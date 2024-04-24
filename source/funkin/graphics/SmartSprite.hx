package funkin.graphics;

// Makin this a bool cause its easier to store
// If i add more render modes will turn it back into integers lol
enum abstract RenderMode(Bool) from Bool {
    var QUAD = true;
    var REPEAT = false;
}

// Internal class to switch between render modes in BasicNote
abstract class SmartSprite extends FlxSkewRepeatSprite
{
    public var renderMode:RenderMode = QUAD;

    // For hscript mainly lmao
    public function setRenderMode(value:String) {
        renderMode = switch (value.toLowerCase().trim()) {
            case "quad" | "q" | "1" | "true": QUAD;
            case "repeat" | "r" | "2" | "false": REPEAT;
            default: QUAD; // Ill maybe add more render modes over time idk
        }
    }

    public function new(?X:Float, ?Y:Float, ?SimpleGraphic:FlxGraphicAsset) {
        super(X, Y, SimpleGraphic, 0, 0);
    }

    override function draw() {
        switch (renderMode) {
            case REPEAT: super.draw();
            case QUAD:  __superDraw();
        }
    }

    override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
        switch (renderMode) {
            case REPEAT: return super.getScreenBounds(newRect, camera);
            case QUAD: return __superGetScreenBounds(newRect, camera);
        }
	}
    
    override function drawComplex(camera:FlxCamera) {
        switch (renderMode) {
            case REPEAT: super.drawComplex(camera);
            case QUAD: __superDrawComplex(camera);
        }
    }
}