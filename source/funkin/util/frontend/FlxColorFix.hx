package funkin.util.frontend;

/*
 	Normal FlxColor doesnt work in Hscript sooooooo yeah
*/
class FlxColorFix {
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

    public static function fromString(str:String):FlxColor {
		return FlxColor.fromString(str);
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

	public static inline function toRGBA (color:FlxColor) {
		return [(color >> 16 & 0xFF), (color >> 8 & 0xFF), (color & 0xFF), (color & 0xFF) << 24, ((color & 0xFF) << 24)];
	}
	
	public static inline function toRGBAFloat (color:FlxColor) {
		return [(color >> 16 & 0xFF) / 255, (color >> 8 & 0xFF) / 255, (color & 0xFF) / 255, ((color & 0xFF) << 24) / 255];
	}

	/*
	public static function hexToInt(hex:String):Int {
		if (hex.startsWith('0x')) {
			hex = hex.substr(2);
		}

		var rgb = [];
		while (hex.length > 0) {
			rgb.push(Std.parseInt('0x${hex.substr(0, 2)}'));
			hex = hex.substr(2);
		}
	
		var red = rgb.length > 0 ? rgb[0] : 0;
		var green = rgb.length > 1 ? rgb[1] : 0;
		var blue = rgb.length > 2 ? rgb[2] : 0;
	
		return (red << 16) | (green << 8) | blue;
	}
	*/
}