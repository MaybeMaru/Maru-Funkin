package funkin.objects.funkui;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import haxe.ds.Vector;

/*
 * Like FlxBar but less cringe
**/
class FunkBar extends FlxSpriteExt {
    public var colors:Vector<Int>;
    public var percent:Float = 50.0;
    var max:Float;

    // Adds a rectangle on top of the graphic instead of coloring the graphic
    public var legacyMode:{active:Bool, outline:Float, inFront:Bool, sprite:FlxSprite} = null;
    
    public function new(X:Float, Y:Float, imagePath:String, max:Float = 2.0) {
        super(X, Y);
        scrollFactor.set();
        this.max = max;
        loadImage(imagePath);
        colors = new Vector(2);
        createFilledBar(0xFFFF0000, 0xFF66FF33);
        updateBar(1.0);

        // Turned off but with the default funkin healthbar variables
        legacyMode = {
            active: false,
            outline: 4.0,
            inFront: true,
            sprite: new FlxSprite().makeGraphic(cast width, cast height)
        }
    }

    override function destroy() {
        super.destroy();
        barPoint = FlxDestroyUtil.put(barPoint);
        legacyMode.sprite.destroy();
        colors = null;
        legacyMode = null;
    }

    public inline function createColoredEmptyBar(color:Int) {
        colors[0] = color;
    }

    public inline function createColoredFilledBar(color:Int) {
        colors[1] = color;
    }

    public inline function createFilledBar(color1:Int, color2:Int) {
        createColoredEmptyBar(color1);
        createColoredFilledBar(color2);
    }

    public inline function updateBar(value:Float) {
        percent = value / max * 100.0;
    }

    public var barPoint:FlxPoint = FlxPoint.get();

    override function draw() {
        inline checkEmptyFrame();
		if (alpha == 0 || !visible || #if web _frame == null #elseif desktop _frame.type == EMPTY #end) return;
		if (dirty) calcFrame(useFramePixels);  // rarely

		for (i in 0...cameras.length) {
			final camera = cameras[i];
			if (!camera.visible || !camera.exists || !isOnScreen(camera)) {
                barPoint.set(-9999,-9999);
                continue;
            }
			drawComplex(camera);
			#if FLX_DEBUG flixel.FlxBasic.visibleCount++; #end
		}

		#if FLX_DEBUG if (FlxG.debugger.drawDebug) drawDebug(); #end
    }

    override function drawComplex(camera:FlxCamera) {
		prepareFrameMatrix(_frame, _matrix, checkFlipX(), checkFlipY());
		
		inline _matrix.translate(-origin.x, -origin.y);
		inline _matrix.scale(scale.x, scale.y);

		if (angle != 0) {
			__updateTrig();
			_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		if (skew.x != 0 || skew.y != 0) {
			inline _skewMatrix.identity();
			_skewMatrix.b = Math.tan(skew.y * CoolUtil.TO_RADS);
			_skewMatrix.c = Math.tan(skew.x * CoolUtil.TO_RADS);
			inline _matrix.concat(_skewMatrix);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

        /*
         * This isn't pretty too look at but shhhhhh it works
        **/
        
        var percentWidth = width * percent * 0.01;
        var percentCut = width - percentWidth;
        var barCenter = height * 0.5;
        
        if (legacyMode.active) {
            final _mX = _matrix.tx;
            final _mY = _matrix.ty;
            if (legacyMode.inFront) camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            
            final _spr = legacyMode.sprite;
            final __frame = _spr.frame;
            final _out = legacyMode.outline * 2;

            _matrix.translate(legacyMode.outline * (_cosAngle - _sinAngle), legacyMode.outline * (_cosAngle + _sinAngle));
            __frame.frame.height = height - _out;

            if (percent != 100) {
                _spr.color = colors[0];
                __frame.frame.width = width - _out;
                camera.drawPixels(__frame, _spr.framePixels, _matrix, _spr.colorTransform, blend, antialiasing, shader);
            }

            _matrix.translate(percentCut * _cosAngle, percentCut * _sinAngle);

            if (percent != 0) {
                _spr.color = colors[1];
                __frame.frame.width = percentWidth - _out;
                camera.drawPixels(__frame, _spr.framePixels, _matrix, _spr.colorTransform, blend, antialiasing, shader);
            }

            barPoint.set(_matrix.tx + (barCenter * -_sinAngle), _matrix.ty + (barCenter * _cosAngle));

            if (!legacyMode.inFront) {
                _matrix.tx = _mX;
                _matrix.ty = _mY;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }
        }
        else {
            if (percent != 100) {
                color = colors[0];
                _frame.frame.x = 0;
                _frame.frame.width = percentCut;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }
    
            _matrix.translate(percentCut * _cosAngle, percentCut * _sinAngle);

            if (percent != 0) {
                color = colors[1];
                _frame.frame.x = percentCut;
                _frame.frame.width = percentWidth;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }

            barPoint.set(_matrix.tx + (barCenter * -_sinAngle), _matrix.ty + (barCenter * _cosAngle));
        }
    }
}