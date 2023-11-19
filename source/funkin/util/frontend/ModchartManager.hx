package funkin.util.frontend;
import funkin.objects.note.StrumLineGroup;
import funkin.util.frontend.CutsceneManager;

class ModchartManager extends EventHandler {
    var strumLines:Map<Int, StrumLineGroup> = [];
    
    public function new() {
        super();
        strumLines = new Map<Int, StrumLineGroup>();
    }

    override function destroy() {
        super.destroy();
        strumLines = null;
    }

    public static function makeManager() {
        return new ModchartManager();
    }

    inline public function setStrumLine(id:Int = 0, strumline:StrumLineGroup) {
        strumLines.set(id, strumline);
    }

    inline public function getStrumLine(id:Int = 0) {
        return strumLines.get(id);
    }

    inline public function getStrum(strumlineID:Int = 0, strumID:Int = 0) {
        return getStrumLine(strumlineID)?.members[strumID] ?? null;
    }

    inline public function setStrumPos(l:Int = 0, s:Int = 0, ?X:Float, ?Y:Float) {
        getStrum(l,s).setPosition(X,Y);
    }

    inline public function tweenStrum(l:Int = 0, s:Int = 0, ?values:Dynamic, time:Float = 1.0, ?settings:Dynamic) {
        return FlxTween.tween(getStrum(l, s), values, time, settings);
    }

    inline public function tweenStrumPos(l:Int = 0, s:Int = 0, X:Float = 0, Y:Float = 0, time:Float = 1.0, ?ease:Dynamic) {
        return tweenStrum(l,s, {x: X, y:Y}, time, {ease: ease ?? FlxEase.linear});
    }
}