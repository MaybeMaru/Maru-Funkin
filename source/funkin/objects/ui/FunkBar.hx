package funkin.objects.ui;

import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import haxe.ds.Vector;

/*
 * Like FlxBar but less cringe
**/
class FunkBar extends FlxSpriteExt {
    public var colors:Vector<Int>;
    public var percent:Float = 0.5;
    var max:Float;
    
    public function new(X:Float, Y:Float, imagePath:String, max:Float = 2.0) {
        super(X, Y);
        scrollFactor.set();
        this.max = max;
        loadImage(imagePath);
        colors = new Vector(2);
        colors[0] = 0xFFFF0000;
        colors[1] = 0xFF66FF33;

        updateBar(1.0);
    }

    public function createColoredEmptyBar(color:Int) {
        colors[0] = color;
    }

    public function createColoredFilledBar(color:Int) {
        colors[1] = color;
    }

    public function createFilledBar(color1:Int, color2:Int) {
        createColoredEmptyBar(color1);
        createColoredFilledBar(color2);
    }

    public function updateBar(value:Float) {
        percent = value / max * 100.0;
    }

    override function drawComplex(camera:FlxCamera) {
        _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

        color = colors[0];
        _frame.frame.x = 0;
        _frame.frame.width = width;
        camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);

        color = colors[1];
        final _pos = width * percent * 0.01;
        _frame.frame.x = width - _pos;
        _frame.frame.width = _pos;
        _matrix.translate(width - _pos, 0);
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
    }
}