package funkin.graphics;

import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.graphics.frames.FlxFrame;

using flixel.util.FlxColorTransformUtil;

enum abstract RepeatDrawStyle(Bool) from Bool {
    var TOP_BOTTOM = true;
    var BOTTOM_TOP = false;
}

/**
 * Like FlxTiledSprite but it use quads
 * This class CANNOT be used unless it gets released on flixel addons or i give u permission to
 *
 * @author maybemaru
 */
class FlxRepeatSprite extends FlxSpriteExt
{    
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

    override function draw():Void {
        if (tilesX == 0) return;
        if (tilesY == 0) return;
        if (!visible) return;
        if (alpha == 0) return;

		checkEmptyFrame();
		if (clipRect != null) if (clipRect.isEmpty) return;

        cameras.fastForEach((camera, i) -> {
            if (camera.visible) if (camera.exists) if (isOnScreen(camera)) {
                drawComplex(camera);
                #if FLX_DEBUG
                FlxBasic.visibleCount++;
                #end
            }
        });
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

    static final tempPoint:FlxPoint = FlxPoint.get();
    static final lastMatrix:FlxPoint = FlxPoint.get(); // Nasty hack

    override function drawComplex(camera:FlxCamera):Void
    {
        __prepareDraw(camera);

        // Holds the og matrix position for each tile
        var point = CoolUtil.point.set(_matrix.tx, _matrix.ty);

        // Fix bug of tiles duplicating
        lastMatrix.set(-1, -1);

        var scaleX = scaleX();
        var scaleY = scaleY();
        var fw:Float = frameWidth * scaleX; // TODO: replace this shit same way as Height

        var hasColors = (colorTransform != null) ? (colorTransform.hasRGBMultipliers() || colorTransform.hasRGBAOffsets()) : false;
        var quad = camera.startQuadBatch(_frame.parent, hasColors, hasColors, blend, antialiasing, shader);

        switch (drawStyle)
        {
            // Draw from left top to right bottom style
            case TOP_BOTTOM:
                for (xi in 0...tilesX)
                {
                    var heightPos:Float = 0;
                    for (yi in 0...tilesY)
                    {
                        setupTile(xi, yi, frame);
                        
                        var addW = fw * (xi + 1);
                        if (addW > repeatWidth) // Cut frame width
                            _frame.frame.width = (fw + (repeatWidth - addW)) / scaleX;
                        
                        heightPos += tempPoint.y;
                        if (heightPos > repeatHeight) // Cut frame height
                            _frame.frame.height = (tempPoint.y + (repeatHeight - heightPos)) / scaleY;
        
                        // Position and draw
                        var addX = addW - fw;
                        var addY = heightPos - tempPoint.y;

                        _matrix.tx = point.x + (addX * _cosAngle) + (addY * -_sinAngle);
                        _matrix.ty = point.y + (addX * _sinAngle) + (addY * _cosAngle);
                        
                        tempPoint.set(addX,addY);
                        drawTile(xi, yi, _frame, frame, quad, tempPoint, camera);
                    }
                }
            // Draw from bottom to top style
            case BOTTOM_TOP:
                for (xi in 0...tilesX)
                {
                    var heightPos:Float = repeatHeight;
                    for (yi in 0...tilesY)
                    {
                        setupTile(xi, yi, frame);

                        var addW = fw * (xi + 1);
                        if (addW > repeatWidth) // Cut frame width
                            _frame.frame.width = (fw + (repeatWidth - addW)) / scaleX;

                        heightPos -= tempPoint.y;
                        if (heightPos < 0)
                        {
                            var moveH = heightPos / scaleY;
                            _frame.frame.height = _frame.frame.height + moveH;
                            _frame.frame.y = _frame.frame.y - moveH;
                            
                            heightPos = 0;
                        }

                        // Position and draw
                        var addX = addW - fw;
                        _matrix.tx = point.x + (addX * _cosAngle) + (heightPos * -_sinAngle);
                        _matrix.ty = point.y + (addX * _sinAngle) + (heightPos * _cosAngle);
                        
                        tempPoint.set(addX,heightPos);
                        drawTile(xi, yi, _frame, frame, quad, tempPoint, camera);
                    }
                }
        }

    }

    private inline function translateWithTrig(tx:Float, ty:Float) {
        _matrix.tx = _matrix.tx + ((tx * _cosAngle) + (ty * -_sinAngle));
        _matrix.ty = _matrix.ty + ((tx * _sinAngle) + (ty * _cosAngle));
    }

    // Prepare tile dimensions
    function setupTile(tileX:Int, tileY:Int, baseFrame:FlxFrame) {
        var rect = baseFrame.frame;
        var point = tempPoint.set(rect.width * scaleX(), rect.height * scaleY());
        _frame.frame.copyFrom(rect);
        _frame.angle = baseFrame.angle;
        return point;
    }

    var tileOffset:FlxPoint = FlxPoint.get();

    function drawTile(tileX:Int, tileY:Int, tileFrame:FlxFrame, baseFrame:FlxFrame, quad:FlxDrawQuadsItem, tilePos:FlxPoint, camera:FlxCamera):Void
    {
        // Do cliprect stuff
        var doDraw:Bool = (clipRect != null) ? handleClipRect(tileFrame, baseFrame, tilePos) : true;
        if (tileRect != null)
            tileFrame = tileFrame.clipTo(tileRect);

        var mTx = _matrix.tx;
        var mTy = _matrix.ty;
        
        if (doDraw) if ((lastMatrix.x != mTx) || (lastMatrix.y != mTy))
        {
            lastMatrix.set(mTx, mTy);
            translateWithTrig(-tileOffset.x, -tileOffset.y);
            
            if (rectInBounds(mTx, mTy, tileFrame.frame.width, tileFrame.frame.height, camera)) // dont draw stuff out of bounds
                quad.addQuad(tileFrame, _matrix, colorTransform);
            
            translateWithTrig(tileOffset.x, tileOffset.y);
            tileOffset.set();
        }
    }

    inline private function scaleX() return scale.x * lodScale;
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

    function handleClipRect(tileFrame:FlxFrame, baseFrame:FlxFrame, tilePos:FlxPoint):Bool
    {
        translateWithTrig(clipRect.x, clipRect.y);
        tilePos.add(clipRect.x, clipRect.y);

        final frame = tileFrame.frame;
        final baseFrame = baseFrame.frame;
        
        final scaleX = scaleX();

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

        final scaleY = scaleY();

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