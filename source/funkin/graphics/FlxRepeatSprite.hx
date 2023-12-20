package funkin.graphics;

import flixel.math.FlxMatrix;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxFrame;


enum RepeatDrawStyle {
    TOP_BOTTOM;
    BOTTOM_TOP;
    //FAST_BOTTOM_TOP; maybe later
}

/**
 * Like FlxTiledSprite but it use quads
 * This class CANNOT be used unless it gets released on flixel addons or i give u permission to
 *
 * @author maybemaru
 */
class FlxRepeatSprite extends FlxSpriteExt {    
    public var repeatWidth:Float;
    public var repeatHeight:Float;
    public var drawStyle:RepeatDrawStyle = TOP_BOTTOM;

    public var tilesX(get, null):Int;
    inline function get_tilesX() {
        return Math.ceil(repeatWidth / (frameWidth * scale.x));
    }
    
    public var tilesY(get, null):Int;
    inline function get_tilesY() {
        return Math.ceil(repeatHeight / (frameHeight * scale.y));
    }

    public function setRepeat(repeatWidth:Float, repeatHeight:Float) {
        this.repeatWidth = repeatWidth;
        this.repeatHeight = repeatHeight;
    }

    public function setTiles(tilesX:Float, tilesY:Float) {
        setRepeat(tilesX * frameWidth * scale.x, tilesY * frameHeight * scale.y);
    }

    /*
     * Optional rect for INDIVIDUAL TILES
     * For the whole sprite use clipRect
     */
    public var tileRect:FlxRect;
    
    public function new(?X:Float, ?Y:Float, ?SimpleGraphic:FlxGraphicAsset, ?repeatWidth:Float, ?repeatHeight:Float) {
        super(X,Y,SimpleGraphic);
        checkEmptyFrame();
        setRepeat(repeatWidth ?? frameWidth, repeatHeight ?? frameHeight);
    }

    override function destroy() {
        super.destroy();
        tileRect = FlxDestroyUtil.put(tileRect);
        clipRect = FlxDestroyUtil.put(clipRect);
    }

    override function set_clipRect(rect:FlxRect):FlxRect {
        return clipRect = rect;
    }

    override function draw() {
        if (tilesX == 0 || tilesY == 0) {
            return;
        }
        
        inline checkEmptyFrame();
		if (alpha == 0 || !visible || (clipRect?.isEmpty)) return;
		if (dirty) calcFrame(useFramePixels);

		for (i in 0...cameras.length) {
            final camera = cameras[i];
			if (!camera.visible || !camera.exists || !isOnScreen(camera)) continue;
			drawComplex(camera);
		}
    }

