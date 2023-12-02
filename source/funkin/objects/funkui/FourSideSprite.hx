package funkin.objects.funkui;

class FourSideSprite extends FlxSprite {
    function __quickDraw(spr:FlxSprite, x:Float, y:Float, flipX:Bool, flipY:Bool) {
        pixels.fillRect(new Rectangle(x,y,spr.width,spr.height), FlxColor.TRANSPARENT);
        spr.flipX = flipX;
        spr.flipY = flipY;
		stamp(spr, Std.int(x), Std.int(y));
	}
    
    public function new(X:Float, Y:Float, Width:Int, Height:Int, Color:Int) {
        super(X,Y);
        final key:String = 'foursidesprite::$Width$Height$Color::';

        if (FlxG.bitmap.checkCache(key)) {
            loadGraphic(FlxG.bitmap.get(key));
        }
        else {
            makeGraphic(Width, Height, Color, false, key);
            final side = new FlxSprite("assets/images/ui/round.png");
            side.color = Color;
            __quickDraw(side, 0, 0, false, false);
            __quickDraw(side, width - side.width, 0, true, false);
            __quickDraw(side, 0, height - side.height, false, true);
            __quickDraw(side, width - side.width, height - side.height, true, true);
            side.destroy();
        }
    }
}