package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.Graphics;
import openfl.display.TriangleCulling;
import openfl.geom.ColorTransform;

typedef DrawData<T> = openfl.Vector<T>;

/**
 * @author Zaphod
 */
 @:unreflective
class FlxDrawTrianglesItem extends FlxDrawBaseItem<FlxDrawTrianglesItem>
{
	static var point:FlxPoint = FlxPoint.get();
	static var rect:FlxRect = FlxRect.get();

	#if !flash
	public var shader:FlxShader;
	var alphas:Array<Float>;
	var colorMultipliers:Array<Float>;
	var colorOffsets:Array<Float>;
	#end

	public var vertices:DrawData<Float> = new DrawData<Float>();
	public var indices:DrawData<Int> = new DrawData<Int>();
	public var uvtData:DrawData<Float> = new DrawData<Float>();
	public var colors:DrawData<Int> = new DrawData<Int>();

	public var verticesPosition:Int = 0;
	public var indicesPosition:Int = 0;
	public var colorsPosition:Int = 0;

	var bounds:FlxRect = FlxRect.get();

	public function new()
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
		#if !flash
		alphas = [];
		#end
	}

	override public function render(camera:FlxCamera):Void
	{
		if (numTriangles <= 0)
			return;

		#if !flash
        if (shader == null)
		{
			shader = graphics.shader;
			if (shader == null)
				return;
		}

        shader.bitmap.input = graphics.bitmap;
		shader.alpha.value = alphas;
        shader.bitmap.wrap = REPEAT; // in order to prevent breaking tiling behaviour in classes that use drawTriangles

        if (antialiasing) 		shader.bitmap.filter = LINEAR;
		//else if (camera.antialiasing) 	shader.bitmap.filter = LINEAR; not used in funkin lol
		else 				shader.bitmap.filter = NEAREST;

		if (colored)
		{
			shader.colorMultiplier.value = colorMultipliers;
			shader.colorOffset.value = colorOffsets;
		}

        setParameterValue(shader.hasColorTransform, colored);
        drawFlxTriangle(camera.canvas.graphics);
        #else
        camera.canvas.graphics.beginBitmapFill(graphics.bitmap, null, true, (camera.antialiasing || antialiasing));
        #end

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			var gfx:Graphics = camera.debugLayer.graphics;
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(vertices, indices, uvtData);
		}

        FlxDrawBaseItem.drawCalls++;
		#end
	}

    #if !flash
    function drawFlxTriangle(graphics:Graphics):Void @:privateAccess
    {
		#if (openfl > "8.7.0")
        graphics.__commands.overrideBlendMode(blend ?? NORMAL);
		#end

		graphics.beginShaderFill(shader);

		graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.NONE);
		graphics.endFill();
    }
    #end

	override public function reset():Void
	{
		super.reset();
		vertices.length = 0;
		indices.length = 0;
		uvtData.length = 0;
		colors.length = 0;

		verticesPosition = 0;
		indicesPosition = 0;
		colorsPosition = 0;
		
		#if !flash
		alphas.clear();
        if (colored) {
            colorMultipliers.clear();
            colorOffsets.clear();
        }
		#end
	}

	override public function dispose():Void
	{
		super.dispose();

		vertices = null;
		indices = null;
		uvtData = null;
		colors = null;
		bounds = null;
		#if !flash
		alphas = null;
		colorMultipliers = null;
		colorOffsets = null;
		#end
	}

	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint,
			?cameraBounds:FlxRect #if !flash , ?transform:ColorTransform #end):Void
	{
		if (position == null)
			position = point.set();

		if (cameraBounds == null)
			cameraBounds = rect.set(0, 0, FlxG.width, FlxG.height);

		var verticesLength:Int = vertices.length;
		var prevVerticesLength:Int = this.vertices.length;
		var numberOfVertices:Int = Std.int(verticesLength / 2);
		var prevIndicesLength:Int = this.indices.length;
		var prevUVTDataLength:Int = this.uvtData.length;
		var prevColorsLength:Int = this.colors.length;
		var prevNumberOfVertices:Int = this.numVertices;

		var tempX:Float, tempY:Float;
		var i:Int = 0;
		var currentVertexPosition:Int = prevVerticesLength;

		while (i < verticesLength)
		{
			tempX = position.x + vertices[i];
			tempY = position.y + vertices[i + 1];

			this.vertices[currentVertexPosition++] = tempX;
			this.vertices[currentVertexPosition++] = tempY;

			if (i == 0)
			{
				bounds.set(tempX, tempY, 0, 0);
			}
			else
			{
				inflateBounds(bounds, tempX, tempY);
			}

			i += 2;
		}

		if (!cameraBounds.overlaps(bounds))
		{
			this.vertices.splice(this.vertices.length - verticesLength, verticesLength);
		}
		else
		{
			var uvtDataLength:Int = uvtData.length;
			for (i in 0...uvtDataLength)
			{
				this.uvtData[prevUVTDataLength + i] = uvtData[i];
			}

			var indicesLength:Int = indices.length;
			for (i in 0...indicesLength)
			{
				this.indices[prevIndicesLength + i] = indices[i] + prevNumberOfVertices;
			}

			if (colored)
			{
				for (i in 0...numberOfVertices)
				{
					this.colors[prevColorsLength + i] = colors[i];
				}

				colorsPosition += numberOfVertices;
			}

			verticesPosition += verticesLength;
			indicesPosition += indicesLength;
		}

		position.putWeak();
		cameraBounds.putWeak();

		#if !flash
		for (_ in 0...numTriangles)
		{
            if (transform != null)
            {
                alphas.push(transform.alphaMultiplier);
                alphas.push(transform.alphaMultiplier);
                alphas.push(transform.alphaMultiplier);
            }
            else
            {
                alphas.push(1.0);
                alphas.push(1.0);
                alphas.push(1.0);
            }
		}

		if (colored || hasColorOffsets)
		{
			if (colorMultipliers == null) {
				colorMultipliers = [];
                colorOffsets = [];
            }

			for (_ in 0...(numTriangles * 3))
			{
				if(transform != null)
				{
					colorMultipliers.push(transform.redMultiplier);
					colorMultipliers.push(transform.greenMultiplier);
					colorMultipliers.push(transform.blueMultiplier);

					colorOffsets.push(transform.redOffset);
					colorOffsets.push(transform.greenOffset);
					colorOffsets.push(transform.blueOffset);
					colorOffsets.push(transform.alphaOffset);
				}
				else
				{
					colorMultipliers.push(1);
					colorMultipliers.push(1);
					colorMultipliers.push(1);
	
					colorOffsets.push(0);
					colorOffsets.push(0);
					colorOffsets.push(0);
					colorOffsets.push(0);
				}

				colorMultipliers.push(1);
			}
		}
		#end
	}

	public static inline function inflateBounds(bounds:FlxRect, x:Float, y:Float):FlxRect
	{
		if (x < bounds.x)
		{
			bounds.width += bounds.x - x;
			bounds.x = x;
		}

		if (y < bounds.y)
		{
			bounds.height += bounds.y - y;
			bounds.y = y;
		}

		if (x > bounds.x + bounds.width)
		{
			bounds.width = x - bounds.x;
		}

		if (y > bounds.y + bounds.height)
		{
			bounds.height = y - bounds.y;
		}

		return bounds;
	}

	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var prevVerticesPos:Int = verticesPosition;
		var prevIndicesPos:Int = indicesPosition;
		var prevColorsPos:Int = colorsPosition;
		var prevNumberOfVertices:Int = numVertices;

		var point = FlxPoint.get();
		point.transform(matrix);

		vertices[prevVerticesPos] = point.x;
		vertices[prevVerticesPos + 1] = point.y;

		uvtData[prevVerticesPos] = frame.uv.x;
		uvtData[prevVerticesPos + 1] = frame.uv.y;

		point.set(frame.frame.width, 0);
		point.transform(matrix);

		vertices[prevVerticesPos + 2] = point.x;
		vertices[prevVerticesPos + 3] = point.y;

		uvtData[prevVerticesPos + 2] = frame.uv.width;
		uvtData[prevVerticesPos + 3] = frame.uv.y;

		point.set(frame.frame.width, frame.frame.height);
		point.transform(matrix);

		vertices[prevVerticesPos + 4] = point.x;
		vertices[prevVerticesPos + 5] = point.y;

		uvtData[prevVerticesPos + 4] = frame.uv.width;
		uvtData[prevVerticesPos + 5] = frame.uv.height;

		point.set(0, frame.frame.height);
		point.transform(matrix);

		vertices[prevVerticesPos + 6] = point.x;
		vertices[prevVerticesPos + 7] = point.y;

		point.put();

		uvtData[prevVerticesPos + 6] = frame.uv.x;
		uvtData[prevVerticesPos + 7] = frame.uv.height;

		indices[prevIndicesPos] = prevNumberOfVertices;
		indices[prevIndicesPos + 1] = prevNumberOfVertices + 1;
		indices[prevIndicesPos + 2] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 3] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 4] = prevNumberOfVertices + 3;
		indices[prevIndicesPos + 5] = prevNumberOfVertices;

		if (colored)
		{
			final color = FlxColor.fromRGBFloat(
                transform.redMultiplier,
                transform.greenMultiplier,
                transform.blueMultiplier,
                #if !neko transform.alphaMultiplier #else 1.0 #end
            );

			colors[prevColorsPos] = color;
			colors[prevColorsPos + 1] = color;
			colors[prevColorsPos + 2] = color;
			colors[prevColorsPos + 3] = color;

			colorsPosition += 4;
		}

		verticesPosition += 8;
		indicesPosition += 6;
	}

	override inline function get_numVertices():Int
	{
		return Std.int(vertices.length * .5);
	}

	override inline function get_numTriangles():Int
	{
		return Std.int(indices.length / 3);
	}
}