    override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (newRect == null) newRect = FlxRect.get();
		if (camera == null) camera = FlxG.camera;
		newRect.setPosition(x, y);
		_scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);
		newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x;
		newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y;
        newRect.setSize(repeatWidth, repeatHeight);
		return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
    }

    static final __tilePoint:FlxPoint = FlxPoint.get();
    static final __tempPoint:FlxPoint = FlxPoint.get();
    static var __drawCam:FlxCamera;

    override function drawComplex(camera:FlxCamera) {
        __drawCam = camera;
        _frame.prepareMatrix(_matrix, ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0) {
			updateTrig();
			if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

        /*
         *  The actual code of the class lol
        **/

        __tilePoint.set(_matrix.tx, _matrix.ty);
        final fw:Float = frameWidth * scale.x;

        _frame.frame.width = frameWidth;
        _frame.frame.height = frameHeight;
        lastMatrix.set(-1,-1);

        switch (drawStyle) {
            // Draw from left top to right bottom style
            case TOP_BOTTOM:
                for (xi in 0...tilesX) {
                    var heightPos:Float = 0;
                    for (yi in 0...tilesY) {
                        setupTile(xi, yi, frame);
                        
                        final addW = fw * (xi + 1);
                        if (addW > repeatWidth) // Cut frame width
                            _frame.frame.width = (fw + (repeatWidth - addW)) / scale.x;
                        
                        heightPos += __tempPoint.y;
                        if (heightPos > repeatHeight) // Cut frame height
                            _frame.frame.height = (__tempPoint.y + (repeatHeight - heightPos)) / scale.y;
        
                        // Position and draw
                        final addX = addW - fw;
                        final addY = heightPos - __tempPoint.y;

                        _matrix.tx = __tilePoint.x + (addX * _cosAngle) + (addY * -_sinAngle);
                        _matrix.ty = __tilePoint.y + (addX * _sinAngle) + (addY * _cosAngle);
                        
                        __tempPoint.set(addX,addY);
                        drawTile(xi, yi, _frame, frame, framePixels, __tempPoint);
                    }
                }
            // Draw from bottom to top style
            case BOTTOM_TOP:
                for (xi in 0...tilesX) {
                    var heightPos:Float = repeatHeight;
                    for (yi in 0...tilesY) {
                        setupTile(xi, yi, frame);

                        final addW = fw * (xi + 1);
                        if (addW > repeatWidth) // Cut frame width
                            _frame.frame.width = (fw + (repeatWidth - addW)) / scale.x;

                        heightPos -= __tempPoint.y;
                        if (heightPos < 0) {
                            _frame.frame.height += heightPos / scale.y;
                            _frame.frame.y -= heightPos / scale.y;
                            heightPos = 0;
                        }

                        // Position and draw
                        final addX = addW - fw;
                        _matrix.tx = __tilePoint.x + (addX * _cosAngle) + (heightPos * -_sinAngle);
                        _matrix.ty = __tilePoint.y + (addX * _sinAngle) + (heightPos * _cosAngle);
                        
                        __tempPoint.set(addX,heightPos);
                        drawTile(xi, yi, _frame, frame, framePixels, __tempPoint);
                    }
                }
        }

    }

    function translateWithTrig(tx:Float, ty:Float) {
        _matrix.tx += (tx * _cosAngle) + (ty * -_sinAngle);
        _matrix.ty += (tx * _sinAngle) + (ty * _cosAngle);
    }

    // Prepare tile dimensions
    function setupTile(tileX:Int, tileY:Int, baseFrame:FlxFrame) {
        __tempPoint.set(baseFrame.frame.width * scale.y, baseFrame.frame.height * scale.y);
        return __tempPoint;
    }

    static var lastMatrix = FlxPoint.get(); // Nasty hack

    function drawTile(tileX:Int, tileY:Int, tileFrame:FlxFrame, baseFrame:FlxFrame, bitmap:BitmapData, tilePos:FlxPoint) {
        final __doDraw:Bool = clipRect != null ? handleClipRect(tileFrame, baseFrame, tilePos) : true;
        if (tileRect != null) tileFrame = tileFrame.clipTo(tileRect);

        if (__doDraw && (lastMatrix.x != _matrix.tx || lastMatrix.y != _matrix.ty)) {
            lastMatrix.set(_matrix.tx, _matrix.ty);
            if (!matrixOutOfBounds(_matrix, tileFrame.frame, __drawCam)) // dont draw stuff out of bounds
                __drawCam.drawPixels(tileFrame, bitmap, _matrix, colorTransform, blend, antialiasing, shader);
        }
        tileFrame.frame.copyFrom(baseFrame.frame);
    }

    inline function matrixOutOfBounds(matrix:FlxMatrix, frame:FlxRect, cam:FlxCamera):Bool {
        return  ((_matrix.ty + frame.height) < cam.viewY) ||
                ((_matrix.ty - frame.height) > cam.viewHeight) ||
                ((_matrix.tx + frame.width) < cam.viewX) ||
                ((_matrix.tx - frame.width) > cam.viewWidth);
    }

    function handleClipRect(tileFrame:FlxFrame, baseFrame:FlxFrame, tilePos:FlxPoint) {
        translateWithTrig(clipRect.x, clipRect.y);
        tilePos.add(clipRect.x, clipRect.y);

        // Cut if clipping left
        if (tilePos.x < 0) {
            final offX = tilePos.x / scale.x;
            tileFrame.frame.width += offX;
            tileFrame.frame.x -= offX;
            translateWithTrig(-offX * scale.x, 0);
            if (tileFrame.frame.width <= 0) return false; // Dont draw it
        }

        // Cut if clipping right
        if ((clipRect.width - clipRect.x) < repeatWidth) {
            final cutX = (tilePos.x + (baseFrame.frame.width * scale.x)) - clipRect.width;
            if (cutX > 0) {
                tileFrame.frame.width -= cutX / scale.x;
                if (tileFrame.frame.width <= 0) return false; // Dont draw it
            }
        }

        // Cut if clipping top
        if (tilePos.y < 0) {
            final offY = tilePos.y / scale.y;
            tileFrame.frame.height += offY;
            tileFrame.frame.y -= offY;
            translateWithTrig(0, -offY * scale.y);
            if (tileFrame.frame.height <= 0) return false; // Dont draw it
        }
        
        // Cut if clipping bottom
        if ((clipRect.height - clipRect.y) < repeatHeight) {
            final cutY = (tilePos.y + (baseFrame.frame.height * scale.y)) - clipRect.height;
            if (cutY > 0) {
                tileFrame.frame.height -= cutY / scale.y;
                if (tileFrame.frame.height <= 0) return false; // Dont draw it
            }
        }

        return true;
    }
}