package funkin.states.editors;

/*
    The idea is to make a quick creator for mod templates
    just adding the essentials quickly with drag n drop and shit
*/

import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIInputText;
import sys.io.File;

/*
    Add WEEKS
    Add SONGS
 */

class ModSetupTabs extends FlxUITabMenu {
    var tabGroup:FlxUI;
    
    var modNameInput:FlxUIInputText;
    var modDescInput:FlxUIInputText;

    var focusList:Array<FlxUIInputText> = [];
	public function getFocus():Bool {
		for (i in focusList) if (i.hasFocus) return true;
		return false;
	}
    
    public function new() {
        super(null,[{name:"Setup Mod Folder", label: "Setup Mod Folder"}], true);
        setPosition(50,50);
        resize(400, 400);
        selected_tab = 0;

        tabGroup = new FlxUI(null, this);
		tabGroup.name = "Setup Mod Folder";
        addGroup(tabGroup);

        modNameInput = new FlxUIInputText(25, 25, 300, "Template Mod");
        addToGroup(modNameInput, "Mod Name:", true);
    }

    function addToGroup(object:Dynamic, txt:String = "", focusPush:Bool = false) {
        if (focusPush && object is FlxUIInputText) focusList.push(object);
        if (txt.length > 0) tabGroup.add(new FlxText(object.x - 50, object.y - 85, 0, txt));
        tabGroup.add(object);
    }
}

class ModSetupState extends MusicBeatState {
    var modTab:ModSetupTabs;
    
    override function create() {
        var bg = new FunkinSprite("menuDesat");
        bg.setScale(1.25,false);
        bg.color = 0xff353535;
        add(bg);

        FlxG.mouse.visible = true;
        modTab = new ModSetupTabs();
        add(modTab);

        /*setOnDrop(function (path:String) {
            trace("DROPPED FILE FROM: " + Std.string(path));
            var newPath = "./" + "mods/test/images/crap.png";
            File.copy(path, newPath);
        });*/
        
        //setupModFolder('sexMod');

        super.create();
    }

    static var modFolderDirs(default, never):Map<String, Array<String>> = [
        "images" => ["characters", "skins", "storymenu"],
        "data" => ["characters", "notetypes", "scripts", "stages", "weeks", "events", "skins"],
        "songs" => [],
        "music" => [],
        "sounds" => [],
        "fonts" => [],
        "videos" => []
    ];

    // Creates a mod folder template
    function setupModFolder(name:String) {
        for (k in modFolderDirs.keys()) {
            var keyArr = modFolderDirs.get(k);
            createFolderWithTxt('$name/$k');
            for (i in keyArr) createFolderWithTxt('$name/$k/$i');
        }
    }

    function createFolderWithTxt(path:String) {
        var pathParts = path.split("/");
        createFolder(path);
        File.saveContent('mods/$path/${pathParts[pathParts.length-1]}-go-here.txt', "");
    }

    function createFolder(path:String) {
        var dirs = path.split("/");
        var lastDir = "mods/";
        for (i in dirs) {
            if (i == null) continue;
            lastDir += '$i/';
            if (!FileSystem.exists(lastDir)) {  // Create subdirectories
                FileSystem.createDirectory(lastDir);
            }
        }
    }

    function setOnDrop(func:Dynamic) {
        FlxG.stage.window.onDropFile.removeAll();
        FlxG.stage.window.onDropFile.add(func);
    }

    override function destroy() {
        super.destroy();
        FlxG.stage.window.onDropFile.removeAll();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (modTab.getFocus()) return;
        if (getKey('BACK-P')) {
            switchState(new MainMenuState());
        }
    }
}