package funkin.util;

/*
 	Normal FlxColor doesnt work in Hscript sooooooo yeah
*/
class FlxColorFix {
    	//	Variables
	public static var TRANSPARENT:FlxColor = 0x00000000;
	public static var WHITE:FlxColor = 0xFFFFFFFF;
	public static var GRAY:FlxColor = 0xFF808080;
	public static var BLACK:FlxColor = 0xFF000000;

	public static var GREEN:FlxColor = 0xFF008000;
	public static var LIME:FlxColor = 0xFF00FF00;
	public static var YELLOW:FlxColor = 0xFFFFFF00;
	public static var ORANGE:FlxColor = 0xFFFFA500;
	public static var RED:FlxColor = 0xFFFF0000;
	public static var PURPLE:FlxColor = 0xFF800080;
	public static var BLUE:FlxColor = 0xFF0000FF;
	public static var BROWN:FlxColor = 0xFF8B4513;
	public static var PINK:FlxColor = 0xFFFFC0CB;
	public static var MAGENTA:FlxColor = 0xFFFF00FF;
	public static var CYAN:FlxColor = 0xFF00FFFF;

    	//	Functions
    public static function fromString(str:String):FlxColor {
		return FlxColor.fromString(str);
	}
    public static function fromRGB(red:Int, green:Int, blue:Int, alpha:Int = 255):FlxColor {
		return FlxColor.fromRGB(red,green,blue,alpha);
	}
	public static function interpolate(color1:Int, color2:Int, factor:Float = 0.5, elpInterp:Bool = true):FlxColor {
		return FlxColor.interpolate(color1,color2, elpInterp ? CoolUtil.getLerp(factor) : factor);
	}
}