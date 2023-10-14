package funkin.states.options.items;

class SettingItem extends FlxSpriteGroup {
    private var usePrefs:Bool = true;
    private var settingTxt:Alphabet;
    public var settingType:String = '';

    private var checkboxSpr:FunkinSprite;       //Bool
    public var  numSetSpr:Alphabet;             //Number
    //private var arraySetSpr:Alphabet;         //Array

    public var stringID:String = '';

    public var itemPref:String = 'lmao';
    public var targetY:Float = 0;
    public var selected:Bool = false;

    public var prefValue:Dynamic;

    public function new(prefName:String = 'cool', description:String = 'swag', usePrefs:Bool = true, ?daValue:Dynamic):Void {
        super();
        this.usePrefs = usePrefs;
        itemPref = prefName;
        prefValue = usePrefs ? Preferences.getPref(itemPref) : daValue;

        var varType = Type.typeof(prefValue);
        switch (varType) {
            default:            settingType = 'bool';
            case TInt | TFloat: settingType = 'num';
            case TClass(Array): settingType = 'array';
        }

        settingTxt = new Alphabet(20, 100, description);
        add(settingTxt);

        switch (settingType) {
            case 'bool':
                checkboxSpr = new FunkinSprite('options/optionCheckbox');
                checkboxSpr.scale.set(0.8,0.8);
                checkboxSpr.updateHitbox();
                checkboxSpr.addAnim('open','open');
                checkboxSpr.addAnim('close','close',24,false,null,[25,0]);
                checkboxSpr.addAnim('staticOpen','staticOpen',24,false,null,[-17,-37]);
                checkboxSpr.addAnim('staticClose','staticClose',24,false,null,[-22,-60]);
                add(checkboxSpr);
                checkboxSpr.playAnim(prefValue ? 'staticOpen' : 'staticClose');
                settingTxt.x += checkboxSpr.width * checkboxSpr.scale.x;

            case 'num':
                numSetSpr = new Alphabet(20, 100,'< $prefValue >');
                add(numSetSpr);
                settingTxt.x += numSetSpr.x + numSetSpr.width;
        }
    }

    public function setValue(newValue:Dynamic):Void {
        prefValue = newValue;

        //hardcoded limits
        if (settingType == 'num') {
            switch (itemPref) {
                case 'framerate':   prefValue = Std.int(FlxMath.bound(prefValue, 60, 240));
                case 'const-speed': prefValue = FlxMath.roundDecimal(FlxMath.bound(prefValue, 0.1, 10.0), 1);
                default:            prefValue = FlxMath.bound(prefValue, 0, 999);
            }
        }
    
        CoolUtil.playSound('scrollMenu');
        if (usePrefs) {
            Preferences.setPref(itemPref, prefValue);
            Preferences.effectPrefs();
        }

        switch (settingType) {
            case 'bool':
                checkboxSpr.playAnim(prefValue ? 'open' : 'close');
            case 'num':
                var prefStr = Std.string(prefValue);
                switch (itemPref) {
                    case "const-speed": if (prefStr.length <= 1) prefStr += ".0";
                }

                numSetSpr.text = "< " + prefStr + " >";
                settingTxt.x = 20 + numSetSpr.x + numSetSpr.width;
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (selected) {
            settingTxt.color = FlxColor.YELLOW;
            settingTxt.alpha = 1;
        } else {
            settingTxt.color = FlxColor.WHITE;
            settingTxt.alpha = 0.6;
        }

        y = CoolUtil.coolLerp(y, targetY, 0.16);
    }
}