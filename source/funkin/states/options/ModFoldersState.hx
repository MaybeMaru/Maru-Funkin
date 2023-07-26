package funkin.states.options;
import funkin.states.options.items.ModItem;
import funkin.states.options.items.SpriteButton;

class ModFoldersState extends MusicBeatState {
    var modFolderButtons:FlxTypedGroup<SpriteButton>;
    var modFolderItems:FlxTypedGroup<ModItem>;
    var sliderPos:Float = 0;

    override function create():Void {
        FlxG.mouse.visible = true;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);

        modFolderItems = new FlxTypedGroup<ModItem>();
        add(modFolderItems);

        var modIndex:Int = 0;
        for (mod in ModdingUtil.modFolders) {
            var newMod:ModItem = new ModItem(mod, modIndex);
            newMod.x = 25;
            newMod.targetY = 0;
            newMod.y = newMod.targetY;
            modFolderItems.add(newMod);
            modIndex++;
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
        CoolUtil.init();
        CoolUtil.playMusic('freakyMenu');
        FlxG.resetState();
    }

    function enableAll():Void {
        enableMods(true);
    }

    function disableAll():Void {
        enableMods(false);
    }

    function enableMods(bool:Bool):Void {
        for (folder in modFolderItems.members) {
            folder.modEnabled = bool;
            ModdingUtil.setModFolder(folder.modName, bool);
            folder.updateUI();
        }
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        
        if (getKey('BACK-P')) {
            FlxG.switchState(new OptionsState());
        }

        if(FlxG.mouse.wheel != 0 && (modFolderItems.length > 3)) {
            var limit:Int = Std.int(modFolderItems.length-3);
            sliderPos += FlxG.mouse.wheel;
            if (sliderPos>0)                sliderPos = 0;
            else if (sliderPos < -limit)    sliderPos = -limit;
		}

        for (item in modFolderItems) {
            item.targetY = 50 + (sliderPos-item.modID+modFolderItems.members.length-1)*200;
        }
    }
}