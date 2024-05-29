package funkin.util;

import flixel.math.FlxMatrix;

class FunkMath
{
    public static inline var PI:Float = 3.14159265358979323846;
	public static inline var DOUBLE_PI:Float = PI * 2;
	public static inline var TO_RADS:Float = PI / 180;
	public static inline var TO_DEGREES:Float = 180 / PI;

	public static inline function isZero(value:Float):Bool {
		return Math.abs(value) < 0.0001;
	}

    public static inline function sin(radians:Float):Float {
		return #if FAST_MATH FlxMath.fastSin(radians); #else Math.sin(radians); #end
	}

	public static inline function cos(radians:Float):Float {
		return #if FAST_MATH FlxMath.fastCos(radians); #else Math.cos(radians); #end
	}

	public static inline function sinAngle(angle:Float):Float {
		return sin(angle * TO_RADS);
	}

	public static inline function cosAngle(angle:Float):Float {
		return cos(angle * TO_RADS);
	}

    public static function fastRotatedRect(rect:FlxRect, ?origin:FlxPoint, degrees:Float):FlxRect
    {
        degrees = (degrees % 360);
        if (degrees == 0)
            return rect;
        
        if (degrees < 0)
			degrees += 360;
        
        var rads = (degrees * TO_RADS);
        return fastRotatedTrigRect(rect, origin, cos(rads), sin(rads));
    }

    public static function fastRotatedTrigRect(rect:FlxRect, ?origin:FlxPoint, cos:Float, sin:Float):FlxRect
    {
		if (cos == 1) if (sin == 0) // Rect is at angle 0, no need to calculate
			return rect;

		var originX:Float;
        var originY:Float;

        if (origin == null)
        {
            originX = 0;
            originY = 0;
        }
        else
        {
            originX = origin.x;
            originY = origin.y;
            origin.putWeak();
        }
        
        final left = -originX;
		final top = -originY;
		final right = -originX + rect.width;
		final bottom = -originY + rect.height;

		if (cos > 0 && sin >= 0)
		{
			rect.x = rect.x + originX + cos * left - sin * bottom;
			rect.y = rect.y + originY + sin * left + cos * top;
		}
		else if (cos < 0 && sin >= 0)
		{
			rect.x = rect.x + originX + cos * right - sin * bottom;
			rect.y = rect.y + originY + sin * left + cos * bottom;
		}
		else if (cos < 0 && sin < 0)
		{
			rect.x = rect.x + originX + cos * right - sin * top;
			rect.y = rect.y + originY + sin * right + cos * bottom;
		}
		else
		{
			rect.x = rect.x + originX + cos * left - sin * top;
			rect.y = rect.y + originY + sin * right + cos * top;
		}

		final newHeight = Math.abs(cos * rect.height) + Math.abs(sin * rect.width);
		rect.width = Math.abs(cos * rect.width) + Math.abs(sin * rect.height);
		rect.height = newHeight;
        
        return rect;
    }

	public static inline function scaleMatrix(mat:FlxMatrix, sx:Float, sy:Float):Void
	{
		if (sx != 1) {
			mat.a = (mat.a * sx);
			mat.c = (mat.c * sx);
			mat.tx = (mat.tx * sx);
		}

		if (sy != 1) {
			mat.b = (mat.b * sy);
			mat.d = (mat.d * sy);
			mat.ty = (mat.ty * sy);
		}
	}
}