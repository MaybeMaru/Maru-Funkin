package funkin.objects;

import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.util.typeLimit.OneOfTwo;
import openfl.display.Shape;
import openfl.display.Bitmap;
import openfl.display.BlendMode;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMatrix;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxFrame;
import openfl.geom.ColorTransform;

using flixel.util.FlxColorTransformUtil;

private typedef FlxDrawItem = flixel.graphics.tile.FlxDrawQuadsItem;

class CameraShape extends Shape {
    public function new() {
        super();
        alpha = 0.0;
    }

    var alphaMult:Float = 1.0;
    var color:FlxColor;

    public inline function setAlpha(Alpha:Float)
        alpha = Alpha * alphaMult;

    public inline function setColor(Color:FlxColor) {
        if (color != Color) {
            color = Color;
            color = FlxColor.fromInt(color);
            alphaMult = color.alphaFloat; // Make the alpha part of the sprite, not the rect
            
            graphics.clear();
            graphics.beginFill(FlxColor.fromRGB(color.red, color.green, color.blue, 255));
            graphics.drawRect(0, 0, 1, 1);
            graphics.endFill();
        }
    }
}

class FunkCamera extends FlxCamera {    
    var __fadeShape:CameraShape;
    var __flashShape:CameraShape;
    
    override public function new(?X, ?Y, ?W, ?H, ?Z) {
        super(X,Y,W,H,Z);
       
        __fadeShape = new CameraShape();
        _scrollRect.addChild(__fadeShape);

        __flashShape = new CameraShape();
        _scrollRect.addChild(__flashShape);

        #if FLX_DEBUG
        _scrollRect.removeChild(debugLayer);
        _scrollRect.addChild(debugLayer);
        #end
    }

    override function destroy() {
        _scrollRect.removeChild(__fadeShape);
        _scrollRect.removeChild(__flashShape);
        __fadeShape = null;
        __flashShape = null;
        
        super.destroy();
    }

    public var updateFX:Bool = true;

    public inline function clearFX():Void {
        _fxFlashAlpha = 0.0;
        _fxFadeDuration = 0.0;

        __fadeShape.alpha = 0.0;
        __flashShape.alpha = 0.0;
    }

    override function update(elapsed:Float) {
        if (target != null)
            updateFollow();

        updateScroll();
        if (updateFX) {
            updateFlash(elapsed);
            updateFade(elapsed);
        }

        flashSprite.filters = filtersEnabled ? filters : null;
        updateFlashSpritePosition();
        updateShake(elapsed);
    }

    private var _shakeX:Float = 0.0;
    private var _shakeY:Float = 0.0;

    override inline function updateShake(elapsed:Float):Void
    {
        if (_fxShakeDuration > 0)
        {
            _fxShakeDuration -= elapsed;
            if (_fxShakeDuration <= 0)
            {
                if (_fxShakeComplete != null)
                    _fxShakeComplete();
            }
            else
            {
                _shakeX = _fxShakeAxes.x ? FlxG.random.float(-1, 1) * _fxShakeIntensity * width : 0;
                _shakeY = _fxShakeAxes.y ? FlxG.random.float(-1, 1) * _fxShakeIntensity * height : 0;
            }
        }
    }

    override inline function drawFX():Void {} // Wont be using this anymore

    override function updateFlash(elapsed:Float):Void {
        if (_fxFlashAlpha > 0.0) {
			_fxFlashAlpha -= elapsed / _fxFlashDuration;
            __flashShape.setAlpha(_fxFlashAlpha);
			
            if (_fxFlashAlpha <= 0) if (_fxFlashComplete != null)
                _fxFlashComplete();
		}
    }

    override function updateFade(elapsed:Float):Void {
		if (_fxFadeDuration == 0.0) return;

		if (_fxFadeIn) {
			_fxFadeAlpha -= elapsed / _fxFadeDuration;
            __fadeShape.setAlpha(_fxFadeAlpha);
			if (_fxFadeAlpha <= 0.0) {
				_fxFadeAlpha = 0.0;
				completeFade();
			}
		}
		else {
			_fxFadeAlpha += elapsed / _fxFadeDuration;
            __fadeShape.setAlpha(_fxFadeAlpha);
			if (_fxFadeAlpha >= 1.0) {
				_fxFadeAlpha = 1.0;
				completeFade();
			}
		}
	}

    override public function fade(Color:FlxColor = FlxColor.BLACK, Duration:Float = 1, FadeIn:Bool = false, ?OnComplete:Void->Void, Force:Bool = false):Void {
        if (_fxFadeDuration > 0) if (!Force)
            return;

		_fxFadeColor = Color;
        __fadeShape.setColor(Color);
		
        if (Duration <= 0) Duration = 0.000001;
		_fxFadeIn = FadeIn;
		_fxFadeDuration = Duration;
		_fxFadeComplete = OnComplete;
		_fxFadeAlpha = _fxFadeIn ? 0.999999 : 0.000001;
	}

