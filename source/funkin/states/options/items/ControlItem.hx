package funkin.states.options.items;

class ControlItem extends FlxSpriteGroup {
    public var targetY:Float = 0;
    public var indexID:Int = 0;
    public var orderID:Int = 0;

    public var selected:Bool = false;
    public var bindSelected:Int = 0;
    public var curBind:String = '';

    public var keyText:Alphabet;
    public var bind1Text:Alphabet;
    public var bind2Text:Alphabet;

    private var titleOnly:Bool = false;

    public function new(key:String = '', bind1:String = '', bind2:String = '', targetY:Float = 0, titleOnly:Bool = false):Void {
        super();

        this.targetY = targetY;
        this.titleOnly = titleOnly;

        keyText = new Alphabet(0, 0, key, true);
        add(keyText);

        if (!titleOnly) {
            bind1Text = new Alphabet(400, 0, bind1, false);
            bind2Text = new Alphabet(800, 0, bind2, false);
            add(bind1Text);
            add(bind2Text);
        }

        y = targetY;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (!titleOnly) {
            var leAlpha:Float = 0.6;
            keyText.color = FlxColor.WHITE;
            keyText.alpha = leAlpha;
            bind1Text.alpha = leAlpha;
            bind2Text.alpha = leAlpha;

            if (selected) {
                keyText.color = FlxColor.YELLOW;
                keyText.alpha = 1;

                var bindText:Alphabet = (bindSelected == 0) ? bind1Text : bind2Text;
                bindText.alpha = 1;
                curBind = bindText.text.toUpperCase().trim();
            }
        }
        else {
            keyText.color = FlxColor.WHITE;
            keyText.alpha = 1;
        }

        y = CoolUtil.coolLerp(y, targetY, 0.16);
    }
}