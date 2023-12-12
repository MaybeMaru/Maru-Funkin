package funkin.objects.funkui;

enum FourSideStyle {
    NONE;
    OUTLINE(thickness:Float, ?color:FlxColor);
}

class FourSideSprite extends FlxSprite {
    static var rect:Rectangle = new Rectangle();
    static function getRect(X:Float,Y:Float,W:Float,H:Float) {
        rect.setTo(X,Y,W,H);
        return rect;
    }
    
    function __quickDraw(spr:FlxSprite, x:Float, y:Float, flipX:Bool, flipY:Bool, fill:FlxColor) {
        pixels.fillRect(getRect(x,y,spr.width,spr.height), fill);
        spr.flipX = flipX;
        spr.flipY = flipY;
		stamp(spr, Std.int(x), Std.int(y));
	}
    
    public function new(X:Float, Y:Float, Width:Int, Height:Int, Color:Int, Style:FourSideStyle = NONE) {
        super(X,Y);
        final key:String = 'foursidesprite::$Width$Height$Color::';

        if (FlxG.bitmap.checkCache(key)) {
            loadGraphic(FlxG.bitmap.get(key));
        }
        else {
            final side = new FlxSprite("assets/images/ui/round.png");
            switch (Style) {
                case NONE:
                    makeGraphic(Width, Height, Color, false, key);
                    side.color = Color;
                    __doDraw(side);

                case OUTLINE(thickness, color):
                    makeGraphic(Width, Height, color, false, key);
                    side.color = color;
                    __doDraw(side);

                    pixels.fillRect(getRect(thickness, thickness, Width - (thickness * 2), Height - (thickness * 2)), Color);
                    side.color = Color;
                    __doDraw(side, thickness, color);
            }
            
            side.destroy();
        }
    }

    override function draw() {
        if (visible) super.draw();
    }

    private function __doDraw(side:FlxSprite, out:Float = 0.0, fill:FlxColor = FlxColor.TRANSPARENT) {
        __quickDraw(side, out, out, false, false, fill);
        __quickDraw(side, width - side.width - out, out, true, false, fill);
        __quickDraw(side, out, height - side.height - out, false, true, fill);
        __quickDraw(side, width - side.width - out, height - side.height - out, true, true, fill);
    } 
}