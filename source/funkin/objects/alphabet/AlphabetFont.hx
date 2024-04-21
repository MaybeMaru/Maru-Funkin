package funkin.objects.alphabet;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFrame;

typedef LetterData =
{
	?name:String, // prefix
	?upperOffset:Float, // uppercase
	?lowerOffset:Float, // lowercase
	?boldOffset:Float // bold
}

class AlphabetFont extends FlxBitmapFont
{
	public static final characters:Map<String, LetterData> = [
		//  Alphabet
		"a" => {lowerOffset: 22},
		"b" => {boldOffset: -3, lowerOffset: 8},
		"c" => {boldOffset: 1, lowerOffset: 25, upperOffset: 1},
		"d" => {lowerOffset: 5, upperOffset: 2},
		"e" => {boldOffset: 1, lowerOffset: 21, upperOffset: 5},
		"f" => {lowerOffset: 10, upperOffset: 6},
		"g" => {boldOffset: -3, lowerOffset: 32, upperOffset: 2},
		"h" => {lowerOffset: 12, upperOffset: 5},
		"i" => {boldOffset: 1, lowerOffset: 15, upperOffset: 6},
		"j" => {boldOffset: -3, lowerOffset: 15, upperOffset: 4},
		"k" => {boldOffset: -3, lowerOffset: 10, upperOffset: 6},
		"l" => {lowerOffset: 10, upperOffset: 5},
		"m" => {boldOffset: 3, lowerOffset: 31, upperOffset: 8},
		"n" => {lowerOffset: 31, upperOffset: 8},
		"o" => {boldOffset: -3, lowerOffset: 27, upperOffset: 3},
		"p" => {boldOffset: -3, lowerOffset: 30, upperOffset: 7},
		"q" => {lowerOffset: 34, upperOffset: 6},
		"r" => {lowerOffset: 29, upperOffset: 3},
		"s" => {lowerOffset: 23, upperOffset: 3},
		"t" => {boldOffset: 1, lowerOffset: 10, upperOffset: 7},
		"u" => {boldOffset: 7, lowerOffset: 25, upperOffset: 8},
		"v" => {lowerOffset: 26, upperOffset: 9},
		"w" => {boldOffset: 3, lowerOffset: 27, upperOffset: 7},
		"x" => {lowerOffset: 25, upperOffset: 5},
		"y" => {boldOffset: -3, lowerOffset: 25, upperOffset: 5},
		"z" => {lowerOffset: 27, upperOffset: 10},
		//  Numbers
		"0" => {lowerOffset: 3},
		"1" => {lowerOffset: 4},
		"2" => {boldOffset: 2, lowerOffset: 5},
		"3" => {boldOffset: 1, lowerOffset: 2},
		"4" => {boldOffset: 2, lowerOffset: 3},
		"5" => {lowerOffset: 4},
		"6" => {lowerOffset: 4},
		"7" => {boldOffset: 3, lowerOffset: 8},
		"8" => {lowerOffset: 1},
		"9" => {lowerOffset: 1},
		//  Symbols
		"|" => null,
		"~" => null,
		"#" => null,
		"$" => null,
		"%" => null,
		"(" => null,
		")" => null,
		"*" => null,
		"+" => null,
		"-" => {boldOffset: 25},
		"_" => null,
		":" => {boldOffset: 10},
		";" => null,
		"<" => null,
		">" => null,
		// "=" => null,
		"@" => null,
		"[" => null,
		"]" => null,
		"^" => null,
		"." => {name: "period", boldOffset: 50, lowerOffset: 40},
		"," => {name: "comma", lowerOffset: 40},
		"'" => {name: "apostrophe"},
		"!" => {name: "exclamation", boldOffset: -10},
		"?" => {name: "question", boldOffset: -5},
		//  Spanish and Portuguese Characters
		"á" => {boldOffset: -33, lowerOffset: -5, upperOffset: -24},
		"é" => {boldOffset: -31, lowerOffset: -4, upperOffset: -20},
		"í" => {boldOffset: -32, lowerOffset: 5, upperOffset: -19},
		"ó" => {boldOffset: -33, lowerOffset: 2, upperOffset: -22},
		"ú" => {boldOffset: -27, lowerOffset: 1, upperOffset: -15},
		"â" => {boldOffset: -27, upperOffset: -20},
		"ê" => {boldOffset: -30, upperOffset: -19},
		"ô" => {boldOffset: -31, lowerOffset: 5, upperOffset: -18},
		"ã" => {boldOffset: -24, lowerOffset: 5, upperOffset: -18},
		"õ" => {boldOffset: -25, lowerOffset: 9, upperOffset: -15},
		"ï" => {boldOffset: -18, lowerOffset: 17, upperOffset: -10},
		"ü" => {boldOffset: -13, lowerOffset: 11, upperOffset: -4},
		"ñ" => {boldOffset: -22, lowerOffset: 10, upperOffset: -10},
		"ç" => {boldOffset: 2, lowerOffset: 26, upperOffset: 2}
	];

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

	public function new(key:String, bold:Bool)
	{
		var graphic:LodGraphic = AssetManager.cacheGraphicPath(key);
		var xml = CoolUtil.getFileContent(key.replace(".png", ".xml"));
		var atlas = Paths.__checkLodFrames(Paths.getFrames(graphic, () -> return FlxAtlasFrames.fromSparrow(graphic, xml)));

		AssetManager.getAsset(key).onDispose = () -> {
			cachedAlphabets.remove(key);
		}

		lodScale = graphic.lodScale;

		super(graphic.imageFrame.frame);

		for (key => data in characters)
		{
			var upperCode = key.toUpperCase().charCodeAt(0);
			var code = key.charCodeAt(0);

			var name:String = key;
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
