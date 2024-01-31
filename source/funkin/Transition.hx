package funkin;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event as OpenFlEvent;

class ResizableSprite extends Sprite {
    public function new() {
        super();
        addEventListener(OpenFlEvent.ADDED_TO_STAGE, create);
    }

    function create(_):Void {
        stage.addEventListener(OpenFlEvent.RESIZE, onResize);
    }
    
    function onResize(_):Void {
        final _scale = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height);
        scaleX = _scale;
        scaleY = _scale;
    }
}

class Transition extends ResizableSprite {
    public static var skipTransOpen:Bool = false;
    public static var skipTransClose:Bool = false;

    public inline static function setSkip(open:Bool = false, ?close:Bool) {
        skipTransOpen = open;
		skipTransClose = close ?? open;
    }
    
    public static var times = {
        open: 0.4,
        close: 0.3
    }
    var bitmap:Bitmap;

    public function new() {
        super();
        bitmap = new Bitmap();
        addChild(bitmap);
        set();
        visible = false;
    }
    
    public function set(?color:FlxColor, openTime:Float = 0.4, closeTime:Float = 0.3, ?asset:FlxGraphicAsset) {
        times.open = openTime;
        times.close = closeTime;
        
        if (asset != null) {
            if (asset is String) {
                bitmap.bitmapData = AssetManager.getFileBitmap(asset, true);
            }
            else if (asset is FlxGraphic) {
                final _graphic = cast(asset, FlxGraphic);
                bitmap.bitmapData = _graphic.bitmap;
                _graphic.persist = true;
                _graphic.destroyOnNoUse = false;
            } 
            else if (asset is BitmapData) {
                bitmap.bitmapData = asset;
            }
            updateScale();
        }
        else {
            color = color ?? FlxColor.BLACK;
            final bmp = new BitmapData(FlxG.width, FlxG.height * 2, true, color);
            for (i in 0...FlxG.height) {
                var lineAlpha = FlxMath.remapToRange(i, 0, FlxG.height, 0, color.alpha);
                bmp.fillRect(new Rectangle(0, i, FlxG.width, 1), FlxColor.fromRGB(color.red,color.green,color.blue,Std.int(lineAlpha)));
            }
            bitmap.bitmapData = bmp;
            bitmap.scaleX = bitmap.scaleY = 1;
        }

        bitmap.smoothing = true;
        return bitmap.bitmapData;
    }

    inline function updateScale() {
        bitmap.scaleX = FlxG.width / bitmap.bitmapData.width;
        bitmap.scaleY = FlxG.height*2 / bitmap.bitmapData.height;
    }

    var inExit:Bool;

    public function startTrans(?nextState:FlxState, ?completeCallback:Dynamic) {
        final _func = function (?tween:FlxTween) {
            if (completeCallback != null) completeCallback();
            if (nextState != null) FlxG.switchState(nextState);
        }
        scaleY = -Math.abs(scaleY);
        inExit = false;
        setupTrans(0, height, times.open, _func, true);
    }

    public function exitTrans(?completeCallback:Dynamic) {
        scaleY = Math.abs(scaleY);
        inExit = true;
        setupTrans(-height * 0.5, height * 0.5, times.close, completeCallback, false);
    }

    function setupTrans(start:Float = 0, end:Float = 0, time:Float = 1, ?callback:Dynamic, isOpen:Bool) {
        final skipBool:Bool = (isOpen ? skipTransOpen : skipTransClose);
        
        y = startPosition = start;
        visible = !skipBool;
        endPosition = end;
        transDuration = time;
        timeElapsed = 0;
        finishCallback = callback;
        inTransition = true;
        
        if (skipBool) {
            __finishTrans();
        }
    }

    var timeElapsed:Float = 0;
    var transDuration:Float = 1.0;

    var startPosition:Float = 0;
    var endPosition:Float = 720;

    var finishCallback:Dynamic = null;
    public var inTransition(default, null):Bool = false;

    public function update(elapsed:Float) {
        if (inTransition) {
            timeElapsed += elapsed;
            final lerpValue:Float = FlxMath.bound(timeElapsed / transDuration, 0.0, 1.0);
            y = FlxMath.lerp(startPosition, endPosition, lerpValue);
        
            if (timeElapsed >= transDuration) {
                __finishTrans();
            }
        }
    }

    @:noCompletion
    function __finishTrans() {
        if (finishCallback != null) Reflect.callMethod(null, finishCallback, []);
        if (inExit) visible = false;
        inTransition = false;
    }
}