package funkin.graphics;

import openfl.display.BitmapData;
import flixel.graphics.frames.FlxFrame;


enum RepeatDrawStyle {
    TOP_BOTTOM;
    BOTTOM_TOP;
}

/**
 * WORK IN PROGRESS
 * @author MaybeMaru
 */

class FlxRepeatSprite extends FlxSpriteExt {    
    public var repeatWidth:Float;
    public var repeatHeight:Float;
    public var drawStyle:RepeatDrawStyle = TOP_BOTTOM;

    public var tilesX(get, null):Int;
    inline function get_tilesX() {
        return Math.ceil(repeatWidth / (frameWidth * scale.x));
    }
    
    public var tilesY(get, null):Int;
    inline function get_tilesY() {
        return Math.ceil(repeatHeight / (frameHeight * scale.y));
    }

    public function setRepeat(repeatWidth:Float, repeatHeight:Float) {
        this.repeatWidth = repeatWidth;
        this.repeatHeight = repeatHeight;
    }

    public function setTiles(tilesX:Float, tilesY:Float) {
        setRepeat(tilesX * frameWidth * scale.x, tilesY * frameHeight * scale.y);
    }
    
    public function new(?X:Float, ?Y:Float, ?SimpleGraphic:FlxGraphicAsset, ?repeatWidth:Float, ?repeatHeight:Float) {
        super(X,Y,SimpleGraphic);
        checkEmptyFrame();
        setRepeat(repeatWidth ?? frameWidth, repeatHeight ?? frameHeight);
    }

    var __tilePoint:FlxPoint = FlxPoint.get();

    override function drawComplex(camera:FlxCamera) {
        _frame.prepareMatrix(_matrix, ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0) {
			updateTrig();
			if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

        /*
            The actual code of the class lol
        */

        __tilePoint.set(_matrix.tx, _matrix.ty);
        final fw:Float = frameWidth * scale.x;
        final fh:Float = frameHeight * scale.y;

        _frame.frame.width = frameWidth;
        _frame.frame.height = frameHeight;

        if (tilesX == 0 || tilesY == 0) {
            return;
        }

        switch (drawStyle) {
            // Draw from left top to right bottom style
            case TOP_BOTTOM:
                for (xi in 0...tilesX) {
                    for (yi in 0...tilesY) {
                        final addW = fw * (xi + 1);
                        if (addW > repeatWidth) // Cut frame width
                            _frame.frame.width = (fw + (repeatWidth - addW)) / scale.x;
                        
                        final addH = fh * (yi + 1);
                        if (addH > repeatHeight) // Cut frame height
                            _frame.frame.height = (fh + (repeatHeight - addH)) / scale.y;
        
                        // Position and draw
                        final addX = addW - fw;
                        final addY = addH - fh;
        
                        _matrix.tx = __tilePoint.x + (addX * _cosAngle) + (addY * -_sinAngle);
                        _matrix.ty = __tilePoint.y + (addX * _sinAngle) + (addY * _cosAngle);
                        
                        drawTile(xi, yi, _frame, frame, framePixels);
                    }
                }
            // Draw from bottom to top style
            case BOTTOM_TOP:
                for (xi in 0...tilesX) {
                    for (yi in 0...tilesY) {
                        final addW = fw * (xi + 1);
                        if (addW > repeatWidth) // Cut frame width
                            _frame.frame.width = (fw + (repeatWidth - addW)) / scale.x;

                        var addH = repeatHeight - (fh * (yi + 1));
                        if (addH < 0) {
                            _frame.frame.height += addH / scale.y;
                            _frame.frame.y -= addH / scale.y;
                            addH -= addH;
                        }

                        // Position and draw
                        final addX = addW - fw;
                        final addY = addH;
        
                        _matrix.tx = __tilePoint.x + (addX * _cosAngle) + (addY * -_sinAngle);
                        _matrix.ty = __tilePoint.y + (addX * _sinAngle) + (addY * _cosAngle);
                        
                        drawTile(xi, yi, _frame, frame, framePixels);
                    }
                }
        }

    }

    function drawTile(tileX:Int, tileY:Int, tileFrame:FlxFrame, baseFrame:FlxFrame, bitmap:BitmapData) {
        camera.drawPixels(tileFrame, bitmap, _matrix, colorTransform, blend, antialiasing, shader);
        tileFrame.frame.copyFrom(baseFrame.frame);
        tileFrame.offset.copyFrom(baseFrame.offset);
    }
}