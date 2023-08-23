package funkin.graphics;

/*
	Quick FlxText with the prebuilt shit
 */
class FunkinText extends FlxText
{
	public function new(x:Float = 0, y:Float = 0, text:String = '', size:Int = 20, width:Float = 0, alignment:String = 'left')
	{
		super(x, y, width, text, size);
		setFormat(Paths.font('vcr'), size, FlxColor.WHITE, alignment.toLowerCase().trim(), OUTLINE, FlxColor.BLACK);
		borderSize = 2;
		scrollFactor.set();
	}
}
