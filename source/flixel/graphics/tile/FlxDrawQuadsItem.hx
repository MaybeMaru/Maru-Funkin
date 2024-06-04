package flixel.graphics.tile;

import openfl.display.Graphics;
#if FLX_DRAW_QUADS
import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import openfl.Vector;

@:unreflective
class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
{
	static inline var VERTICES_PER_QUAD = 4;

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
		alphas.clear();
		if (colored)
		{
			colorMultipliers.clear();
			colorOffsets.clear();
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

	override inline function set_colored(value:Bool) {
		if (value) if (colorMultipliers == null) {
			colorMultipliers = [];
			colorOffsets = [];
		}
		return colored = value;
	}

	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		rects.push(frame.frame.x);
		rects.push(frame.frame.y);
		rects.push(frame.frame.width);
		rects.push(frame.frame.height);

		transforms.push(matrix.a);
		transforms.push(matrix.b);
		transforms.push(matrix.c);
		transforms.push(matrix.d);
		transforms.push(matrix.tx);
		transforms.push(matrix.ty);

		final alphaMultiplier = transform != null ? transform.alphaMultiplier : 1.0;
		for (i in 0...VERTICES_PER_QUAD)
			alphas.push(alphaMultiplier);

		if (colored)
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
	}

	#if !flash
	override public function render(camera:FlxCamera):Void
	{
		if (#if cpp untyped __cpp__('this->rects->_hx___array->length == 0') #else rects.length == 0 #end)
			return;

		if (shader == null)
		{
			shader = graphics.shader;
			if (shader == null)
				return;
		}

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

		setParameterValue(shader.hasColorTransform, colored);
		drawFlxQuad(camera.canvas.graphics, shader, rects, transforms);
		
		#if FLX_DEBUG
		FlxDrawBaseItem.drawCalls++;
		#end
	}

	// Copy pasted from openfl Graphics, made SPECIFICALLY to work with funkin draw quads

	private static final bounds:Rectangle = new Rectangle(0, 0, 1280, 720);

	function drawFlxQuad(graphics:Graphics, shader:FlxShader, rects:Vector<Float>, transforms:Vector<Float>):Void @:privateAccess
	{
		// Override blend mode
		if (blend == null) blend = NORMAL;
		graphics.__commands.overrideBlendMode(blend);

		// Begin shader fill
		final shaderBuffer = graphics.__shaderBufferPool.get();
		graphics.__usedShaderBuffers.add(shaderBuffer);
		shaderBuffer.update(cast shader);
		graphics.__commands.beginShaderFill(shaderBuffer);

		// Draw the quad
		if (graphics.__bounds == null)
		{
			graphics.__bounds = bounds;
			graphics.__transformDirty = true;
		}

		graphics.__commands.drawQuads(rects, null, transforms);

		graphics.__dirty = true;
		graphics.__visible = true;
	}
	#end

	override inline function get_numVertices():Int
	{
		return VERTICES_PER_QUAD;
	}

	override inline function get_numTriangles():Int
	{
		return 2;
	}
}
#end