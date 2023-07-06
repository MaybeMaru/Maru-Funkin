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

        var leType = Type.typeof(prefValue);
        if (leType == TBool)                            settingType = 'bool';
        else if (leType == TInt || leType == TFloat)    settingType = 'num';
        //if (leType == TClass(Array))            settingType = 'array';

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
        switch (itemPref) {
            case 'framerate':
                if (prefValue > 240)    prefValue = 240;
                if (prefValue < 60)     prefValue = 60;
        }
    
        CoolUtil.playSound('scrollMenu');
        if (usePrefs) {
            Preferences.setPref(itemPref, prefValue);
            Preferences.savePrefs();
            Preferences.effectPrefs();
        }

        switch (settingType) {
            case 'bool':
                checkboxSpr.playAnim(prefValue ? 'open' : 'close');
            case 'num':
                numSetSpr.makeText('< $prefValue >');
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