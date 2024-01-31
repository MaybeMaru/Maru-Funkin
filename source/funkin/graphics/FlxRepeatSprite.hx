package funkin.graphics;

import flixel.math.FlxMatrix;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxFrame;


enum RepeatDrawStyle {
    TOP_BOTTOM;
    BOTTOM_TOP;
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
        return Math.ceil(repeatWidth / (frameWidth * Math.abs(scale.x)));
    }
    
    public var tilesY(get, null):Int;
    inline function get_tilesY() {
        return Math.ceil(repeatHeight / (frameHeight * Math.abs(scale.y)));
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
        setRepeat(repeatWidth ?? frameWidth, repeatHeight ?? frameHeight);
    }

    override function destroy() {
        super.destroy();
        tileRect = FlxDestroyUtil.put(tileRect);
        clipRect = FlxDestroyUtil.put(clipRect);
        tileOffset = FlxDestroyUtil.put(tileOffset);
    }

    override inline function set_clipRect(rect:FlxRect):FlxRect {
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
            var camera = cameras[i];
			if (!camera.visible || !camera.exists || !isOnScreen(camera)) continue;
			drawComplex(camera);
            #if FLX_DEBUG FlxBasic.visibleCount++; #end
		}
    }

    override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
        if (newRect == null) newRect = CoolUtil.rect;
		if (camera == null) camera = FlxG.camera;
		
		newRect.setPosition(x, y);
		_scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);
		newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x;
		newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y;
		newRect.setSize(repeatWidth, repeatHeight);
		
		return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
    }

    static final __tempPoint:FlxPoint = FlxPoint.get();
    static final __lastMatrix = FlxPoint.get(); // Nasty hack

    override function drawComplex(camera:FlxCamera) {
        prepareFrameMatrix(_frame, _matrix, checkFlipX(), checkFlipY());
		
		inline _matrix.translate(-origin.x, -origin.y);
		inline _matrix.scale(scale.x, scale.y);

        if (angle != 0) {
			__updateTrig();
			_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

        getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		inline _matrix.translate(_point.x, _point.y);

        /*
         *  The actual code of the class lol
        **/

        // Holds the og matrix position for each tile
        var point = CoolUtil.point.set(_matrix.tx, _matrix.ty);

        // Temp point for calculations
        var tempPoint = __tempPoint;

        // Fix bug of tiles duplicating
        __lastMatrix.set(-1, -1);

        var scaleX = scaleX();
        var fw:Float = frameWidth * scaleX; // TODO: replace this shit same way as Height

        switch (drawStyle) {
            // Draw from left top to right bottom style
            case TOP_BOTTOM:
                for (xi in 0...tilesX) {
                    var heightPos:Float = 0;
                    for (yi in 0...tilesY) {
                        setupTile(xi, yi, frame);
                        
                        var addW = fw * (xi + 1);
                        if (addW > repeatWidth) // Cut frame width
                            _frame.frame.width = (fw + (repeatWidth - addW)) / scaleX;
                        
                        heightPos += tempPoint.y;
                        if (heightPos > repeatHeight) // Cut frame height
                            _frame.frame.height = (tempPoint.y + (repeatHeight - heightPos)) / scaleY();
        
                        // Position and draw
                        var addX = addW - fw;
                        var addY = heightPos - tempPoint.y;

                        _matrix.tx = point.x + (addX * _cosAngle) + (addY * -_sinAngle);
                        _matrix.ty = point.y + (addX * _sinAngle) + (addY * _cosAngle);
                        
                        tempPoint.set(addX,addY);
                        drawTile(xi, yi, _frame, frame, framePixels, tempPoint, camera);
                    }
                }
            // Draw from bottom to top style
            case BOTTOM_TOP:
                for (xi in 0...tilesX) {
                    var heightPos:Float = repeatHeight;
                    for (yi in 0...tilesY) {
                        setupTile(xi, yi, frame);

                        var addW = fw * (xi + 1);
                        if (addW > repeatWidth) // Cut frame width
                            _frame.frame.width = (fw + (repeatWidth - addW)) / scaleX;

                        heightPos -= tempPoint.y;
                        if (heightPos < 0) {
                            var scaleY = scaleY();
                            _frame.frame.height += heightPos / scaleY;
                            _frame.frame.y -= heightPos / scaleY;
                            heightPos = 0;
                        }

                        // Position and draw
                        var addX = addW - fw;
                        _matrix.tx = point.x + (addX * _cosAngle) + (heightPos * -_sinAngle);
                        _matrix.ty = point.y + (addX * _sinAngle) + (heightPos * _cosAngle);
                        
                        tempPoint.set(addX,heightPos);
                        drawTile(xi, yi, _frame, frame, framePixels, tempPoint, camera);
                    }
                }
        }

    }

    private inline function translateWithTrig(tx:Float, ty:Float) {
        _matrix.tx += (tx * _cosAngle) + (ty * -_sinAngle);
        _matrix.ty += (tx * _sinAngle) + (ty * _cosAngle);
    }

    // Prepare tile dimensions
    function setupTile(tileX:Int, tileY:Int, baseFrame:FlxFrame) {
        var frame = baseFrame.frame;
        var point = __tempPoint.set(frame.width * scaleX(), frame.height * scaleY());
        _frame.frame.copyFrom(frame);
        _frame.angle = baseFrame.angle;
        return point;
    }

    var tileOffset:FlxPoint = FlxPoint.get();

    function drawTile(tileX:Int, tileY:Int, tileFrame:FlxFrame, baseFrame:FlxFrame, bitmap:BitmapData, tilePos:FlxPoint, camera:FlxCamera) {
        // Do cliprect stuff
        var doDraw:Bool = clipRect != null ? handleClipRect(tileFrame, baseFrame, tilePos) : true;
        if (tileRect != null) tileFrame = tileFrame.clipTo(tileRect);

        var lastMatrix = __lastMatrix;
        var mTx = _matrix.tx;
        var mTy = _matrix.ty;
        
        if (doDraw && (lastMatrix.x != mTx || lastMatrix.y != mTy)) {
            lastMatrix.set(mTx, mTy);
            translateWithTrig(-tileOffset.x, -tileOffset.y);
            
            var frame = tileFrame.frame;
            if (rectInBounds(mTx, mTy, frame.width, frame.height, camera)) // dont draw stuff out of bounds
                drawTileToCamera(tileFrame, bitmap, _matrix, camera);
            
            translateWithTrig(tileOffset.x, tileOffset.y);
            tileOffset.set();
        }
    }

    inline function drawTileToCamera(tileFrame:FlxFrame, bitmap:BitmapData, tileMatrix:FlxMatrix, camera:FlxCamera) {
        camera.drawPixels(tileFrame, bitmap, tileMatrix, colorTransform, blend, antialiasing, shader);
    }

    @:noCompletion
    inline private function scaleX() return scale.x * lodScale;

    @:noCompletion
    inline private function scaleY() return scale.y * lodScale;

    inline function rectInBounds(x:Float, y:Float, w:Float, h:Float, cam:FlxCamera):Bool {
        var rect = CoolUtil.rect.set(
            x,
            y,
            w * Math.abs(scaleX()),
            h * Math.abs(scaleY())
        );
        return cam.containsRect(rect.getRotatedBounds(angle, null, rect));
    }

    function handleClipRect(tileFrame:FlxFrame, baseFrame:FlxFrame, tilePos:FlxPoint) {
        translateWithTrig(clipRect.x, clipRect.y);
        tilePos.add(clipRect.x, clipRect.y);

        var frame = tileFrame.frame;
        var baseFrame = baseFrame.frame;

        var scaleX = scaleX();

        // Cut if clipping left
        if (tilePos.x < 0) {
            var offX = tilePos.x / scaleX;
            frame.width += offX;
            frame.x -= offX;
            translateWithTrig(-offX * scaleX, 0);
            if (frame.width <= 0) return false; // Dont draw it
        }

        // Cut if clipping right
        if ((clipRect.width - clipRect.x) < repeatWidth) {
            var cutX = (tilePos.x + (baseFrame.width * scaleX)) - clipRect.width;
            if (cutX > 0) {
                frame.width -= cutX / scaleX;
                if (frame.width <= 0) return false; // Dont draw it
            }
        }

        var scaleY = scaleY();

        // Cut if clipping top
        if (tilePos.y < 0) {
            var offY = tilePos.y / scaleY;
            frame.height += offY;
            frame.y -= offY;
            translateWithTrig(0, -offY * scaleY);
            if (frame.height <= 0) return false; // Dont draw it
        }
        
        // Cut if clipping bottom
        if ((clipRect.height - clipRect.y) < repeatHeight) {
            var cutY = (tilePos.y + (baseFrame.height * scaleY)) - clipRect.height;
            if (cutY > 0) {
                frame.height -= cutY / scaleY;
                if (frame.height <= 0) return false; // Dont draw it
            }
        }

        return true;
    }
}