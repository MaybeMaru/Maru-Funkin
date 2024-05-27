package funkin.states.options;
import funkin.states.options.items.ModItem;
import funkin.states.options.items.SpriteButton;
#if ZIPS_ALLOWED
import haxe.io.Path;
import funkin.util.backend.SongZip;
#end

class ModFoldersState extends MusicBeatState
{
    var modFolderButtons:TypedGroup<SpriteButton>;
    var modItemsGrp:TypedGroup<ModItem>;
    var sliderPos:Float = 0;

    // Find changes for reload
    var initEnabled:Map<String, Bool>;
    var initMusic:String;

    override function create():Void
    {
        FlxG.mouse.visible = true;
        initEnabled = ModdingUtil.activeMods.copy();
        initMusic = Paths.musicFolder("freakyMenu");

        var bg:FlxSpriteExt = new FlxSpriteExt().loadImage("menuBGBlue");
        bg.setScale(1.1);
        bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);

        modItemsGrp = new TypedGroup<ModItem>();
        add(modItemsGrp);

        ModdingUtil.modsList.fastForEach((mod, i) -> {
            final modItem:ModItem = new ModItem(mod);
            modItem.ID = i;
            modItem.setPosition(25, 0);
            modItemsGrp.add(modItem);
        });

        modFolderButtons = new TypedGroup<SpriteButton>();
        add(modFolderButtons);

        for (i in 0...3) {
            var button:SpriteButton = new SpriteButton(975, (150 * i) + 50,
                ["Reload", "Enable", "Disable"][i],
                [reloadFolders, enableAll, disableAll][i]
            );
            modFolderButtons.add(button);
        }

        super.create();

        #if ZIPS_ALLOWED
        FlxG.stage.window.onDropFile.removeAll();
        FlxG.stage.window.onDropFile.add(function (file:String) {
            var extension = Path.extension(file).toLowerCase();
            if (SongZip.zipMap.exists(extension))
            {
                var newPath = "./mods/" + Path.withoutDirectory(file);
                sys.io.File.copy(file, newPath);
                reloadFolders();
            }
            else
            { // Invalid mod zip format
                CoolUtil.playSound("rejectMenu");
            }
        });
        #end
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
        modItemsGrp.members.fastForEach((mod, i) -> {
            mod.enabled = bool;
            ModdingUtil.setModActive(mod.mod.folder, bool);
            mod.updateUI();
        });
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        
        if (getKey('BACK', JUST_PRESSED))
        {
            for (mod => active in initEnabled)
            {
                // Changed settings, reload mods shit
                if (active != ModdingUtil.getModActive(mod)) {
                    ModdingUtil.reloadMods();
                    SkinUtil.setCurSkin();
                    NoteUtil.initTypes();
                    EventUtil.initEvents();

                    // Mod overrides music
                    if (Paths.musicFolder("freakyMenu") != initMusic)
                        CoolUtil.playMusic('freakyMenu');

                    break;
                }
            }

            switchState(new OptionsState());
        }
        else if (modItemsGrp.length > 3) if (FlxG.mouse.wheel != 0) {
            final limit:Int = modItemsGrp.length - 3;
            sliderPos = FlxMath.bound(sliderPos + FlxG.mouse.wheel, -limit, 0);
		}

        modItemsGrp.members.fastForEach((item, i) -> {
            item.targetY = 50 + (sliderPos - item.ID + modItemsGrp.members.length - 1) * 200;
        });
    }

    #if ZIPS_ALLOWED
    override function destroy() {
        super.destroy();
        FlxG.stage.window.onDropFile.removeAll();
    }
    #end
}