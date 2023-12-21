package funkin.graphics;

import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import openfl.display.BitmapData;

/*
    TODO: add skew y support (_matrix.b) and fix problems with dynamically sized tiles
*/

class FlxSkewRepeatSprite extends FlxRepeatSprite {

    static final tempMatrix:FlxMatrix = new FlxMatrix();

    public var wigglePower:Float = 50.0;


    var elp:Float = 0.0;

    override function update(elapsed:Float) {
        super.update(elapsed);
        elp += elapsed * 10;
        wigglePower = Math.sin(elp) * 50;
    }

    static var matX:Float = 0.0;

    override function drawTile(tileX:Int, tileY:Int, tileFrame:FlxFrame, baseFrame:FlxFrame, bitmap:BitmapData, tilePos:FlxPoint) {
        if (wigglePower == 0) {
            super.drawTile(tileX, tileY, tileFrame, baseFrame, bitmap, tilePos);
            return;
        } 
        
        tempMatrix.copyFrom(_matrix);

        final wiggleX = wigglePower * ((baseFrame.frame.height * scale.y) * 0.01); // Value outta my ass but trust me bro
        
        final skewX = wiggleX * (tileY % 2 == 0 ? -1 : 1);
        _matrix.c = Math.tan(skewX * FlxAngle.TO_RAD);

        if (tileY % 2 == 0) _matrix.translate(matX, 0);
        matX = _matrix.c * baseFrame.frame.width;
        
        super.drawTile(tileX, tileY, tileFrame, baseFrame, bitmap, tilePos);
        _matrix.copyFrom(tempMatrix);
    }
}