package funkin.objects.funkui;

class FunkDropDown extends FourSideSprite implements IFunkUIObject {
	public var ogX:Float;
	public var ogY:Float;

    private var openButton:FourSideSprite;
    private var text:FunkUIText;

    private var dropContainer:FourSideSprite;
    private var dropSelect:FourSideSprite;
    private var dropText:FunkUIText;

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

        dropSelect = new FourSideSprite(0, 0, Std.int((width * 0.875) - 12), 18, 0xff3559B5);
        dropText = new FunkUIText(0, 0, "", Std.int(width * 0.875), FlxG.height, 14);

        setList(["Value", "Ass", "Balls", "Fuck", "Puta Vida"]); // 
    }

    public var list(default, null):Array<Dynamic> = [];

    public function setList(array:Array<Dynamic>) {
        list = array;
        dropContainer = new FourSideSprite(0,0, Std.int(width * 0.875), (17*list.length) + 14, 0xff28272E, OUTLINE(2, 0xff535358));
        dropText.text = "";
        for (i in 0...list.length) {
            dropText.text += Std.string(list[i]) + "\n";
        }
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);

        dropSelect.visible = false;
        if (FlxG.mouse.overlaps(dropContainer))  {
            dropSelect.visible = true;
        }
    }

    public function setUIPosition(X:Float, Y:Float) {
        setPosition(X,Y);
        text.setPosition(X + 4, Y + 3);
        openButton.setPosition(X, Y);
        dropContainer.setPosition(X, Y + 28);
        dropSelect.setPosition(X + 6, Y + 34);
        dropText.setPosition(X + 8, Y + 34);
    }

    override function draw() {
        super.draw();
        text.draw();
        openButton.draw();
        dropContainer.draw();
        dropSelect.draw();
        dropText.draw();
    }

    override function destroy() {
        super.destroy();
        openButton = FlxDestroyUtil.destroy(openButton);
        text = FlxDestroyUtil.destroy(text);
        dropContainer = FlxDestroyUtil.destroy(dropContainer);
        dropSelect = FlxDestroyUtil.destroy(dropSelect);
        dropText = FlxDestroyUtil.destroy(dropText);
    }
}