package funkin.util.frontend;

/*
 	Normal FlxColor doesnt work in Hscript sooooooo yeah
*/
class FlxColorFix {
	public static inline var TRANSPARENT:FlxColor = 0x00000000;
	public static inline var WHITE:FlxColor = 0xFFFFFFFF;
	public static inline var GRAY:FlxColor = 0xFF808080;
	public static inline var BLACK:FlxColor = 0xFF000000;

	public static inline var GREEN:FlxColor = 0xFF008000;
	public static inline var LIME:FlxColor = 0xFF00FF00;
	public static inline var YELLOW:FlxColor = 0xFFFFFF00;
	public static inline var ORANGE:FlxColor = 0xFFFFA500;
	public static inline var RED:FlxColor = 0xFFFF0000;
	public static inline var PURPLE:FlxColor = 0xFF800080;
	public static inline var BLUE:FlxColor = 0xFF0000FF;
	public static inline var BROWN:FlxColor = 0xFF8B4513;
	public static inline var PINK:FlxColor = 0xFFFFC0CB;
	public static inline var MAGENTA:FlxColor = 0xFFFF00FF;
	public static inline var CYAN:FlxColor = 0xFF00FFFF;

	// Taken (stolen) from Psych :3
	inline public static function fromString(color:String):FlxColor {
		final hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum ?? FlxColor.WHITE;
	}

    public static function fromRGB(red:Int, green:Int, blue:Int, alpha:Int = 255):FlxColor {
		return FlxColor.fromRGB(red,green,blue,alpha);
	}

	public static function interpolate(color1:Int, color2:Int, factor:Float = 0.5, fpsLerp:Bool = false):FlxColor {
		return FlxColor.interpolate(color1,color2, fpsLerp ? CoolUtil.getLerp(factor) : factor);
	}

	public static function fromInt(value:Int):FlxColor {
		return FlxColor.fromInt(value);
	}

	public var R:Float = 0;
	public var G:Float = 0;
	public var B:Float = 0;
	public var A:Float = 0;

	public function new(R:Float = 255,G:Float = 255,B:Float = 255,A:Float = 255) {
		set(R,G,B,A);
	}

	public static inline function fromFlxColor(color:FlxColor) {
		return new FlxColorFix(color.red,color.green,color.blue,color.alpha);
	}

	public function set(R:Float = 255,G:Float = 255,B:Float = 255,A:Float = 255) {
		this.R = R;
		this.G = G;
		this.B = B;
		this.A = A;
	}
	
	public inline function get():FlxColor {
		return FlxColor.fromRGB(Std.int(R),Std.int(G),Std.int(B),Std.int(A));
	}

	public function lerp(target:FlxColor, factor:Float = 0.5, fpsLerp:Bool = false):FlxColor {
		var lerpVal = fpsLerp ? CoolUtil.getLerp(factor) : factor;
		R = FlxMath.lerp(R, target.red, lerpVal);
		G = FlxMath.lerp(G, target.green, lerpVal);
		B = FlxMath.lerp(B, target.blue, lerpVal);
		return get();
	}

	public static inline function toRGBA(color:FlxColor) {
		return [(color >> 16 & 0xFF), (color >> 8 & 0xFF), (color & 0xFF), (color & 0xFF) << 24, ((color & 0xFF) << 24)];
	}
	
	public static inline function toRGBAFloat(color:FlxColor) {
		return [(color >> 16 & 0xFF) / 255, (color >> 8 & 0xFF) / 255, (color & 0xFF) / 255, ((color & 0xFF) << 24) / 255];
	}
}