package funkin.graphics;

import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import openfl.display.BitmapData;

/*
    TODO:
    add skew y support (_matrix.b) and fix problems with dynamically sized tiles
    fix skew on angles other than 0 and 180 (Fr this shit fucking sucks)
*/

class FlxSkewRepeatSprite extends FlxRepeatSprite {
    static var idY:Int = -1;

    public var wigglePower:Float = 0.0;
    public var smoothTiles:Float = 1;
    public var calcHeight:Int = -1;

    static var scaledWiggleX:Float = 1.0;

    override function drawTile(tileX:Int, tileY:Int, tileFrame:FlxFrame, baseFrame:FlxFrame, bitmap:BitmapData, tilePos:FlxPoint) {
        if (wigglePower == 0) {
            super.drawTile(tileX, tileY, tileFrame, baseFrame, bitmap, tilePos);
            return;
        }

        idY = tileY;
        
        scaledWiggleX = wigglePower * (calcHeight != -1 ? calcHeight : baseFrame.frame.height) * scale.y * 0.01; // Value outta my ass but trust me bro
        scaledWiggleX /= smoothTiles;

        final lerpValue = ((idY % smoothTiles) + 1) / smoothTiles;
        final lerpWiggle = FlxMath.lerp(0, scaledWiggleX, lerpValue);

        final skewX = lerpWiggle * (isLeftSkew() ? -1 : 1);
        _matrix.c = Math.tan(skewX * CoolUtil.TO_RADS); // Set skew X

        if (clipRect == null) offsetSkew(tileFrame, baseFrame);
        super.drawTile(tileX, idY, tileFrame, baseFrame, bitmap, tilePos);
    }

    inline function isLeftSkew():Bool {
        return (idY % (smoothTiles * 2)) < smoothTiles;
    }

    static var xOff:Float = 0.0;

    inline function offsetSkew(tileFrame:FlxFrame, baseFrame:FlxFrame) {
        final percId = idY % (smoothTiles * 2);
        tileOffset.set();

        if (percId == 0)    xOff = 0;
        else                xOff -= _matrix.c * baseFrame.frame.width;

        // TODO: This is more or less accurate but still isnt perfect, figure out better math you dumb cunt
        var multX:Float = 1.0;
        if (tileFrame.frame.height != baseFrame.frame.height) {
            multX = tileFrame.frame.height / baseFrame.frame.height;
            if (isLeftSkew())
                tileOffset.x -= _matrix.c * baseFrame.frame.width * (1 - multX);
        }

        tileOffset.x += xOff * multX;
        tileOffset.x *= -_cosAngle;
    }

    override function handleClipRect(tileFrame:FlxFrame, baseFrame:FlxFrame, tilePos:FlxPoint):Bool {
        final _draw = super.handleClipRect(tileFrame, baseFrame, tilePos);
        if (_draw && wigglePower != 0) offsetSkew(tileFrame, baseFrame);
        return _draw;
    }
}