    override public function flash(Color:FlxColor = FlxColor.WHITE, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void {
        if (_fxFlashAlpha > 0) if (!Force)
            return;

		_fxFlashColor = Color;
        __flashShape.setColor(Color);
		
        if (Duration <= 0) Duration = 0.000001;
		_fxFlashDuration = Duration;
		_fxFlashComplete = OnComplete;
		_fxFlashAlpha = 1.0;
	}

    override function updateInternalSpritePositions() {
        if (canvas != null)
        {
			canvas.x = -.5 * width * (scaleX - initialZoom) * FlxG.scaleMode.scale.x;
			canvas.y = -.5 * height * (scaleY - initialZoom) * FlxG.scaleMode.scale.y;

			canvas.scaleX = totalScaleX;
			canvas.scaleY = totalScaleY;

            if (__fadeShape != null) if (__flashShape != null) {
                __fadeShape.scaleX = __flashShape.scaleX = totalScaleX * width / zoom;
                __fadeShape.scaleY = __flashShape.scaleY = totalScaleY * height / zoom;
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

    override public function setScale(X:Float, Y:Float):Void {
		scaleX = X;
		scaleY = Y;

		totalScaleX = scaleX * FlxG.scaleMode.scale.x;
		totalScaleY = scaleY * FlxG.scaleMode.scale.y;

		calcMarginX();
		calcMarginY();

		updateScrollRect();
		updateInternalSpritePositions();

		FlxG.cameras.cameraResized.dispatch(this);
	}

    
    public var pixelPerfect:Bool = false;
    public var pixelMult(default, set):Int = 1;
    inline function set_pixelMult(value:Int):Int {
        return pixelMult = (value < 1 ? 1 : value);
    }
    
    override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
    {
        if (_fxShakeDuration > 0) {
            matrix.tx = (matrix.tx + _shakeX);
            matrix.ty = (matrix.ty + _shakeY);
        }
        
        if (pixelPerfect) {
            matrix.tx = Std.int(matrix.tx / pixelMult) * pixelMult;
            matrix.ty = Std.int(matrix.ty / pixelMult) * pixelMult;
        }
        
        if (transform != null) {
            final hasColors = transform.hasRGBMultipliers() || transform.hasRGBAOffsets();
            final drawItem = startQuadBatch(frame.parent, hasColors, hasColors, blend, smoothing, shader);
            drawItem.addQuad(frame, matrix, transform);
        }
        else {
            final drawItem = startQuadBatch(frame.parent, false, false, blend, smoothing, shader);
            drawItem.addQuad(frame, matrix, transform);
        }
	}

    @:noCompletion
	public override function startQuadBatch(graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false, ?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader)
	{
		#if FLX_RENDER_TRIANGLE
		return startTrianglesBatch(graphic, smooth, colored, blend);
		#else
		var itemToReturn = null;

        if (_currentDrawItem != null)
        if (_currentDrawItem.type == FlxDrawItemType.TILES)
        {
            if (_headTiles.graphics == graphic)
            if (_headTiles.colored == colored)
            if (_headTiles.blend == blend)
            if (_headTiles.antialiasing == smooth)
            if (_headTiles.shader == shader)
                return _headTiles;
        }

        if (FlxCamera._storageTilesHead != null)
		{
			itemToReturn = FlxCamera._storageTilesHead;
			var newHead = itemToReturn.nextTyped;
			itemToReturn.reset();
			FlxCamera._storageTilesHead = newHead;
		}
		else
		{
			itemToReturn = new FlxDrawItem();
		}

		itemToReturn.graphics = graphic;
		itemToReturn.antialiasing = smooth;
		itemToReturn.colored = colored;
		itemToReturn.blend = blend;
		itemToReturn.shader = shader;

		itemToReturn.nextTyped = _headTiles;
		_headTiles = itemToReturn;

		if (_headOfDrawStack == null)
			_headOfDrawStack = itemToReturn;

		if (_currentDrawItem != null)
			_currentDrawItem.next = itemToReturn;

		_currentDrawItem = itemToReturn;

		return itemToReturn;
		#end
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

    override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader)
    {
        if (_fxShakeDuration > 0) {
            matrix.tx = (matrix.tx + _shakeX);
            matrix.ty = (matrix.ty + _shakeY);
        }
        
        if (angle != 0) {
            final midX = width * .5;
            final midY = height * .5;

            matrix.tx = (matrix.tx - midX);
            matrix.ty = (matrix.ty - midY);
            matrix.rotateWithTrig(_cos, _sin);
            matrix.tx = (matrix.tx + midX);
            matrix.ty = (matrix.ty + midY);
        }

        if (pixelPerfect) {
            matrix.tx = Std.int(matrix.tx / pixelMult) * pixelMult;
            matrix.ty = Std.int(matrix.ty / pixelMult) * pixelMult;
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