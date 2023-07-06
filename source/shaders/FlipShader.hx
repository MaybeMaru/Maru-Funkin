package shaders;

import flixel.system.FlxAssets.FlxShader;

class FlipShader
{
	public var shader(default, null):FlipXShader = new FlipXShader();
	
	public function new():Void
	{}
}

class FlipXShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		void main()
		{
		  	vec2 flippedTexCoords = vec2(1.0 - openfl_TextureCoordv.x, openfl_TextureCoordv.y);
		  	vec4 color = texture2D(bitmap, flippedTexCoords);
			gl_FragColor = color;
		}
	')
	
	public function new()
	{
		super();
	}
}
