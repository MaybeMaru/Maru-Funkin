package funkin.states.options.items;

enum PrefType {
    BOOL;
    NUMBER;
    ARRAY;
}

class PrefItem extends FlxSpriteGroup {
    private var usePrefs:Bool = true;
    private var settingTxt:Alphabet;
    public var type:PrefType = null;

    private var checkboxSpr:FunkinSprite;   //Bool
    public var  numSetSpr:Alphabet;         //Number
    public var array:Array<String>;         //Array     

    public var stringID:String = '';

    public var itemPref:String = 'lmao';
    public var selected:Bool = false;

    public var prefValue:Dynamic;

    public function new(prefName:String = 'cool', description:String = 'swag', usePrefs:Bool = true, ?daValue:Dynamic):Void {
        super();
        this.usePrefs = usePrefs;
        itemPref = prefName;
        prefValue = usePrefs ? Preferences.getPref(itemPref) : daValue;

        switch (Type.typeof(prefValue)) {
            default:            type = BOOL;
            case TInt | TFloat: type = NUMBER;
            case TClass(String):
                type = ARRAY;
                array = Preferences.arrayPrefs.get(itemPref).array.copy();
        }

        settingTxt = new Alphabet(20, 100, description);
        add(settingTxt);

        switch (type) {
            case BOOL:
                checkboxSpr = new FunkinSprite('options/optionCheckbox');
                checkboxSpr.scale.set(0.8,0.8);
                checkboxSpr.updateHitbox();
                checkboxSpr.addAnim('open', 'open');
                checkboxSpr.addAnim('close', 'close', 24, false, null, [25,0]);
                checkboxSpr.addAnim('staticOpen', 'staticOpen', 24, false, null, [-17,-37]);
                checkboxSpr.addAnim('staticClose', 'staticClose', 24, false, null, [-22,-60]);
                add(checkboxSpr);
                checkboxSpr.playAnim(prefValue ? 'staticOpen' : 'staticClose');
                settingTxt.x += checkboxSpr.width * checkboxSpr.scale.x;

            case NUMBER | ARRAY:
                numSetSpr = new Alphabet(20, 100,'< $prefValue >');
                add(numSetSpr);
                settingTxt.x += numSetSpr.x + numSetSpr.width;
        }
    }

    inline public function getArrIndex() {
        return array.indexOf(prefValue);
    }

    function applyAntiGroup(_members:Array<Dynamic>, anti:Bool = true) {
        for (i in _members) {
            switch(Type.typeof(i)) {
                case TClass(FunkinSprite) | TClass(AlphabetCharacter):
                    i.antialiasing = anti;
                case TClass(FlxTypedGroup) | TClass(PrefItem) | TClass(Alphabet):
                    applyAntiGroup(i.members ?? i.group.members, anti);
                default:
            } 
        }
    }

    public function setValue(newValue:Dynamic):Void {
        prefValue = newValue;

        //hardcoded limits
        if (type == NUMBER) {
            switch (itemPref) {
                case 'framerate':   prefValue = Std.int(FlxMath.bound(prefValue, 60, 240));
                case 'const-speed': prefValue = FlxMath.roundDecimal(FlxMath.bound(prefValue, 0.1, 10.0), 1);
                default:            prefValue = FlxMath.bound(prefValue, 0, 999);
            }
        }
    
        CoolUtil.playSound('scrollMenu');
        if (usePrefs) {
            Preferences.setPref(itemPref, prefValue);
            switch (itemPref) {
                case "framerate": Preferences.updateFramerate();
                case "fps-counter": Preferences.updateFpsCounter();
                case "resolution": Preferences.updateResolution();
                case "gpu-textures": Preferences.updateGpuTextures();
                case "antialiasing": applyAntiGroup(FlxG.state.members, cast prefValue);
            }
        }

        switch (type) {
            case BOOL: checkboxSpr.playAnim(prefValue ? 'open' : 'close');
            case NUMBER | ARRAY:
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
    }
}