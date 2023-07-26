package funkin.util;

import flixel.addons.display.FlxRuntimeShader;
import openfl.display.BitmapData;

class Shader
{
	public static var shaderMap:Map<String, FlxRuntimeShader> = [];
	inline public static var shaderToyFix:String = '
		//SHADERTOY PORT FIX
		#pragma header
		vec2 uv = openfl_TextureCoordv.xy;
		vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
		vec2 iResolution = openfl_TextureSize;
		uniform float iTime;
		#define iChannel0 bitmap
		#define texture flixel_texture2D
		#define fragColor gl_FragColor
		#define mainImage main
		//SHADERTOY PORT FIX';

	public static function initShader(shader:String, ?tag:String, force:Bool = false):Void
	{
		if (shaderMap.exists(shader) && !force)
			return;

		var frag:String = Paths.shader(shader);
		if (!Paths.exists(frag, TEXT))
			return;

		var txt = CoolUtil.getFileContent(frag);
		txt = !txt.startsWith('//SHADERTOY PORT FIX') ? '$shaderToyFix\n$txt' : txt;
		shaderMap.set(tag == null ? shader : tag, new FlxRuntimeShader(txt));
		trace('created shader $shader from $frag');
	}

	public static function getShader(shader:String):Null<FlxRuntimeShader>
	{
		initShader(shader);
		return shaderMap.get(shader);
	}

	// Doesnt work correctly yet

	/*public static function resetCameraCache(camera:FlxCamera)
		{
			var spr = camera.flashSprite;
			if (spr == null || spr.filters == null)
				return;
			@:privateAccess {
				spr.__cacheBitmap = null;
				spr.__cacheBitmapData = null;
			}
		}

		inline public static function setCameraShader(camera:FlxCamera, shader:String)
		{
			if (existsShader(shader))
			{
				resetCameraCache(camera);
				camera.setFilters([new ShaderFilter(getShader(shader))]);
			}
	}*/

	inline public static function copyShader(shader:String, tag:String)
	{
		if (existsShader(shader))
			shaderMap.set(tag, getShader(shader));
	}

	inline public static function setSpriteShader(sprite:FlxSprite, shader:String)
	{
		if (existsShader(shader))
			sprite.shader = getShader(shader);
	}

	inline public static function setInt(shader:String, prop:String, value:Int):Void
	{
		if (existsShader(shader))
			getShader(shader).setInt(prop, value);
	}

	public static function getInt(shader:String, prop:String):Int
	{
		if (existsShader(shader))
			return getShader(shader).getInt(prop);
		return 0;
	}

	inline public static function setFloat(shader:String, prop:String, value:Float):Void
	{
		if (existsShader(shader))
			getShader(shader).setFloat(prop, value);
	}

	/*public static function getFloat(shader:String, prop:String):Float
		{
			if (existsShader(shader))
				return getShader(shader).getFloat(prop);
			return 0;
		}

		public static function addFloat(shader:String, prop:String, value:Float)
		{
			if (existsShader(shader))
				setFloat(shader, prop, getFloat(shader, prop) + value);
	}*/
	inline public static function setBool(shader:String, prop:String, value:Bool):Void
	{
		if (existsShader(shader))
			getShader(shader).setBool(prop, value);
	}

	public static function getBool(shader:String, prop:String):Bool
	{
		if (existsShader(shader))
			return getShader(shader).getBool(prop);
		return false;
	}

	inline public static function setSampler2D(shader:String, prop:String, path:String, ?bitmap:BitmapData)
	{
		if (existsShader(shader)) {
			var asset = new FlxSprite().loadGraphic(Paths.image(path, null));
			getShader(shader).setSampler2D(prop, bitmap != null ? bitmap : asset.pixels);
		}

	}

	inline public static function existsShader(shader:String)
	{
		getShader(shader); // Checks for new shader
		return shaderMap.exists(shader);
	}
}
