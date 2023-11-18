package funkin.objects.ui;

class FunkButton extends FlxSprite {
	private var text:FlxFunkText;
	
	public var label(default, set):String = "";
	function set_label(value:String):String {
		return text.text = label = value;
	}
	
	public function new(?X:Float, ?Y:Float, Label:String = "guh", ?Callback:Dynamic, Color:FlxColor = FlxColor.WHITE, Outline:Float = 7) {
		super(X,Y);

		makeGraphic(150, 150, Color);
		pixels.fillRect(new Rectangle(Outline, Outline, width - (Outline * 2), height - (Outline * 2)), FlxColor.BLACK);
		text = new FlxFunkText(X,Y,Label,FlxPoint.weak(width,height));
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