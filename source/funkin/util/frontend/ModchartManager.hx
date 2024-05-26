package funkin.util.frontend;

import funkin.objects.NotesGroup;
import funkin.objects.note.StrumLineGroup;
import funkin.util.frontend.CutsceneManager;

typedef ModchartData = {
    var cos:Array<Float>; // [size, offset]
	var sin:Array<Float>; // [size, offset]
    var boost:Array<Float>; // [acceleration, startPosition]
}

class ModchartManager extends EventHandler implements IMusicHit
{
    @:unreflective
    static final DEFAULT_DATA:ModchartData = {
        cos: [0, 0],
        sin: [0, 0],
        boost: [0, 200]
    }

    private var strumLines:Map<Int, StrumLineGroup> = [];
    
    public function new():Void {
        super();
        strumLines = new Map<Int, StrumLineGroup>();
        destroyOnComplete = false;
    }

    override function destroy():Void {
        super.destroy();
        strumLines = null;
    }

    public static function makeManager():ModchartManager {
        return new ModchartManager();
    }

    /**
      * GETTING / SETTING STRUMS
     **/

    inline public function setStrumLine(id:Int = 0, strumline:StrumLineGroup):Void {
        strumLines.set(id, strumline);
    }

    inline public function getStrumLine(id:Int = 0):StrumLineGroup {
        return strumLines.get(id);
    }

    inline public function getStrum(strumlineID:Int = 0, strumID:Int = 0):NoteStrum {
        return getStrumLine(strumlineID)?.members[strumID] ?? null;
    }

    /**
      * STRUM MOVEMENT
     **/

    inline public function setStrumPos(l:Int = 0, s:Int = 0, ?X:Float, ?Y:Float):Void {
        getStrum(l,s).setPosition(X,Y);
    }

    inline public function moveStrum(l:Int = 0, s:Int = 0, X:Float = 0, Y:Float = 0):Void {
        var strum = getStrum(l, s);
        strum.x += X;
        strum.y += Y;
    }

    inline public function offsetStrum(l:Int = 0, s:Int = 0, X:Float = 0, Y:Float = 0):Void {
        moveStrum(l, s, -X, -Y);
    }

    inline public function tweenStrum(l:Int = 0, s:Int = 0, ?values:Dynamic, time:Float = 1.0, ?settings:Dynamic) {
        return FlxTween.tween(getStrum(l, s), values, time, settings);
    }

    inline public function tweenStrumPos(l:Int = 0, s:Int = 0, X:Float = 0, Y:Float = 0, time:Float = 1.0, ?ease:Dynamic) {
        return tweenStrum(l,s, {x: X, y:Y}, time, {ease: ease ?? FlxEase.linear});
    }

    /**
      * STRUM MODIFIERS
     **/

    // TODO: add the typical modchart effects like drunk, wavy n all that shit

    public function setValue(value:String, ?data:Dynamic) {
        for (strumline in strumLines.keys())
            setStrumLineValue(strumline, value, data);
    }

    inline public function setStrumLineValue(strumline:Int, value:String, ?data:Dynamic) {
        for (i in 0...getStrumLine(strumline).members.length)
            setStrumValue(strumline, i, value, data);
    }

    inline public function setStrumValue(strumline:Int, id:Int, value:String, ?valueData:Dynamic) {
        final data = resolveData(getStrum(strumline, id));
        value = value.toLowerCase().trim();
        
        if (Reflect.hasField(data, value))
        {
            if (valueData != null)
                Reflect.setProperty(data, value, valueData);
        }
        else
        {
            ModdingUtil.warningPrint("Couldn't find modchart value for " + '"$value"');
        }
    }
    
    public var speed:Float = 1.0;
    var startTick:Float = 0; // Game tick the modchart started at, for cosine stuff
    var timeElapsed:Float;

    override function start() {
        startTick = FlxG.game.ticks;
        super.start();
    }

    override function updatePosition() {
        position = Conductor.songPosition;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        timeElapsed = ((FlxG.game.ticks - startTick) * speed * 0.0001) % FunkMath.DOUBLE_PI;

        for (key => strumline in strumLines) {
            strumline.members.fastForEach((strum, i) -> {
                if (strum.modchart != null)
                    manageStrum(strum, strum.modchart);
            });
        }
    }
    
    // TODO: add shit with these
    
    public function stepHit(curStep:Int):Void {}

    public function beatHit(curBeat:Int):Void {}

    public function sectionHit(curSection:Int):Void {}

    // Backend crap

    function resolveData(strum:NoteStrum):ModchartData
    {
        if (strum.modchart == null)
            strum.modchart = Reflect.copy(DEFAULT_DATA);
           
        return strum.modchart;
    }

    function manageStrum(strum:NoteStrum, data:ModchartData)
    {
        strum.xModchart = 0;
        strum.yModchart = 0;

        // COS MODIFIER
        if (data.cos[0] != 0) {
            strum.xModchart += (FunkMath.cos(timeElapsed + data.cos[1]) * data.cos[0]);
        }
        
        // SIN MODIFIER
        if (data.sin[0] != 0) {
            strum.yModchart += (FunkMath.sin(timeElapsed + data.sin[1]) * data.sin[0]);
        }

        // BOOST MODIFIER
        if (data.boost[0] != 0)
        {
            NotesGroup.instance.notes.members.fastForEach((note, i) ->
            {
                if (note != null) if (!note.isSustainNote) if (note.targetStrum == strum)
                {
                    final diff = note.strumTime - Conductor.songPosition;
                    final pos = diff * (0.45 * note.noteSpeed);

                    if (pos <= data.boost[1])
                    {
                        // Boost acceleration crap
                        final targetTime = data.boost[1] / (0.45 * note.noteSpeed);
                        final mult = (1 - (diff / targetTime)) * data.boost[0];

                        note.speedMult = mult;
                        if (note.child != null)
                            note.child.speedMult = mult;
                    }
                }
            });
        }
    }
}