package funkin.objects.funkui;

class FunkButton extends FourSideSprite implements IFunkUIObject {
	private var text:FlxFunkText;
	public var ogX:Float;
	public var ogY:Float;
	
	public var label(default, set):String = "";
	function set_label(value:String):String {
		return text.text = label = value;
	}

	public var callback:Void->Void = null;
	
	public function new(?X:Float, ?Y:Float, Label:String = "abc", ?Callback:Void->Void, Color:Int = 0xff1F6AA4) {
		super(X, Y, Std.int(Math.max(125, Label.length * 9)), 25, Color);

		ogX = X;
		ogY = Y;

		text = new FunkUIText(X,Y,Label,width);
		text.alignment = "center";

		callback = Callback;
	}

	public function setUIPosition(X:Float, Y:Float) {
		setPosition(X,Y);
		text.setPosition(X, Y + 1);
	}

	static final HIGHLIGHT_COLOR:Int = 0xFFC8C7C7;
	static final PRESS_COLOR:Int = 0xFF808080;

	var targetColor:FlxColor = FlxColor.WHITE;

	override function update(elapsed:Float) {
		super.update(elapsed);
		
		if (FlxG.mouse.overlaps(this)) {
			targetColor = HIGHLIGHT_COLOR;
			if (FlxG.mouse.justPressed) {
				text.color = color = PRESS_COLOR;
				onClick();
			}
		} else {
			targetColor = FlxColor.WHITE;
		}

		if (color != targetColor) {
			text.color = color = FlxColor.interpolate(color, targetColor, elapsed * 10);
		}
	}

	function onClick() {
		if (callback != null) {
			callback();
		}
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