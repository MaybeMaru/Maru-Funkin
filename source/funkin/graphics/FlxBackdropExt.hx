package funkin.graphics;

import flixel.graphics.frames.FlxFrame;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMatrix;
import flixel.util.FlxAxes;

using flixel.util.FlxColorTransformUtil;

// TODO: make this override FlxSpriteExt instead, im just lazy to convert the rest of the class rn lmao
class FlxBackdropExt extends FlxBackdrop
{
    var tileMatrix:FlxMatrix;
    var tileSize:FlxPoint = FlxPoint.get();

    public function new(?graphic:Null<FlxGraphicAsset>, repeatAxes:FlxAxes = XY, spacingX:Float = 0.0, spacingY:Float = 0.0) {
        super(graphic, repeatAxes, spacingX, spacingY);

        this.tileMatrix = new FlxMatrix();
    }

    override function destroy() {
        super.destroy();
        tileMatrix = null;
        tileSize = FlxDestroyUtil.put(tileSize);
    }

    private inline function prepareFrameMatrix(frame:FlxFrame, mat:FlxMatrix):Void
	{
		var flipX = (flipX != _frame.flipX);
		var flipY = (flipY != _frame.flipY);
		
		if (animation.curAnim != null)
		{
			flipX != animation.curAnim.flipX;
			flipY != animation.curAnim.flipY;
		}
		
		@:privateAccess {
			final tileMat = frame.tileMatrix;
			mat.a = tileMat[0];
			mat.b = tileMat[1];
			mat.c = tileMat[2];
			mat.d = tileMat[3];
			mat.tx = tileMat[4];
			mat.ty = tileMat[5];
		}

		if (frame.angle == 180) {
			mat.rotateBy180();
			mat.tx = (mat.tx + frame.sourceSize.y);
			mat.ty = (mat.ty + frame.sourceSize.x);
		}

		if (lodScale != 1.0)
			FunkMath.scaleMatrix(mat, lodScale, lodScale);

		if (flipX != frame.flipX) {
			FunkMath.scaleMatrix(mat, -1, 1);
			mat.tx = (mat.tx + frame.sourceSize.x);
		}

		if (flipY != frame.flipY) {
			FunkMath.scaleMatrix(mat, 1, -1);
			mat.tx = (mat.tx + frame.sourceSize.y);
		}
	}

    override function drawComplex(camera:FlxCamera)
	{
		if (repeatAxes == NONE)
		{
			super.drawComplex(camera);
			return;
		}
		
        prepareFrameMatrix(_frame, _matrix);
		_matrix.translate(-origin.x, -origin.y);
		
        tileSize.set(
            (_frame.frame.width  + spacing.x) * scale.x * lodScale,
            (_frame.frame.height + spacing.y) * scale.y * lodScale,
        );
        
        FunkMath.scaleMatrix(_matrix, scale.x, scale.y);

        if (angle != 0) {
			if (_angleChanged) {
                final rads:Float = angle * FunkMath.TO_RADS;
                _cosAngle = FunkMath.cos(rads);
                _sinAngle = FunkMath.sin(rads);
                _angleChanged = false;
            }
			_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		
		getScreenPosition(_point, camera).subtractPoint(offset);
		
        var tilesX = 1;
		var tilesY = 1;

        final viewMargins = camera.getViewMarginRect();
        final bounds = getScreenBounds(camera);

        if (repeatAxes.x)
        {
            final origTileSizeX = (frameWidth + spacing.x) * scale.x;
            final left  = modMin(bounds.right, origTileSizeX, viewMargins.left) - bounds.width;
            final right = modMax(bounds.left, origTileSizeX, viewMargins.right) + origTileSizeX;
            tilesX = Math.round((right - left) / tileSize.x);
            _point.x = left + _point.x - bounds.x;
        }
        
        if (repeatAxes.y)
        {
            final origTileSizeY = (frameHeight + spacing.y) * scale.y;
            final top    = modMin(bounds.bottom, origTileSizeY, viewMargins.top) - bounds.height;
            final bottom = modMax(bounds.top, origTileSizeY, viewMargins.bottom) + origTileSizeY;
            tilesY = Math.round((bottom - top) / tileSize.y);
            _point.y = top + _point.y - bounds.y;
        }

        viewMargins.put();
        bounds.put();
        
		_point.addPoint(origin);

        var hasColors = (colorTransform != null) ? (colorTransform.hasRGBMultipliers() || colorTransform.hasRGBAOffsets()) : false;
        var quad = camera.startQuadBatch(_frame.parent, hasColors, hasColors, blend, antialiasing, shader);
		
		for (tileX in 0...tilesX)
		{
			for (tileY in 0...tilesY)
			{
				tileMatrix.copyFrom(_matrix);
				tileMatrix.translate(_point.x + (tileSize.x * tileX), _point.y + (tileSize.y * tileY));
				quad.addQuad(_frame, tileMatrix, colorTransform);
			}
		}
	}

	public var lodScale(default, null):Float = 1.0;

	override function set_graphic(value:FlxGraphic):FlxGraphic
	{
		if (graphic != value) {
			lodScale = (value is LodGraphic) ? cast(value, LodGraphic).lodScale : 1.0;			
			graphic = value;
		}
		
		return value;
	}
}