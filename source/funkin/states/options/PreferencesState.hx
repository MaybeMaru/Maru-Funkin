package funkin.states.options;
import funkin.states.options.items.SettingItem;

class PreferencesState extends MusicBeatState {
    var curSelected:Int = 0;
    var prefItems:FlxTypedGroup<SettingItem>;

    override function create():Void {
        persistentUpdate = true;
		persistentDraw = true;

        final bg:FunkinSprite = new FunkinSprite('menuBGBlue');
        bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.screenCenter();
        add(bg);

        prefItems = new FlxTypedGroup<SettingItem>();
        add(prefItems);

        final prefsArray:Array<String> = Preferences.prefsArray;
        for (i in 0...prefsArray.length) {
            final pref:String = prefsArray[i];
            final prefLabel = Preferences.getLabel(pref);
            final prefSetting:SettingItem = new SettingItem(pref, prefLabel);
            prefSetting.targetY = (i + (prefsArray.length/10))*125;
            prefSetting.y = prefSetting.targetY;
            prefSetting.ID = i;
            prefItems.add(prefSetting);
        }
        changeSelection();
        super.create();
    }

    function changeSelection(change:Int = 0):Void {
        curSelected = FlxMath.wrap(curSelected + change, 0, prefItems.length - 1);
        if (change != 0) CoolUtil.playSound('scrollMenu');

        for (item in prefItems.members) {
            item.targetY = (item.ID - curSelected + (prefItems.length/10))*125;
            item.selected = false;
            if (curSelected == item.ID) {
                item.selected = true;
            }
        }
    }

    function selectPref() {
        final leftP = getKey('UI_LEFT-P');
		final rightP = getKey('UI_RIGHT-P');
		final accepted = getKey('ACCEPT-P');

        if (accepted || leftP || rightP) {
            for (item in prefItems) {
                if (item.ID == curSelected) {
                    switch (item.settingType) {
                        case BOOL:
                            if (accepted) {
                                switch(item.itemPref) {
                                    case 'naughty': if (!item.prefValue) CoolUtil.playSound('chart/naughty_on'); //  Tankman easteregg
                                    case 'antialiasing': FlxSprite.defaultAntialiasing = !item.prefValue;
                                }
                                item.setValue(!item.prefValue);
                            }
                            
                        case NUMB:
                            var mult:Float = (FlxG.keys.pressed.SHIFT) ? 5 : 1;
                            switch(item.itemPref) {
                                case 'const-speed': mult *= 0.1;
                                default:
                            }
                            if (leftP || rightP) {
                                if (leftP)  item.setValue(item.prefValue-mult);
                                if (rightP) item.setValue(item.prefValue+mult);
                            }
                            
                        case ARRAY:
                    }
                    break;
                }
            }
        }
    }

    var hitBack:Bool = false;

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        if (!hitBack) {
            if (getKey('UI_UP-P'))    changeSelection(-1);
            if (getKey('UI_DOWN-P'))  changeSelection(1);
            selectPref();
    
            if (getKey('BACK-P')) {
                SaveData.flushData();
                hitBack = true;
                switchState(new OptionsState());
            }
        }
    }
}