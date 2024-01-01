package funkin.objects;

import flixel.graphics.tile.FlxDrawBaseItem;
import openfl.display.BlendMode;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMatrix;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxFrame;
import openfl.geom.ColorTransform;

using flixel.util.FlxColorTransformUtil;

class FunkCamera extends FlxCamera {    
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