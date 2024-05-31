package funkin.states.options;
import funkin.states.options.items.PrefItem;

class PreferencesState extends MusicBeatState {
    var curSelected:Int = 0;
    var prefItems:Array<PrefItem> = [];
    var camFollow:FlxObject;

    var initQuality:String;

    override function create():Void {
        persistentUpdate = persistentDraw = true;
        initQuality = Preferences.getPref("quality");

        camFollow = new FlxObject(FlxG.width * .5, 0);
        FlxG.camera.follow(camFollow, null, 0.16);
        add(camFollow);

        var bg:FunkinSprite = new FunkinSprite('menuBGBlue');
        bg.scrollFactor.set();
        bg.setScale(1.1);
		bg.screenCenter();
        add(bg);

        var id:Int = 0;
        var y:Float = 0;

        for (header in Preferences.headers) {
            var back = new FlxSpriteExt(0, y - 10).makeRect(FlxG.width, 85, FlxColor.BLACK);
            back.alpha = 0.4;
            add(back);
            
            var title = new Alphabet(0, y, switch (header) {
                case "GAMEPLAY": FlxG.random.bool(5) ? "GAYPLAY" : header;
                default: header;
            });
            title.screenCenter(X);
            add(title);

            y += 40;

            for (pref in Preferences.headerContents.get(header)) {
                var label = Preferences.getLabel(pref);
                var item = new PrefItem(pref, label);
                item.ID = id;
                prefItems.push(item);
                add(item);

                item.y = y;

                id++;
                y += 125;
            }

            y += 90;
        }

        changeSelection();
        FlxG.camera.focusOn(camFollow.getPosition());
        super.create();
    }

    var curItem:PrefItem;

    function changeSelection(change:Int = 0):Void {
        curSelected = FlxMath.wrap(curSelected + change, 0, prefItems.length - 1);
        if (change != 0) CoolUtil.playSound('scrollMenu');

        prefItems.fastForEach((item, i) -> {
            if (item.ID == curSelected) {
                item.selected = true;
                camFollow.y = item.y + FlxG.height * .25;
                curItem = item;
            }
            else item.selected = false;
        });
    }

    function selectPref() {
        final leftP:Bool = getKey('UI_LEFT', JUST_PRESSED);
		final rightP:Bool = getKey('UI_RIGHT', JUST_PRESSED);
		final accepted:Bool = getKey('ACCEPT', JUST_PRESSED);

        if (accepted || leftP || rightP) {
            if (curItem != null) {
                switch (curItem.type) {
                    case BOOL: handleBool(curItem, accepted, leftP, rightP);
                    case NUMBER: handleNumber(curItem, accepted, leftP, rightP);
                    case ARRAY: handleArray(curItem, accepted, leftP, rightP);
                }
            }
        }
    }

    function handleBool(item:PrefItem, accepted:Bool, leftP:Bool, rightP:Bool) {
        if (accepted) {
            switch(item.itemPref) {
                case 'naughty': if (!item.prefValue) CoolUtil.playSound('chart/naughty_on'); //  Tankman easteregg
                case 'antialiasing': FlxSprite.defaultAntialiasing = !item.prefValue;
            }
            item.setValue(!item.prefValue);
        }
    }

    function handleNumber(item:PrefItem, accepted:Bool, leftP:Bool, rightP:Bool) {
        var mult:Float = (FlxG.keys.pressed.SHIFT) ? 5 : 1;
        switch(item.itemPref) {
            case 'const-speed': mult *= 0.1;
            default:
        }
        if (leftP || rightP) {
            if (leftP)  item.setValue(item.prefValue - mult);
            if (rightP) item.setValue(item.prefValue + mult);
        }
    }

    function handleArray(item:PrefItem, accepted:Bool, leftP:Bool, rightP:Bool) {
        if (leftP || rightP) {
            if (leftP)  item.setValue(item.array[FlxMath.wrap(item.getArrIndex() - 1, 0, item.array.length - 1)]);
            if (rightP) item.setValue(item.array[FlxMath.wrap(item.getArrIndex() + 1, 0, item.array.length - 1)]);
        }
    }

    var hitBack:Bool = false;

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        if (!hitBack) {
            if (getKey('UI_UP', JUST_PRESSED))    changeSelection(-1);
            if (getKey('UI_DOWN', JUST_PRESSED))  changeSelection(1);
            selectPref();
    
            if (getKey('BACK', JUST_PRESSED)) {
                SaveData.flushData();
                hitBack = true;
                switchState(new OptionsState());
            }
        }
    }

    override function destroy() {
        super.destroy();

        // Clear all assets from cache on quality change
        var newQuality = Preferences.getPref("quality");
        if (newQuality != initQuality) {
            AssetManager.clearAllCache(true, false);
            AssetManager.setLodQuality(newQuality);
        }
    }
}