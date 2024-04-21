package funkin.objects.alphabet;

import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxFrame;

class Alphabet extends FlxBitmapText
{
	var alphabetFont:AlphabetFont;

	public function new(x:Float = 0, y:Float = 0, text:String = "", bold:Bool = true)
	{
		alphabetFont = AlphabetFont.getFont(bold);
		super(x, y, text, alphabetFont);
		
		scale.set(alphabetFont.lodScale, alphabetFont.lodScale);
		autoUpperCase = bold;

		drawMap = alphabetFont.animFrames[curFrame];
	}

	var drawMap:Map<Int, FlxFrame>;

	override function draw():Void
	{
		alphabetFont.charMap = drawMap;
		super.draw();
	}

	var curFrame:Int = 0;
	var framerate:Float = 24.0;
	var animElapsed:Float = 0.0;

	override function update(elapsed:Float)
	{
		animElapsed += elapsed;
		if (animElapsed >= (1 / framerate))
		{
			animElapsed = 0;
			curFrame = (curFrame + 1) % alphabetFont.animFrames.length;
			drawMap = alphabetFont.animFrames[curFrame];
		}

		super.update(elapsed);
	}
}