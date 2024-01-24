package funkin.graphics;

enum RenderMode {
    QUAD;
    REPEAT;
}

class SmartSprite extends FlxSkewRepeatSprite {
    public var renderMode:RenderMode = QUAD;
    public function setRenderMode(value:String) {
        renderMode = switch (value.toLowerCase().trim()) {
            case "quad" | "q" | "1": QUAD;
            case "repeat" | "r" | "2": REPEAT;
            default: QUAD; // Ill maybe add more render modes over time idk
        }
    }

    public function new(?X:Float, ?Y:Float, ?SimpleGraphic:FlxGraphicAsset) {
        super(X, Y, SimpleGraphic, 0, 0);
    }

    override function draw() {
        switch (renderMode) {
            case REPEAT: super.draw();
            case QUAD:
                inline checkEmptyFrame();
                if (alpha == 0 || _frame.type == EMPTY) return;
                if (dirty)  calcFrame(useFramePixels); // rarely
         
                for (camera in cameras) {
                    if (!camera.visible || !camera.exists || !isOnScreen(camera)) continue;
                    drawComplex(camera);
                }
        }
    }

    override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
        switch (renderMode) {
            case REPEAT: return super.getScreenBounds(newRect, camera);
            case QUAD:
                if (newRect == null) newRect = CoolUtil.rect;
                if (camera == null) camera = FlxG.camera;
                newRect.setPosition(x, y);
                _scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);
                newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x;
                newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y;
                newRect.setSize(frameWidth * Math.abs(scale.x), frameHeight * Math.abs(scale.y));
                return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
        }
	}
    
    override function drawComplex(camera:FlxCamera) {
        switch (renderMode) {
            case REPEAT: super.drawComplex(camera);
            case QUAD: __superDrawComplex(camera);
        }
    }
}