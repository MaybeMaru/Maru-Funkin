package funkin.objects.alphabet;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFrame;

typedef AlphabetFontJson = {
	letters:Array<LetterData>
}

typedef LetterData =
{
	id:String, // character id
	?name:String, // prefix
	?upperOffset:Float, // uppercase
	?lowerOffset:Float, // lowercase
	?boldOffset:Float // bold
}

class AlphabetFont extends FlxBitmapFont
{
	public static var cachedAlphabets:Map<String, Array<AlphabetFont>> = [];

	public var animFrames:Array<Map<Int, FlxFrame>> = [];

	public static function getFont(bold:Bool):AlphabetFont
	{
		var key = Paths.png("alphabet");

		if (!cachedAlphabets.exists(key)) {
			cachedAlphabets.set(key, []);
			for (i in 0...2) {
				var cachedFont = new AlphabetFont(key, i == 0);
				cachedAlphabets.get(key).push(cachedFont);
			}
		}

		return cachedAlphabets.get(key)[bold ? 0 :  1];
	}

	public var lodScale:Float;

	// TODO: make this not forced to be sparrow atlas

	public function new(key:String, bold:Bool)
	{
		var graphic:LodGraphic = AssetManager.cacheGraphicPath(key);
		var xml = CoolUtil.getFileContent(key.replace(".png", ".xml"));
		var atlas = Paths.__checkLodFrames(Paths.getFrames(graphic, () -> return FlxAtlasFrames.fromSparrow(graphic, xml)));

		var rawFont = CoolUtil.getFileContent(key.replace(".png", "-font.json"));
		var font:AlphabetFontJson = Json.parse(rawFont);

		AssetManager.getAsset(key).onDispose = () -> {
			cachedAlphabets.remove(key);
		}

		lodScale = graphic.lodScale;

		super(graphic.imageFrame.frame);

		for (data in font.letters)
		{
			var id = data.id;
			var upperCode = id.toUpperCase().charCodeAt(0);
			var code = id.charCodeAt(0);

			var name:String = id;
			var boldOffset:Float = 0;
			var lowerOffset:Float = 0;
			var upperOffset:Float = 0;

			if (data != null)
			{
				if (data.name != null)
					name = data.name;

				if (data.boldOffset != null)
					boldOffset = data.boldOffset / lodScale;

				if (data.lowerOffset != null)
					lowerOffset = data.lowerOffset / lodScale;

				if (data.upperOffset != null)
					upperOffset = data.upperOffset / lodScale;
			}

			if (bold) // Bold
			{
				var boldFrames = atlas.getAllByPrefix('$name bold');
				if (boldFrames.length > 0)
				{
					var frame = boldFrames[0].frame.copyTo(FlxRect.get());
					setCharFrame(upperCode, frame, cast frame.width, FlxPoint.get(0, boldOffset));
					pushFrames(upperCode, boldFrames);
				}
			}
			else // Normal
			{
				if (code == upperCode) // Symbol
				{
					var symbolFrames = atlas.getAllByPrefix('$name normal');
					if (symbolFrames.length > 0)
					{
						var frame = symbolFrames[0].frame.copyTo(FlxRect.get());
						setCharFrame(code, frame, cast frame.width, FlxPoint.get(0, lowerOffset));
						pushFrames(code, symbolFrames);
					}
				}
				else // Normal character
				{
					var lowerFrames = atlas.getAllByPrefix('$name lowercase');
					if (lowerFrames.length > 0)
					{
						var frame = lowerFrames[0].frame.copyTo(FlxRect.get());
						setCharFrame(code, frame, cast frame.width, FlxPoint.get(0, lowerOffset));
						pushFrames(code, lowerFrames);
					}

					var upperFrames = atlas.getAllByPrefix('$name uppercase');
					if (upperFrames.length > 0)
					{
						var frame = upperFrames[0].frame.copyTo(FlxRect.get());
						setCharFrame(upperCode, frame, cast frame.width, FlxPoint.get(0, upperOffset));
						pushFrames(upperCode, upperFrames);
					}
				}
			}
		}

		lineHeight = Std.int((bold ? 75 : 60) / lodScale);
		spaceWidth = Std.int(20 / lodScale);
		this.bold = bold;
		updateSourceHeight();

		charMap = animFrames[0];
	}

	function pushFrames(code:Int, frames:Array<FlxFrame>)
	{
		for (i in 0...frames.length)
		{
			if (animFrames[i] == null)
				animFrames.push([]);

			var setFrame = frames[i];
			var baseFrame = charMap.get(code);

			setFrame.sourceSize.copyFrom(baseFrame.sourceSize);
			setFrame.offset.addPoint(baseFrame.offset);
			setFrame.cacheFrameMatrix();

			animFrames[i].set(code, setFrame);
		}
	}
}
