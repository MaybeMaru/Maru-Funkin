package funkin.util.frontend;
import funkin.objects.note.StrumLineGroup;
import funkin.util.frontend.CutsceneManager;

class ModchartManager extends EventHandler
{
    private var strumLines:Map<Int, StrumLineGroup> = [];
    
    public function new():Void {
        super();
        strumLines = new Map<Int, StrumLineGroup>();
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
      * STRUM EFFECTS
     **/

    // TODO: add the typical modchart effects like drunk, wavy n all that shit

    inline public function setStrumLineSin(l:Int = 0, offPerNote:Float = 0.0, size:Float = 50.0, ?startY:Float) {
        for (i in 0...getStrumLine(l).members.length)
            setStrumSin(l, i, offPerNote * i, size, startY);
    }

    inline public function setStrumLineCos(l:Int = 0, offPerNote:Float = 0.0, size:Float = 50.0, ?startX:Float) {
        for (i in 0...getStrumLine(l).members.length)
            setStrumCos(l, i, offPerNote * i, size, startX);
    }

    inline public function setStrumSin(l:Int = 0, s:Int = 0, off:Float = 0.0, size:Float = 50.0, ?startY:Float) {
        final strum = getStrum(l, s);
        sinStrums.remove(strum);

        strum.modchart.startY = startY ?? strum.y;
        strum.modchart.sinOff = off;
        strum.modchart.sinSize = size;
        sinStrums.push(strum);
    }

    inline public function setStrumCos(l:Int = 0, s:Int = 0, off:Float = 0.0, size:Float = 50.0, ?startX:Float) {
        final strum = getStrum(l, s);
        cosStrums.remove(strum);

        strum.modchart.startX = startX ?? strum.x;
        strum.modchart.cosOff = off;
        strum.modchart.cosSize = size;
        cosStrums.push(strum);
    }

    var sinStrums:Array<NoteStrum> = [];
    var cosStrums:Array<NoteStrum> = [];

    public var speed:Float = 1.0;
    var startTick:Float = 0; // Game tick the modchart started at, for cosine stuff

    override function start() {
        startTick = FlxG.game.ticks;
        super.start();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        final timeElapsed = ((FlxG.game.ticks - startTick) * speed * 0.0001) % FunkMath.DOUBLE_PI;

        if (cosStrums.length > 0) {
            cosStrums.fastForEach((strum, i) -> {
                strum.x = (strum.modchart.startX) + (FunkMath.cos(timeElapsed + (strum.modchart.cosOff)) * (strum.modchart.cosSize));
            });
        }

        if (sinStrums.length > 0) {
            sinStrums.fastForEach((strum, i) -> {
                strum.y = (strum.modchart.startY) + (FunkMath.sin(timeElapsed + (strum.modchart.sinOff)) * (strum.modchart.sinSize));
            });
        }
    }

    override function updatePosition() {
        position = Conductor.songPosition;
    }
}