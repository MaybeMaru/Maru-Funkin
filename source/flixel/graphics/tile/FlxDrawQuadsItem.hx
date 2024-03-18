package flixel.graphics.tile;

import openfl.display.Graphics;
#if FLX_DRAW_QUADS
import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import openfl.display.ShaderParameter;
import openfl.Vector;

class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
{
	static inline var VERTICES_PER_QUAD = #if (openfl >= "8.5.0") 4 #else 6 #end;

	public var shader:FlxShader;

	var rects:Vector<Float>;
	var transforms:Vector<Float>;
	var alphas:FlxQuadVector;
	var colorMultipliers:FlxQuadVector;
	var colorOffsets:FlxQuadVector;

	public function new()
	{
		super();
		type = FlxDrawItemType.TILES;
		rects = new Vector<Float>();
		transforms = new Vector<Float>();
		alphas = new FlxQuadVector();
	}

	override public function reset():Void
	{
		super.reset();
		rects.length = 0;
		transforms.length = 0;
		alphas.reset();
		if (colored)
		{
			colorMultipliers.reset();
			colorOffsets.reset();
		}
	}

	override public function dispose():Void
	{
		super.dispose();
		rects = null;
		transforms = null;

		alphas.dispose();
		alphas = null;

		colorMultipliers.dispose();
		colorMultipliers = null;

		colorOffsets.dispose();
		colorOffsets = null;
	}

	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		final rect = frame.frame;
		rects.push(rect.x);
		rects.push(rect.y);
		rects.push(rect.width);
		rects.push(rect.height);

		transforms.push(matrix.a);
		transforms.push(matrix.b);
		transforms.push(matrix.c);
		transforms.push(matrix.d);
		transforms.push(matrix.tx);
		transforms.push(matrix.ty);

		alphas.push(transform == null ? 1.0 : transform.alphaMultiplier);

		if (colored)
		{
			if (colorMultipliers == null)
			{
				colorMultipliers = new FlxQuadVector();
				colorOffsets = new FlxQuadVector();
			}

			for (i in 0...VERTICES_PER_QUAD)
			{
				colorMultipliers.pushData(
					transform.redMultiplier,
					transform.greenMultiplier,
					transform.blueMultiplier,
					1.0
				);
				
				colorOffsets.pushData(
					transform.redOffset,
					transform.greenOffset,
					transform.blueOffset,
					transform.alphaOffset
				);
			}
		}
	}

	#if !flash
	override public function render(camera:FlxCamera):Void
	{
		if (rects.length == 0)
			return;

		if (shader == null)
			shader = graphics.shader;

		if (shader == null)
			return;

		shader.bitmap.input = graphics.bitmap;
		shader.alpha.value = alphas.toArray();

		if (antialiasing) 		shader.bitmap.filter = LINEAR;
		//else if (camera.antialiasing) 	shader.bitmap.filter = LINEAR; not used in funkin lol
		else 				shader.bitmap.filter = NEAREST;

		if (colored)
		{
			shader.colorMultiplier.value = colorMultipliers.toArray();
			shader.colorOffset.value = colorOffsets.toArray();
		}

		if (blend == null)
			blend = NORMAL;

		setParameterValue(shader.hasColorTransform, colored);
		drawFlxQuad(camera.canvas.graphics, cast blend, shader, rects, transforms);
		
		#if FLX_DEBUG
		FlxDrawBaseItem.drawCalls++;
		#end
	}

	inline function setParameterValue(parameter:ShaderParameter<Bool>, value:Bool):Void
	{
		if (parameter.value == null)
			parameter.value = [];
		parameter.value[0] = value;
	}

	// Copy pasted from openfl Graphics, made SPECIFICALLY to work with funkin draw quads

	private static final bounds:Rectangle = new Rectangle(0, 0, 1280, 720);

	function drawFlxQuad(graphics:Graphics, blendMode:Int, shader:FlxShader, rects:Vector<Float>, transforms:Vector<Float>):Void @:privateAccess
	{
		final commands = graphics.__commands;

		// Override blend mode
		commands.overrideBlendMode(cast blendMode);

		// Begin shader fill
		final shaderBuffer = graphics.__shaderBufferPool.get();
		graphics.__usedShaderBuffers.add(shaderBuffer);
		shaderBuffer.update(cast shader);
		commands.beginShaderFill(shaderBuffer);

		// Draw the quad
		if (graphics.__bounds == null)
		{
			graphics.__bounds = bounds;
			graphics.__transformDirty = true;
		}

		commands.drawQuads(rects, null, transforms);

		graphics.__dirty = true;
		graphics.__visible = true;
	}
	#end
}
#end
