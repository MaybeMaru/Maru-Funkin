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
		text.setPosition(X,Y);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		
		if (FlxG.mouse.overlaps(this)) {
			if (FlxG.mouse.justPressed) {
				text.color = color = FlxColor.GRAY;
				onClick();
			}
		}

		if (color != FlxColor.WHITE) {
			text.color = color = FlxColor.interpolate(color, FlxColor.WHITE, elapsed * 10);
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