package flixel.graphics.tile;

import openfl.geom.Matrix;
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

		if (colored)
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

		if (shader == null)
			shader = graphics.shader;

		if (shader == null)
			return;

		shader.bitmap.input = graphics.bitmap;
		shader.alpha.value = alphas;

		if (antialiasing) 		shader.bitmap.filter = LINEAR;
		//else if (camera.antialiasing) 	shader.bitmap.filter = LINEAR; not used in funkin lol
		else 				shader.bitmap.filter = NEAREST;

		if (colored)
		{
			shader.colorMultiplier.value = colorMultipliers;
			shader.colorOffset.value = colorOffsets;
		}

		if (blend == null)
			blend = NORMAL;

		setParameterValue(shader.hasTransform, true);
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

	// Copy pasted from openfl Graphics, just inlines some stuff and removes indices since flixel quads dont need those
	
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
		var tileRect = CoolUtil.rectangle;

		var minX = Math.POSITIVE_INFINITY;
		var minY = minX;
		var maxX = Math.NEGATIVE_INFINITY;
		var maxY = maxX;

		tileRect.width = rects[6];
		tileRect.height = rects[7];

		if (tileRect.width > 0) if (tileRect.height > 0)
		{
			var tileMatrix = CoolUtil.matrix;

			tileMatrix.a = transforms[6];
			tileMatrix.b = transforms[7];
			tileMatrix.c = transforms[8];
			tileMatrix.d = transforms[9];
			tileMatrix.tx = transforms[10];
			tileMatrix.ty = transforms[11];

			__transformRect(tileRect, tileMatrix);
	
			if (minX > tileRect.x) minX = tileRect.x;
			if (minY > tileRect.y) minY = tileRect.y;
			
			var right = tileRect.right;
			if (maxX < right) maxX = right;
			
			var bottom = tileRect.bottom;
			if (maxY < bottom) maxY = bottom;
		}

		graphics.__inflateBounds(minX, minY);
		graphics.__inflateBounds(maxX, maxY);

		commands.drawQuads(rects, null, transforms);

		graphics.__dirty = true;
		graphics.__visible = true;
	}

	// In draw quads, the rect always starts with x and y at 0, so we can skip some calculations here
	function __transformRect(r:Rectangle, m:Matrix):Void
	{
		var w = r.width;
		var h = r.height;
		
		var tx1 = 0.0;
		var ty1 = 0.0;

		var tx = m.a * w;
		var ty = m.b * w;

		if (tx > tx1) tx1 = tx;
		if (ty > ty1) ty1 = ty;

		tx = m.a * w + m.c * h;
		ty = m.b * w + m.d * h;

		if (tx > tx1) tx1 = tx;
		if (ty > ty1) ty1 = ty;

		tx = m.c * h;
		ty = m.d * h;

		if (tx > tx1) tx1 = tx;
		if (ty > ty1) ty1 = ty;

		r.setTo(m.tx, m.ty, tx1, ty1);
	}
	#end
}
#end
