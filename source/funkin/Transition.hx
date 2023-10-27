package funkin;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class Transition extends Sprite {
    public static var skipTrans:Bool = false;
    public static var times = {
        open: 0.6,
        close: 0.4
    }
    var bitmap:Bitmap;

    public function new() {
        super();
        bitmap = new Bitmap();
        addChild(bitmap);
        set();
        visible = false;
        
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.ENTER_FRAME, update);
        //openfl.Lib.current.stage.quality = LOW;
    }
    
    public function set(?color:FlxColor, openTime:Float = 0.6, closeTime:Float = 0.4, ?asset:FlxGraphicAsset) {
        times.open = openTime;
        times.close = closeTime;
        
        if (bitmap.bitmapData != null) {
            bitmap.bitmapData.dispose();
            bitmap.bitmapData.disposeImage();
            bitmap.bitmapData = null;
        }
        
        if (asset != null) {
            if (asset is String) bitmap.bitmapData = AssetManager.getRawBitmap(cast(asset, String));
            else if (asset is FlxGraphic) {
                final _graphic = cast(asset, FlxGraphic);
                bitmap.bitmapData = _graphic.bitmap;
                _graphic.persist = true;
                _graphic.destroyOnNoUse = false;
            } 
            else if (asset is BitmapData) bitmap.bitmapData = cast(asset, BitmapData);

            bitmap.scaleX = FlxG.width / bitmap.bitmapData.width;
            bitmap.scaleY = FlxG.height*2 / bitmap.bitmapData.height;
        } else {
            color = color ?? FlxColor.BLACK;
            final bmp = new BitmapData(FlxG.width, FlxG.height * 2, true, color);
            for (i in 0...FlxG.height) {
                var lineAlpha = FlxMath.remapToRange(i, 0, FlxG.height, 0, color.alpha);
                bmp.fillRect(new Rectangle(0, i, FlxG.width, 1), FlxColor.fromRGB(color.red,color.green,color.blue,Std.int(lineAlpha)));
            }
            bitmap.bitmapData = bmp;
        }

        bitmap.smoothing = true;
        return bitmap.bitmapData;
    }

    var inExit:Bool;

    public function startTrans(?nextState:FlxState, ?completeCallback:Dynamic) {
        var _func = function (?tween:FlxTween) {
            if (completeCallback != null) completeCallback();
            if (nextState != null) FlxG.switchState(nextState);
        }
        this.scaleY = -1;
        inExit = false;
        setupTrans(0, FlxG.height*2, times.open, _func);
    }

    public function exitTrans(?completeCallback:Dynamic) {
        this.scaleY = 1;
        inExit = true;
        setupTrans(-FlxG.height, FlxG.height, times.close, completeCallback);
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

    function update(event) {
        if (!transitioning) return;
        final elapsed = FlxG.elapsed;

        timeElapsed += elapsed;
        var lerpValue:Float = FlxMath.bound(timeElapsed / transDuration, 0.0, 1.0);
        y = FlxMath.lerp(startPosition, endPosition, lerpValue);
    
        if (Math.floor(y) == endPosition) {
            if (finishCallback != null) finishCallback();
            if (inExit) visible = false;
            transitioning = false;
        }

    }
}