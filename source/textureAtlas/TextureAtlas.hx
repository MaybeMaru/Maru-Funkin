package textureAtlas;

import textureAtlas.data.AnimationData;
import textureAtlas.data.SpriteMapData;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
import openfl.utils.Assets;

class TextureAtlas extends FlxAtlasFrames
{
	public static function fromAtlas(Path:String)
	{
		var frames = new TextureAtlas(null);
		var limbs = fromTextureAtlas(Path);
		if (limbs == null)
			return null;

		if (!Paths.exists('$Path/Animation.json', TEXT))
			return null;
		var animFile:AnimAtlas = haxe.Json.parse(CoolUtil.getFileContent('$Path/Animation.json'));

		var stageInstance:StageInstance = animFile.AN.STI;
		if (stageInstance == null)
		{
			stageInstance = cast {
				"SI": {
					"SN": animFile.AN.SN,
					"IN": "",
					"ST": "G",
					"FF": 0,
					"LP": "LP",
					"TRP": {
						"x": 0,
						"y": 0
					},
					"M3D": [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
				}
			}
		}
		var dictionary = animFile.SD.S;
		dictionary.push({SN: animFile.AN.SN, TL: animFile.AN.TL});
		var i = 0;
		while (true)
		{
			stageInstance.SI.FF += i;
			var symbol = symbolise(limbs, dictionary, stageInstance.SI);
			if (symbol == null)
				break;
			var rect = new Rectangle();
			@:privateAccess
			symbol.__getFilterBounds(rect, new FlxMatrix());
			var bitmap = new BitmapData(cast rect.width, cast rect.height, 0);
			bitmap.draw(symbol, new FlxMatrix(1, 0, 0, 1, -rect.x, -rect.y));
			@:privateAccess
			var frame = new FlxFrame(FlxGraphic.fromBitmapData(bitmap));
			frame.name = '${animFile.AN.SN}${Std.string(10000 + i).substring(1)}';
			frame.frame = new FlxRect(0, 0, bitmap.width, bitmap.height);
			frame.offset.set(rect.x, rect.y);
			frames.pushFrame(frame);
			stageInstance.SI.FF -= i;
			i++;
		}

		return frames;
	}

	private static function symbolise(limbs:TextureAtlas, dictionary:Array<SymbolData>, symbol:SymbolInstance):Sprite
	{
		var sprite = new Sprite();
		sprite.transform.colorTransform = AnimationData.parseColorEffect(AnimationData.fromColorJson(symbol.C));
		sprite.transform.matrix = new FlxMatrix(symbol.M3D[0], symbol.M3D[1], symbol.M3D[4], symbol.M3D[5], symbol.M3D[12], symbol.M3D[13]);
		sprite.filters = AnimationData.fromFilterJson(symbol.F);
		sprite.name = symbol.SN;
		var l = dictionary.filter((f) -> f.SN == symbol.SN)[0].TL.L;

		for (layer in l)
		{
			var sprLayer = new Sprite();
			sprLayer.name = layer.LN;
			sprLayer.mask = sprite.getChildByName(layer.Clpb);
			var frame:Frame = null;
			for (fr in layer.FR)
			{
				if (symbol.FF < fr.I + fr.DU)
				{
					frame = fr;
					break;
				}
			}
			if (frame == null)
				continue;

			sprLayer.transform.colorTransform = AnimationData.parseColorEffect(AnimationData.fromColorJson(frame.C));
			for (element in frame.E)
			{
				if (element.SI != null)
				{
					var symbol = symbolise(limbs, dictionary, element.SI);

					(symbol != null) ? sprLayer.addChild(symbol) : continue;
				}
				else
				{
					var limb = limbs.getByName(element.ASI.N);

					sprLayer.graphics.beginBitmapFill(limb.parent.bitmap);
					sprLayer.graphics.drawRect(limb.frame.x, limb.frame.y, limb.frame.width, limb.frame.height);
					sprLayer.graphics.endFill();
				}
			}
			sprite.addChildAt(sprLayer, 0);
		}
		@:privateAccess
		if (sprite.__children.length == 0)
			return null;

		return sprite;
	}

	private static function fromTextureAtlas(Path:String):TextureAtlas
	{
		var frames:TextureAtlas = new TextureAtlas(null);
		if (Paths.exists('$Path/spritemap.json', TEXT))
		{
			var curJson:AnimateAtlas = haxe.Json.parse(StringTools.replace(CoolUtil.getFileContent('$Path/spritemap.json'), String.fromCharCode(0xFEFF), ""));
			var curSpritemap = Paths.getRawBitmap('$Path/${curJson.meta.image}');
			if (curSpritemap != null)
			{
				var graphic = FlxG.bitmap.add(curSpritemap);
				var spritemapFrames = FlxAtlasFrames.findFrame(graphic);
				if (spritemapFrames == null)
				{
					spritemapFrames = new TextureAtlas(null);
					for (curSprite in curJson.ATLAS.SPRITES)
					{
						spritemapFrames.pushFrame(textureAtlasHelper(graphic.bitmap, curSprite.SPRITE, curJson.meta));
					}
				}
				graphic.addFrameCollection(spritemapFrames);
				frames._concat(spritemapFrames);
			}
			else
				FlxG.log.error('the image called "${curJson.meta.image}" does not exist in Path $Path, maybe you changed the image Path somewhere else?');
		}
		var i = 1;
		while (Paths.exists('$Path/spritemap$i.json', TEXT))
		{
			var curJson:AnimateAtlas = haxe.Json.parse(StringTools.replace(CoolUtil.getFileContent('$Path/spritemap$i.json'), String.fromCharCode(0xFEFF), ""));
			var curSpritemap = Paths.getRawBitmap('$Path/${curJson.meta.image}');
			if (curSpritemap != null)
			{
				var graphic = FlxG.bitmap.add(curSpritemap);
				var spritemapFrames = FlxAtlasFrames.findFrame(graphic);
				if (spritemapFrames == null)
				{
					spritemapFrames = new TextureAtlas(null);
					for (curSprite in curJson.ATLAS.SPRITES)
					{
						spritemapFrames.pushFrame(textureAtlasHelper(graphic.bitmap, curSprite.SPRITE, curJson.meta));
					}
				}
				graphic.addFrameCollection(spritemapFrames);
				frames._concat(spritemapFrames);
			}
			else
				FlxG.log.error('the image called "${curJson.meta.image}" does not exist in Path $Path, maybe you changed the image Path somewhere else?');
			i++;
		}
		if (frames.frames == [])
		{
			FlxG.log.error("the Frames parsing couldn't parse any of the frames, it's completely empty! \n Maybe you misspelled the Path?");
			return null;
		}
		return frames;
	}

	function _concat(frames:FlxFramesCollection)
	{
		for (frame in frames.frames)
			pushFrame(frame);
	}

	static function textureAtlasHelper(SpriteMap:BitmapData, limb:AnimateSpriteData, curMeta:Meta)
	{
		var width = (limb.rotated) ? limb.h : limb.w;
		var height = (limb.rotated) ? limb.w : limb.h;
		var sprite = new BitmapData(width, height, true, 0);
		var matrix = new FlxMatrix(1, 0, 0, 1, -limb.x, -limb.y);
		if (limb.rotated)
		{
			matrix.rotateByNegative90();
			matrix.translate(0, height);
		}
		sprite.draw(SpriteMap, matrix);

		@:privateAccess
		var curFrame = new FlxFrame(FlxG.bitmap.add(sprite));
		curFrame.name = limb.name;
		curFrame.sourceSize.set(width, height);
		curFrame.frame = new FlxRect(0, 0, width, height);
		return curFrame;
	}
}
