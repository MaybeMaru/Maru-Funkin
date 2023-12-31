package funkin.states.options;
import funkin.states.options.items.ModItem;
import funkin.states.options.items.SpriteButton;

class ModFoldersState extends MusicBeatState {
    var modFolderButtons:FlxTypedGroup<SpriteButton>;
    var modItemsGrp:FlxTypedGroup<ModItem>;
    var sliderPos:Float = 0;

    override function create():Void {
        FlxG.mouse.visible = true;

        var bg:FlxSpriteExt = new FlxSpriteExt().loadImage("menuBGBlue");
        bg.setScale(1.1);
        bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);

        modItemsGrp = new FlxTypedGroup<ModItem>();
        add(modItemsGrp);

        for (i in 0...ModdingUtil.modsList.length) {
            final modItem:ModItem = new ModItem(ModdingUtil.modsList[i]);
            modItem.ID = i;
            modItem.setPosition(25, 0);
            modItemsGrp.add(modItem);
        }

        modFolderButtons = new FlxTypedGroup<SpriteButton>();
        add(modFolderButtons);

        var folderOptions:Array<String> = ['Reload', 'Enable', 'Disable'];
        var folderCallbacks:Array<Void->Void> = [reloadFolders, enableAll, disableAll];
        for (i in 0...folderOptions.length) {
            var daButton:SpriteButton = new SpriteButton(1000, (150*i)+100, folderOptions[i], folderCallbacks[i]);
            modFolderButtons.add(daButton);
        }

        super.create();
    }

    function reloadFolders():Void {
        SaveData.flushData();
        CoolUtil.init();
        CoolUtil.playMusic('freakyMenu');
        CoolUtil.resetState();
    }

    inline function enableAll():Void {
        enableMods(true);
    }

    inline function disableAll():Void {
        enableMods(false);
    }

    function enableMods(bool:Bool):Void {
        for (i in modItemsGrp) {
            i.enabled = bool;
            ModdingUtil.setModActive(i.mod.folder, bool);
            i.updateUI();
        }
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        
        if (getKey('BACK-P')) {
            switchState(new OptionsState());
        }

        if(FlxG.mouse.wheel != 0 && (modItemsGrp.length > 3)) {
            final limit:Int = Std.int(modItemsGrp.length-3);
            sliderPos = FlxMath.bound(sliderPos + FlxG.mouse.wheel, -limit, 0);
		}

        for (item in modItemsGrp) {
            item.targetY = 50 + (sliderPos-item.ID+modItemsGrp.members.length-1)*200;
        }
    }
}