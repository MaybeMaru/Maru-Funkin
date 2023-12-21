package funkin.graphics;

import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import openfl.display.BitmapData;

/*
    TODO: add skew y support (_matrix.b) and fix problems with dynamically sized tiles
*/

class FlxSkewRepeatSprite extends FlxRepeatSprite {
    static final tempMatrix:FlxMatrix = new FlxMatrix();
    static var idY:Int = -1;

    public var wigglePower:Float = 50.0;

    override function update(elapsed:Float) {
        super.update(elapsed);
        clipRect.y -= elapsed * 25;
    }

    override function drawTile(tileX:Int, tileY:Int, tileFrame:FlxFrame, baseFrame:FlxFrame, bitmap:BitmapData, tilePos:FlxPoint) {
        if (wigglePower == 0) {
            super.drawTile(tileX, tileY, tileFrame, baseFrame, bitmap, tilePos);
            return;
        }

        idY = tileY;
        
        tempMatrix.copyFrom(_matrix);

        final wiggleX = wigglePower * ((baseFrame.frame.height * scale.y) * 0.01); // Value outta my ass but trust me bro
        final skewX = wiggleX * (idY % 2 == 0 ? -1 : 1);
        _matrix.c = Math.tan(skewX * FlxAngle.TO_RAD);

        if (clipRect == null) offsetSkew(tileFrame, baseFrame);
        
        super.drawTile(tileX, idY, tileFrame, baseFrame, bitmap, tilePos);
        _matrix.copyFrom(tempMatrix);
    }

    inline function offsetSkew(tileFrame:FlxFrame, baseFrame:FlxFrame) {
        final multX = tileFrame.frame.height / baseFrame.frame.height;
        if (idY % 2 == 0) _matrix.translate(-_matrix.c * baseFrame.frame.width * multX, 0);
        else if (multX != 1) {
            _matrix.translate(-_matrix.c * baseFrame.frame.width * multX, 0);
            _matrix.translate(baseFrame.frame.width * _matrix.c, 0);
        }
    }

    override function handleClipRect(tileFrame:FlxFrame, baseFrame:FlxFrame, tilePos:FlxPoint):Bool {
        final _draw = super.handleClipRect(tileFrame, baseFrame, tilePos);
        if (_draw) offsetSkew(tileFrame, baseFrame);
        return _draw;
    }
}