package funkin.util.frontend;
import funkin.objects.note.StrumLineGroup;
import funkin.util.frontend.CutsceneManager;

class ModchartManager extends EventHandler {
    var strumLines:Map<Int, StrumLineGroup> = [];
    
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

    inline public function setStrumLine(id:Int = 0, strumline:StrumLineGroup):Void {
        strumLines.set(id, strumline);
    }

    inline public function getStrumLine(id:Int = 0):StrumLineGroup {
        return strumLines.get(id);
    }

    inline public function getStrum(strumlineID:Int = 0, strumID:Int = 0):NoteStrum {
        return getStrumLine(strumlineID)?.members[strumID] ?? null;
    }

    inline public function setStrumPos(l:Int = 0, s:Int = 0, ?X:Float, ?Y:Float):Void {
        getStrum(l,s).setPosition(X,Y);
    }

    inline public function tweenStrum(l:Int = 0, s:Int = 0, ?values:Dynamic, time:Float = 1.0, ?settings:Dynamic) {
        return FlxTween.tween(getStrum(l, s), values, time, settings);
    }

    inline public function tweenStrumPos(l:Int = 0, s:Int = 0, X:Float = 0, Y:Float = 0, time:Float = 1.0, ?ease:Dynamic) {
        return tweenStrum(l,s, {x: X, y:Y}, time, {ease: ease ?? FlxEase.linear});
    }

    inline public function setStrumLineSine(l:Int = 0, offPerNote:Float = 0.0, size:Float = 50.0, ?startY:Float) {
        for (i in 0... getStrumLine(l).members.length)
            setStrumSine(l, i, offPerNote * i, size, startY);
    }

    inline public function setStrumLineCosine(l:Int = 0, offPerNote:Float = 0.0, size:Float = 50.0, ?startX:Float) {
        for (i in 0... getStrumLine(l).members.length)
            setStrumCosine(l, i, offPerNote * i, size, startX);
    }

    // Requires the manager to be added to the state to work

    inline public function setStrumSine(l:Int = 0, s:Int = 0, off:Float = 0.0, size:Float = 50.0, ?startY:Float) {
        final strum = getStrum(l, s);
        sineStrums.remove(strum);

        strum._dynamic.startY = startY ?? strum.y;
        strum._dynamic.sineOff = off;
        strum._dynamic.sineSize = size;
        sineStrums.push(strum);
    }

    inline public function setStrumCosine(l:Int = 0, s:Int = 0, off:Float = 0.0, size:Float = 50.0, ?startX:Float) {
        final strum = getStrum(l, s);
        cosineStrums.remove(strum);

        strum._dynamic.startX = startX ?? strum.x;
        strum._dynamic.cosineOff = off;
        strum._dynamic.cosineSize = size;
        cosineStrums.push(strum);
    }

    var sineStrums:Array<NoteStrum> = [];
    var cosineStrums:Array<NoteStrum> = [];
    
    var timeElapsed:Float = 0.0;
    var speed:Float = 1.0;

    override function update(elapsed:Float) {
        timeElapsed += elapsed * speed;
        timeElapsed %= Math.PI * 2;
        super.update(elapsed);

        if (sineStrums.length > 0 || cosineStrums.length > 0) {
            for (i in sineStrums)
                i.y = (i._dynamic?.startY ?? 0) + (FlxMath.fastSin(timeElapsed + (i._dynamic?.sineOff ?? 0)) * (i._dynamic?.sineSize ?? 50.0));

            for (i in cosineStrums)
                i.x = (i._dynamic?.startX ?? 0) + (FlxMath.fastCos(timeElapsed + (i._dynamic?.cosineOff ?? 0)) * (i._dynamic?.cosineSize ?? 50.0));
        }
    }
}