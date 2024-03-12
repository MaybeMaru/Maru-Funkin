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

    // If to flip the display of the bar (for opponent play)
    public var flipped:Bool = false;

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
		if (alpha == 0 || !visible || _frame.type == EMPTY) return;
		if (dirty) calcFrame(useFramePixels);  // rarely

        cameras.fastForEach((camera, i) -> {
			barPoint.set(-9999,-9999);
            if (camera.visible) if (camera.exists) if (isOnScreen(camera)) {
				drawComplex(camera);
				#if FLX_DEBUG FlxBasic.visibleCount++; #end
			}
		});

		#if FLX_DEBUG if (FlxG.debugger.drawDebug) drawDebug(); #end
    }

    override function drawComplex(camera:FlxCamera)
    {
		__prepareDraw();

        var percent:Float = percent;
        if (flipped)
            percent = 100 - percent;
        
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
                _frame.frame.width = percentCut * lodDiv;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }
    
            _matrix.translate(percentCut * _cosAngle, percentCut * _sinAngle);

            if (percent != 0) {
                color = colors[1];
                _frame.frame.x = percentCut * lodDiv;
                _frame.frame.width = percentWidth * lodDiv;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }

            barPoint.set(_matrix.tx + (barCenter * -_sinAngle), _matrix.ty + (barCenter * _cosAngle));
        }
    }
}