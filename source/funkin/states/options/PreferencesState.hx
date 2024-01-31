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
            var back = new FlxSprite(0, y - 10).makeGraphic(1, 1, FlxColor.BLACK);
            back.antialiasing = false;
            back.scale.set(FlxG.width, 85);
            back.updateHitbox();
            back.alpha = 0.4;
            add(back);
            
            var title = new Alphabet(FlxG.width * .5, y, switch (header) {
                case "GAMEPLAY": FlxG.random.bool(5) ? "GAYPLAY" : header;
                default: header;
            });
            title.alignment = CENTER;
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

        for (item in prefItems) {
            item.selected = false;
            if (curSelected == item.ID) {
                item.selected = true;
                camFollow.y = item.y + FlxG.height * .25;
                curItem = item;
            }
        }
    }

    function selectPref() {
        final leftP:Bool = getKey('UI_LEFT-P');
		final rightP:Bool = getKey('UI_RIGHT-P');
		final accepted:Bool = getKey('ACCEPT-P');

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
            if (leftP)  item.setValue(item.array[FlxMath.wrap(item.getArrIndex()-1, 0, item.array.length - 1)]);
            if (rightP) item.setValue(item.array[FlxMath.wrap(item.getArrIndex()+1, 0, item.array.length - 1)]);
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