package funkin.objects;

class CustomTransition extends FlxSprite {
    public static var skipTrans:Bool = false;
    public static var transGraphic(get, default):FlxGraphic = null;
    public static var openTimes:Array<Float> = [0.4,0.3];

    public static function get_transGraphic() {
        return (transGraphic == null ? init() : transGraphic);
    }

    public static function set(?color:FlxColor, openTime:Float = 0.4, closeTime:Float = 0.3) {
        openTimes = [openTime, closeTime];
        color = (color == null ? FlxColor.BLACK : color);
        transGraphic = FlxG.bitmap.create(FlxG.width, FlxG.height * 2, color, true, 'transition_graphic');
        for (i in 0...FlxG.height) {
            var lineAlpha = FlxMath.remapToRange(i, 0, FlxG.height, 0, color.alpha);
            transGraphic.bitmap.fillRect(new Rectangle(0, i, FlxG.width, 1), FlxColor.fromRGB(color.red,color.green,color.blue,Std.int(lineAlpha)));
        }
        transGraphic.persist = true;
        transGraphic.destroyOnNoUse = false;
        return transGraphic;
    }

    public static function init() {
        return set(); // Run defaults
    }

    public function startTrans(?nextState:FlxState, ?completeCallback:Dynamic) {
        var _func = function (?tween:FlxTween) {
            if (completeCallback != null) completeCallback();
            if (nextState != null) FlxG.switchState(nextState);
        }

        if (skipTrans) {
            _func();
            return;
        }
        
        flipY = true;
        visible = true;
        y = -FlxG.height * 2;
        FlxTween.tween(this, {y: 0}, openTimes[0], {
            onComplete: _func
        });
    }

    public function exitTrans() {
        if (skipTrans) return;
        flipY = false;
        visible = true;
        y = -FlxG.height;
        FlxTween.tween(this, {y: FlxG.height}, openTimes[1]);
    }

    public function new() {
        super();
        loadGraphic(transGraphic);
        scrollFactor.set();
        y = FlxG.height;
    }
}