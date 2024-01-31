package funkin.util.backend;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.AtlasBase;
import flixel.graphics.atlas.TexturePackerAtlas;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import haxe.xml.Access;
import openfl.Assets;
import openfl.geom.Rectangle;

// Fix for lod graphics

class AtlasFrames extends FlxAtlasFrames
{
	public static function fromSparrow(source:FlxGraphicAsset, xml:FlxXmlAsset):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source);
		if (graphic == null)
			return null;
		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || xml == null)
			return null;

		frames = new AtlasFrames(graphic);

		var data:Access = new Access(xml.getXml().firstElement());

		for (texture in data.nodes.SubTexture)
		{
			var name = texture.att.name;
			var trimmed = texture.has.frameX;
			var rotated = (texture.has.rotated && texture.att.rotated == "true");
			var flipX = (texture.has.flipX && texture.att.flipX == "true");
			var flipY = (texture.has.flipY && texture.att.flipY == "true");

			var rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width),
				Std.parseFloat(texture.att.height));

			var size = if (trimmed)
			{
				new Rectangle(Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY), Std.parseInt(texture.att.frameWidth),
					Std.parseInt(texture.att.frameHeight));
			}
			else
			{
				new Rectangle(0, 0, rect.width, rect.height);
			}

			var angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;

			var offset = FlxPoint.get(-size.left, -size.top);
			var sourceSize = FlxPoint.get(size.width, size.height);

			if (rotated && !trimmed)
				sourceSize.set(size.height, size.width);
            
			frames.addAtlasFrame(rect, sourceSize, offset, name, angle, flipX, flipY);
		}

		return frames;
	}

    override function checkFrame(frame:FlxRect, ?name:String):FlxRect
	{
        var lodScale:Float = cast(parent, LodGraphic).lodScale;
        var lodWidth:Float = parent.width * lodScale;
        var lodHeight:Float = parent.height * lodScale;

		var x:Float = FlxMath.bound(frame.x, 0, lodWidth);
		var y:Float = FlxMath.bound(frame.y, 0, lodHeight);

		var r:Float = FlxMath.bound(frame.right, 0, lodWidth);
		var b:Float = FlxMath.bound(frame.bottom, 0, lodHeight);

		frame.set(x, y, r - x, b - y);

		if (frame.width <= 0 || frame.height <= 0)
			FlxG.log.warn("The frame " + name + " has incorrect data and results in an image with the size of (0, 0)");

		return frame;
	}
}