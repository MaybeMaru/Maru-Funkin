package funkin.states.options.items;

class SpriteButton extends SpriteGroup
{
    public var clickCallback:()->Void;
    public var text:Alphabet;
    public var button:FunkinSprite;

    public function new(X:Float, Y:Float, buttonText:String = 'balls', ?clickCallback:()->Void, baseSpr:String = 'buttonSprite'):Void {
        super(X, Y);
        this.clickCallback = clickCallback;

        button = new FunkinSprite('options/$baseSpr', null, [0,0]);
        if (button.animated) {
            button.addAnim('loop', 'buttonSprite', 24, true);
            button.playAnim('loop');
        }
        button.setScale(0.6);
        add(button);

        text = new Alphabet(0, 0, buttonText, false);
        CoolUtil.positionInCenter(text, button);
        add(text);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        color = FlxColor.interpolate(color, FlxColor.WHITE, elapsed * 8);

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(button))
            onButtonClick();
    }

    function onButtonClick():Void {
        CoolUtil.playSound('scrollMenu');
        color = FlxColor.YELLOW;
        if (clickCallback != null) clickCallback();
    }
}