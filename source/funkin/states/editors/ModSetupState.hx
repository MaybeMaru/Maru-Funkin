package funkin.states.editors;

/*
    The idea is to make a quick creator for mod templates
    just adding the essentials quickly with drag n drop and shit
*/

import flixel.addons.ui.FlxUICheckBox;
import funkin.substates.PromptSubstate;
import flixel.addons.ui.FlxUIButton;
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
    
    var modFolderInput:FlxUIInputText;
    var modNameInput:FlxUIInputText;
    var modDescInput:FlxUIInputText;
    var createButton:FlxUIButton;

    var templatesCheck:FlxUICheckBox;

    var focusList:Array<FlxUIInputText> = [];
	public function getFocus():Bool {
		for (i in focusList) if (i.hasFocus) return true;
		return false;
	}

    static var invalidFolderCharacters(default, never):Array<String> = ["/",":","*","?",'"',"<",">","|"];
    
    public function new() {
        super(null,[{name:"Setup Mod Folder", label: "Setup Mod Folder"}], true);
        setPosition(50,50);
        resize(400, 400);
        selected_tab = 0;

        tabGroup = new FlxUI(null, this);
		tabGroup.name = "Setup Mod Folder";
        addGroup(tabGroup);

        final _sep:Int = 35;

        modFolderInput = new FlxUIInputText(25, 25, 350, "Template Mod");
        addToGroup(modFolderInput, "Mod Folder:", true);

        modNameInput = new FlxUIInputText(25, 25 + _sep, 350, "Template Mod");
        addToGroup(modNameInput, "Mod Name:", true);

        modDescInput = new FlxUIInputText(25, 25 + _sep * 2, 350, "Get silly on a friday night yeah");
        modDescInput.lines = 999;
        addToGroup(modDescInput, "Mod Description:", true);

        createButton = new FlxUIButton(310, 350, "Create Folder", function () {
            final modFolder = modFolderInput.text;
            
            var keys:Array<String> = [];
            for (i in ModSetupState.modFolderDirs.keys()) keys.push(i);
            if (keys.contains(modFolder)) {
                CoolUtil.playSound("rejectMenu");
                return; // Invalid folder name
            }
            
            for (i in invalidFolderCharacters) {
                if (modFolder.contains(i)) {
                    CoolUtil.playSound("rejectMenu");
                    return; // Invalid folder character
                }
            }
            
            var createFunc = function () {
                ModSetupState.setupModFolder(modFolder);
                var _jsonData = JsonUtil.copyJson(ModdingUtil.DEFAULT_MOD);
                _jsonData.title = modNameInput.text;
                _jsonData.description = modDescInput.text;
            
                var _jsonStr = FunkyJson.stringify(_jsonData, "\t");
                File.saveContent('mods/$modFolder/mod.json', _jsonStr);
                CoolUtil.playSound('confirmMenu');
            }

            if (FileSystem.exists('mods/$modFolder')) {
                FlxG.state.openSubState(new PromptSubstate(
                    'Mod folder\n$modFolder\nalready exists\n\nAre you sure you want to\noverwrite this folder?',
                    createFunc));
            }
            else {
                createFunc();
            }
        });
        tabGroup.add(createButton);

        // If to include template character json, week json, songs, etc
        templatesCheck = new FlxUICheckBox(25, 250, null, null, "Include template files");
        templatesCheck.checked = false;
        tabGroup.add(templatesCheck);
    }

    function addToGroup(object:Dynamic, txt:String = "", focusPush:Bool = false) {
        if (focusPush && object is FlxUIInputText) focusList.push(object);
        if (txt.length > 0) tabGroup.add(new FlxText(object.x, object.y - 15, txt));
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

    public static var modFolderDirs(default, never):Map<String, Array<String>> = [
        "images" => ["characters", "skins", "storymenu", "icons"],
        "data" => ["characters", "notetypes", "scripts", "stages", "weeks", "events", "skins"],
        "songs" => [],
        "music" => [],
        "sounds" => [],
        "fonts" => [],
        "videos" => []
    ];

    // Creates a mod folder template
    public static function setupModFolder(name:String) {
        for (k in modFolderDirs.keys()) {
            var keyArr = modFolderDirs.get(k);
            createFolderWithTxt('$name/$k');
            for (i in keyArr) createFolderWithTxt('$name/$k/$i');
        }
    }

    static function createFolderWithTxt(path:String) {
        var pathParts = path.split("/");
        createFolder(path);
        File.saveContent('mods/$path/${pathParts[pathParts.length-1]}-go-here.txt', "");
    }

    public static function createFolder(path:String, prefix:String = "mods/") {
        var dirs = path.split("/");
        var lastDir = prefix;
        for (i in dirs) {
            if (i == null || i.contains(".")) continue;
            lastDir += '$i/';
            if (!FileSystem.exists(lastDir)) {  // Create subdirectories
                FileSystem.createDirectory(lastDir);
            }
        }
    }

    static function setOnDrop(func:Dynamic) {
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