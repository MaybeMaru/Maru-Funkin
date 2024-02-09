package flixel.graphics.tile;

import openfl.display.BlendMode;
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
	var alphas:Array<Float>;
	var colorMultipliers:Array<Float>;
	var colorOffsets:Array<Float>;

	public function new()
	{
		super();
		type = FlxDrawItemType.TILES;
		rects = new Vector<Float>();
		transforms = new Vector<Float>();
		alphas = [];
	}

	override public function reset():Void
	{
		super.reset();
		rects.length = 0;
		transforms.length = 0;
		alphas.splice(0, alphas.length);
		if (colorMultipliers != null)
		{
			colorMultipliers.splice(0, colorMultipliers.length);
			colorOffsets.splice(0, colorOffsets.length);
		}
	}

	override public function dispose():Void
	{
		super.dispose();
		rects = null;
		transforms = null;
		alphas = null;
		colorMultipliers = null;
		colorOffsets = null;
	}

	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var rect = frame.frame;
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

		var alphaMultiplier = transform != null ? transform.alphaMultiplier : 1.0;
		for (i in 0...VERTICES_PER_QUAD)
			alphas.push(alphaMultiplier);

		if (colored || hasColorOffsets)
		{
			if (colorMultipliers == null)
			{
				colorMultipliers = [];
				colorOffsets = [];
			}

			if (transform != null)
			{
				for (i in 0...VERTICES_PER_QUAD)
				{
					colorMultipliers.push(transform.redMultiplier);
					colorMultipliers.push(transform.greenMultiplier);
					colorMultipliers.push(transform.blueMultiplier);
					colorMultipliers.push(1);

					colorOffsets.push(transform.redOffset);
					colorOffsets.push(transform.greenOffset);
					colorOffsets.push(transform.blueOffset);
					colorOffsets.push(transform.alphaOffset);
				}
			}
			else
			{
				for (i in 0...VERTICES_PER_QUAD)
				{
					colorMultipliers.push(1);
					colorMultipliers.push(1);
					colorMultipliers.push(1);
					colorMultipliers.push(1);

					colorOffsets.push(0);
					colorOffsets.push(0);
					colorOffsets.push(0);
					colorOffsets.push(0);
				}
			}
		}
	}

	#if !flash
	override public function render(camera:FlxCamera):Void
	{
		if (rects.length == 0)
			return;

		final shader = shader != null ? shader : graphics.shader;
		if (shader == null)
			return;

		shader.bitmap.input = graphics.bitmap;
		shader.bitmap.filter = (camera.antialiasing || antialiasing) ? LINEAR : NEAREST;
		shader.alpha.value = alphas;

		final hasColors = colored || hasColorOffsets;
		if (hasColors)
		{
			shader.colorMultiplier.value = colorMultipliers;
			shader.colorOffset.value = colorOffsets;
		}

		setParameterValue(shader.hasTransform, true);
		setParameterValue(shader.hasColorTransform, hasColors);
		drawFlxQuad(camera.canvas.graphics, blend, shader, rects, transforms);
		
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

	// Copy pasted from openfl Graphics, just inlines some stuff and removes indices since flixel quads dont need those

	inline function drawFlxQuad(graphics:Graphics, blendMode:BlendMode, shader:FlxShader, rects:Vector<Float>, transforms:Vector<Float>) @:privateAccess
	{
		final commands = graphics.__commands;

		// Override blend mode
		inline commands.overrideBlendMode(blendMode);

		// Begin shader fill
		final shaderBuffer = inline graphics.__shaderBufferPool.get();
		inline graphics.__usedShaderBuffers.add(shaderBuffer);
		inline shaderBuffer.update(cast shader);
		inline commands.beginShaderFill(shaderBuffer);
		
		// Draw the quad
		var tileRect = CoolUtil.rectangle;
		var tileTransform = CoolUtil.matrix;

		var minX = Math.POSITIVE_INFINITY;
		var minY = minX;
		var maxX = Math.NEGATIVE_INFINITY;
		var maxY = maxX;

		tileRect.x = 0;
		tileRect.y = 0;
		tileRect.width = rects[6];
		tileRect.height = rects[7];

		if (tileRect.width > 0 && tileRect.height > 0)
		{
			tileTransform.a = transforms[6];
			tileTransform.b = transforms[7];
			tileTransform.c = transforms[8];
			tileTransform.d = transforms[9];
			tileTransform.tx = transforms[10];
			tileTransform.ty = transforms[11];

			inline tileRect.__transform(tileRect, tileTransform);
	
			if (minX > tileRect.x) minX = tileRect.x;
			if (minY > tileRect.y) minY = tileRect.y;
			if (maxX < tileRect.right) maxX = tileRect.right;
			if (maxY < tileRect.bottom) maxY = tileRect.bottom;
		}

		inline graphics.__inflateBounds(minX, minY);
		inline graphics.__inflateBounds(maxX, maxY);

		inline commands.drawQuads(rects, null, transforms);

		graphics.__dirty = true;
		graphics.__visible = true;
	}
	#end
}
#end
