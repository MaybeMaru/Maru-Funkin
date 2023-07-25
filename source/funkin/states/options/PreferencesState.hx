package funkin.states.options;
import funkin.states.options.items.SettingItem;

class PreferencesState extends MusicBeatState {
    var curSelected:Int = 0;
    var prefItems:FlxTypedGroup<SettingItem>;

    override function create():Void {
        persistentUpdate = true;
		persistentDraw = true;

        var bg:FunkinSprite = new FunkinSprite('menuBGBlue');
        bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.screenCenter();
        add(bg);

        prefItems = new FlxTypedGroup<SettingItem>();
        add(prefItems);

        var prefsArray:Array<String> = Preferences.prefsArray;
        for (i in 0...prefsArray.length) {
            var pref:String = prefsArray[i];
            var prefLabel = Preferences.getLabel(pref);
            var prefSetting:SettingItem = new SettingItem(pref, prefLabel);
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

    override function update(elapsed:Float):Void {
        super.update(elapsed);

		if (getKey('UI_UP-P'))    changeSelection(-1);
		if (getKey('UI_DOWN-P'))  changeSelection(1);
        
        var leftP = getKey('UI_LEFT-P');
		var rightP = getKey('UI_RIGHT-P');
		var accepted = getKey('ACCEPT-P');

        if (accepted || leftP || rightP) {
            for (item in prefItems) {
                if (item.ID == curSelected) {
                    switch (item.settingType) {
                        case 'bool':
                            if (accepted) {
                                if (item.itemPref == 'naughty' && !item.prefValue)  //  Tankman easteregg
                                    CoolUtil.playSound('chart/naughty_on');

                                item.setValue(!item.prefValue);
                            }
                            
                        case 'num':
                            var mult:Int = (FlxG.keys.pressed.SHIFT) ? 5 : 1;
                            if (leftP || rightP) {
                                if (leftP)  item.setValue(item.prefValue-mult);
                                if (rightP) item.setValue(item.prefValue+mult);
                            }
                    }
                    break;
                }
            }
        }

        if (getKey('BACK-P')) {
            Preferences.savePrefs();
            FlxG.switchState(new OptionsState());
        }
    }
}