package funkin.objects.funkui;

class FunkCheckBox extends FlxSprite implements IFunkUIObject {
    private static var __sprite:FlxSprite;

    static function getCheckSprite() {
        if (__sprite != null) return __sprite;
        else {
            final square = new FourSideSprite(0,0,25,25,FlxColor.WHITE);
            final checkMark = new FlxSprite("assets/images/ui/checkmark.png");

            final sprite = new FlxSprite().makeGraphic(25*2, 25, FlxColor.TRANSPARENT, true);
            square.color = 0xff1F6AA4;
            sprite.stamp(square);
            sprite.stamp(checkMark, Std.int(12.5 - checkMark.height * 0.5), Std.int(12.5 - checkMark.height * 0.5));

            square.color = 0xff989FA4;
            sprite.stamp(square, 25);
            
            square.color = 0xff212325;
            square.setGraphicSize(17.5,17.5);
            square.updateHitbox();
            sprite.stamp(square, 25);

            square.destroy();
            checkMark.destroy();

            sprite.loadGraphic(sprite.pixels, true, 25, 25);
            sprite.animation.add("checked", [0]);
            sprite.animation.add("unchecked", [1]);

            return sprite;
        }
    }
    
    private var text:FlxFunkText;
    public var ogX:Float;
	public var ogY:Float;
	
	public var label(default, set):String = "";
	function set_label(value:String):String {
		return text.text = label = value;
	}

    public var checked(default, set):Bool = false;
    function set_checked(value:Bool):Bool {
        animation.play(value ? "checked" : "unchecked");
        return checked = value;
    }

    public var callback:Bool->Void = null;
    
    public function new(X:Float, Y:Float, Label:String = "abc", ?Callback:Bool->Void) {
        super(X,Y);
        loadGraphicFromSprite(getCheckSprite());

        ogX = X;
		ogY = Y;

        text = new FunkUIText(X + 30, Y, Label);
        callback = Callback;
        checked = false;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(this)) {
			if (FlxG.mouse.justPressed) {
                checked = !checked;
				color = FlxColor.GRAY;
                onClick();
            }
		}

		if (color != FlxColor.WHITE) {
			color = FlxColor.interpolate(color, FlxColor.WHITE, elapsed * 10);
		}
    }

    function onClick() {
		if (callback != null) {
			callback(checked);
		}
	}
    
    public function setUIPosition(X:Float, Y:Float):Void {
        setPosition(X,Y);
        text.setPosition(X + 30, Y);
    }

    override function draw() {
		super.draw();
		text.draw();
	}

	override function destroy() {
		super.destroy();
		text.destroy();
	}
}