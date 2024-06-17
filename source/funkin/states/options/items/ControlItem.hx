package funkin.states.options.items;

class ControlItem extends SpriteGroup
{
    public var key:String = '';
    public var selected:Bool = false;
    public var bindSelected:Int = 0;
    public var curBind:String = '';

    public var keyText:Alphabet;
    public var bind1Text:Alphabet;
    public var bind2Text:Alphabet;

    public function new(key:String = '', bind1:String = '', bind2:String = ''):Void {
        super(150);

        this.key = key;

        keyText = new Alphabet(0, 0, key.contains("_") ? key.split("_")[1] : key, true);
        add(keyText);

        bind1Text = new Alphabet(400, 0, bind1, false);
        bind2Text = new Alphabet(800, 0, bind2, false);
        add(bind1Text);
        add(bind2Text);
    }

    public function updateDisplay() {
        if (selected) {
            keyText.color = FlxColor.YELLOW;
            keyText.alpha = 1;
            bind1Text.alpha = bind2Text.alpha = 0.6;

            final bindText = (bindSelected == 0) ? bind1Text : bind2Text;
            bindText.alpha = 1;
            curBind = bindText.text.toUpperCase().trim();
        }
        else {
            keyText.color = FlxColor.WHITE;
            keyText.alpha = bind1Text.alpha = bind2Text.alpha = 0.6;
        }
    }
}