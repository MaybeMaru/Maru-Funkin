package funkin.objects;

class CustomTransition extends FlxSprite {
    public static var skipTrans:Bool = false;
    public static var transGraphic(get, default):FlxGraphic = null;
    public static var openTimes:Array<Float> = [0.6,0.4];

    public static function get_transGraphic() {
        return (transGraphic == null ? init() : transGraphic);
    }

    public static function set(?color:FlxColor, openTime:Float = 0.6, closeTime:Float = 0.4, ?asset:FlxGraphicAsset) {
        openTimes = [openTime, closeTime];
        if (asset != null) transGraphic = FlxG.bitmap.add(asset, true, 'transition_graphic');
        else {
            color = (color == null ? FlxColor.BLACK : color);
            transGraphic = FlxG.bitmap.create(FlxG.width, FlxG.height * 2, color, true, 'transition_graphic');
            for (i in 0...FlxG.height) {
                var lineAlpha = FlxMath.remapToRange(i, 0, FlxG.height, 0, color.alpha);
                transGraphic.bitmap.fillRect(new Rectangle(0, i, FlxG.width, 1), FlxColor.fromRGB(color.red,color.green,color.blue,Std.int(lineAlpha)));
            }
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
        flipY = true;
        setupTrans(-FlxG.height * 2, 0, openTimes[0], _func);
    }

    public function exitTrans(?completeCallback:Dynamic) {
        flipY = false;
        setupTrans(-FlxG.height, FlxG.height, openTimes[1], completeCallback);
    }

    public function new() {
        super();
        loadGraphic(transGraphic);
        setGraphicSize(FlxG.width, FlxG.height * 2);
        updateHitbox();
        scrollFactor.set();
        y = FlxG.height;
    }

    function setupTrans(start:Float = 0, end:Float = 0, time:Float = 1, ?callback:Dynamic) {
        y = startPosition = (skipTrans ? end : start);
        visible = !skipTrans;
        endPosition = end;
        transDuration = time;
        timeElapsed = 0;
        finishCallback = callback;
        transitioning = true;
    }

    var timeElapsed:Float = 0;
    var transDuration:Float = 1.0;

    var startPosition:Float = 0;
    var endPosition:Float = 720;

    var finishCallback:Dynamic = null;
    var transitioning:Bool = false;

    override public function update(elapsed:Float) {
        if (!transitioning) return;

        timeElapsed += elapsed;
        cameras = [CoolUtil.getTopCam()];
        var lerpValue:Float = FlxMath.bound(timeElapsed / transDuration, 0.0, 1.0);
        y = FlxMath.lerp(startPosition, endPosition, lerpValue);
    
        if (Math.floor(y) == endPosition) {
            if (finishCallback != null) finishCallback();
            transitioning = false;
        }

        super.update(elapsed);
    }
}