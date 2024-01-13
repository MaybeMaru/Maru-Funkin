package funkin.objects.funkui;

class DropDown extends FourSideSprite implements IUIObject {
	public var ogX:Float;
	public var ogY:Float;

    private var openButton:FourSideSprite;
    private var text:UIText;

    private var dropContainer:FourSideSprite;
    private var dropSelect:FourSideSprite;
    private var dropText:UIText;

    public function new(?X:Float, ?Y:Float, Width:Int = 125, ?List:Array<String>, ?DefaultValue:String) {
        super(X, Y, Width, 25, 0xff2068A3);
        ogX = X;
        ogY = Y;

        final btnPos = Width * 0.8;
        text = new UIText(X,Y,"",btnPos,25,14);

        openButton = new FourSideSprite(X,Y,Width,25,0xff1F3A4F);
        openButton.pixels.fillRect(new Rectangle(0, 0, btnPos, 25), FlxColor.TRANSPARENT);
        this.pixels.fillRect(new Rectangle(btnPos, 0, Width - btnPos, 25), FlxColor.TRANSPARENT);

        final arrow = new FlxSprite("assets/images/ui/arrow.png");
        openButton.stamp(arrow, Std.int(btnPos + (arrow.width * 0.25)), Std.int(arrow.height * 0.25));
        arrow.destroy();

        dropSelect = new FourSideSprite(0, 0, Std.int((width * 0.875) - 12), 18, 0xff3559B5);
        dropText = new UIText(0, 0, "", Std.int(width * 0.875), FlxG.height, 14);

        setList(List ?? []);
        setSelect(DefaultValue ?? list[0] ?? "Value");
        closeDropDown();
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
        
        if (open) {
            if (list.length > 0 && FlxG.mouse.overlaps(dropContainer))  {
                handleOverlap();
            }
            else {
                dropSelect.visible = false;
                curIndex = -1;
                curLabel = "";
            }
        }

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this)) {
            open ? closeDropDown() : openDropDown();
            color = FlxColor.GRAY;
        }

        if (color != FlxColor.WHITE) {
			text.color = openButton.color = color = FlxColor.interpolate(color, FlxColor.WHITE, elapsed * 10);
		}
    }

    public var curIndex(default, null):Int = -1;
    public var curLabel(default, null):String = "";

    function handleOverlap() {
        dropSelect.visible = true;

        final mousePos = FlxG.mouse.getScreenPosition(); // TODO: replace this with something more optimized later
        final textPos = dropText.getScreenPosition();

        curIndex = Std.int(FlxMath.bound((mousePos.y - textPos.y) * 0.058823529411, 0, list.length - 1));
        curLabel = list[curIndex];
        dropSelect.offset.y = curIndex * -17;

        if (FlxG.mouse.justPressed) {
            setSelect(curLabel);
            closeDropDown();
        }
    }
    
    public var selectedValue(default, null):String = "";

    function setSelect(value:String) {
        selectedValue = value;
        text.text = value;
    }

    public var open(default, null):Bool = false;

    public function closeDropDown() {
        dropContainer.visible = false;
        dropText.visible = false;
        dropSelect.visible = false;
        open = false;
    }

    public function openDropDown() {
        dropContainer.visible = true;
        dropText.visible = true;
        open = true;

        UIGlobal.lastObject = this;
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