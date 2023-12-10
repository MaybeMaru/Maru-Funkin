package funkin.objects.funkui;

class FunkDropDown extends FourSideSprite implements IFunkUIObject {
	public var ogX:Float;
	public var ogY:Float;

    private var openButton:FourSideSprite;
    private var text:FunkUIText;

    public function new(?X:Float, ?Y:Float, Width:Int = 125) {
        super(X, Y, Width, 25, 0xff2068A3);
        ogX = X;
        ogY = Y;

        final btnPos = Width * 0.8;
        text = new FunkUIText(X,Y,"Value",btnPos,25,14);

        openButton = new FourSideSprite(X,Y,Width,25,0xff1F3A4F);
        openButton.pixels.fillRect(new Rectangle(0, 0, btnPos, 25), FlxColor.TRANSPARENT);
        this.pixels.fillRect(new Rectangle(btnPos, 0, Width - btnPos, 25), FlxColor.TRANSPARENT);

        final arrow = new FlxSprite("assets/images/ui/arrow.png");
        openButton.stamp(arrow, Std.int(btnPos + (arrow.width * 0.25)), Std.int(arrow.height * 0.25));
        arrow.destroy();
    }

    public function setUIPosition(X:Float, Y:Float) {
        setPosition(X,Y);
        text.setPosition(X + 4, Y + 3);
        openButton.setPosition(X,Y);
    }

    override function draw() {
        super.draw();
        text.draw();
        openButton.draw();
    }

    override function destroy() {
        super.destroy();
        openButton = FlxDestroyUtil.destroy(openButton);
        text = FlxDestroyUtil.destroy(text);
    }
}