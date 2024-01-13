package funkin.objects;

import openfl.display.Bitmap;
import openfl.display.BlendMode;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMatrix;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxFrame;
import openfl.geom.ColorTransform;

using flixel.util.FlxColorTransformUtil;

class FunkCamera extends FlxCamera {    
    var __fadeSprite:Bitmap;
    var __flashSprite:Bitmap;
    
    override public function new(?X,?Y,?W,?H,?Z) {
        super(X,Y,W,H,Z);
        
        __fadeSprite = new Bitmap(__baseBitmap.clone());
        __fadeSprite.alpha = 0.0;
        _scrollRect.addChild(__fadeSprite);

        __flashSprite = new Bitmap(__baseBitmap.clone());
        __flashSprite.alpha = 0.0;
        _scrollRect.addChild(__flashSprite);

        #if FLX_DEBUG
        _scrollRect.removeChild(debugLayer);
        _scrollRect.addChild(debugLayer);
        #end
    }

    override function destroy() {
        _scrollRect.removeChild(__fadeSprite);
        _scrollRect.removeChild(__flashSprite);
        AssetManager.disposeBitmap(__fadeSprite.bitmapData);
        AssetManager.disposeBitmap(__flashSprite.bitmapData);
        __fadeSprite = null;
        __flashSprite = null;
        
        super.destroy();
    }

    private static var __rect:Rectangle = new Rectangle(0,0,1,1);
    private static var __baseBitmap:BitmapData = new BitmapData(1,1,false,0xFFFFFFFF);

    inline private function __setFadeColor(color:Int) {
        __fadeSprite.bitmapData.fillRect(__rect, color);
    }

    inline private function __setFlashColor(color:Int) {
        __flashSprite.bitmapData.fillRect(__rect, color);
    }

    override function drawFX():Void {
		if (_fxFlashAlpha > 0.0) __flashSprite.alpha = _fxFlashAlpha;
		if (_fxFadeAlpha > 0.0) __fadeSprite.alpha = _fxFadeAlpha;
	}

    override public function fade(Color:FlxColor = FlxColor.BLACK, Duration:Float = 1, FadeIn:Bool = false, ?OnComplete:Void->Void, Force:Bool = false):Void {
		if (_fxFadeDuration > 0 && !Force) return;

		_fxFadeColor = Color;
        __setFadeColor(Color);
		
        if (Duration <= 0) Duration = 0.000001;
		_fxFadeIn = FadeIn;
		_fxFadeDuration = Duration;
		_fxFadeComplete = OnComplete;
		_fxFadeAlpha = _fxFadeIn ? 0.999999 : 0.000001;
	}

    override public function flash(Color:FlxColor = FlxColor.WHITE, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void {
		if (!Force && (_fxFlashAlpha > 0.0)) return;

		_fxFlashColor = Color;
        __setFlashColor(Color);
		
        if (Duration <= 0) Duration = 0.000001;
		_fxFlashDuration = Duration;
		_fxFlashComplete = OnComplete;
		_fxFlashAlpha = 1.0;
	}

    override function updateInternalSpritePositions() {
        if (canvas != null) {
			canvas.x = -0.5 * width * (scaleX - initialZoom) * FlxG.scaleMode.scale.x;
			canvas.y = -0.5 * height * (scaleY - initialZoom) * FlxG.scaleMode.scale.y;

			canvas.scaleX = totalScaleX;
			canvas.scaleY = totalScaleY;

            if (__fadeSprite != null && __flashSprite != null) {
                __fadeSprite.scaleX = __flashSprite.scaleX = totalScaleX * width * 1.25;
                __fadeSprite.scaleY = __flashSprite.scaleY = totalScaleY * height * 1.25;
            }

			#if FLX_DEBUG
			if (debugLayer != null) {
				debugLayer.x = canvas.x;
				debugLayer.y = canvas.y;

				debugLayer.scaleX = totalScaleX;
				debugLayer.scaleY = totalScaleY;
			}
			#end
		}
    }
    
    override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void {        
        if (transform != null) {
            final drawItem = startQuadBatch(frame.parent, inline transform.hasRGBMultipliers(), inline transform.hasRGBAOffsets(), blend, smoothing, shader);
            drawItem.addQuad(frame, matrix, transform);
        }
        else {
            final drawItem = startQuadBatch(frame.parent, false, false, blend, smoothing, shader);
            drawItem.addQuad(frame, matrix, transform);
        }
	}
}

class AngledCamera extends FunkCamera {
    @:noCompletion
    private var _sin(default, null):Float = 0.0;

    @:noCompletion
    private var _cos(default, null):Float = 0.0;

    override function set_angle(value:Float):Float {
        if (value != angle) {
            final rads:Float = value * CoolUtil.TO_RADS;
            _sin = CoolUtil.sin(rads);
            _cos = CoolUtil.cos(rads);
        }
        return angle = value;
    }

    override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader) {
        if (angle != 0) {
            inline matrix.translate(-width * .5, -height * .5);
            matrix.rotateWithTrig(_cos, _sin);
            inline matrix.translate(width * .5, height * .5);
        }

        if (transform != null) {
            final drawItem = startQuadBatch(frame.parent, inline transform.hasRGBMultipliers(), inline transform.hasRGBAOffsets(), blend, smoothing, shader);
            drawItem.addQuad(frame, matrix, transform);
        }
        else {
            final drawItem = startQuadBatch(frame.parent, false, false, blend, smoothing, shader);
            drawItem.addQuad(frame, matrix, transform);
        }
    }
}