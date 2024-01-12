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
        __fadeSprite.scaleX = FlxG.width;
        __fadeSprite.scaleY = FlxG.height;
        //__fadeSprite.visible = false;
        __fadeSprite.alpha = 0.0;
        _scrollRect.addChild(__fadeSprite);

        __flashSprite = new Bitmap(__baseBitmap.clone());
        __flashSprite.scaleX = FlxG.width;
        __flashSprite.scaleY = FlxG.height;
        //__flashSprite.visible = false;
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