package funkin.util.modding;

import flixel.util.FlxArrayUtil;

typedef ModFolder = {
    var title:String;
    var description:String;
    var icon:String;
    var global:Bool;
    var apiVersion:Int;
    
    @:optional var ?folder:String; // This is used internally, dont worry about it
}

/*
 * API VERSIONS
 * -1 => Beta 1 (And earlier versions)
 * 0 => Beta 2
 */

class ModdingUtil {
    public static var folderExceptions(default, never):Array<String> = ['data', 'fonts', 'images', 'music', 'songs', 'videos', 'sounds'];
    public static inline var API_VERSION:Int = 0;
    public static final DEFAULT_MOD:ModFolder = {
        title: "Empty Mod",
        description: "This mod has no description.",
        icon: "icon",
        global: false,
        apiVersion: API_VERSION
    }
    
    //Mod folders
    public static var curModFolder(default, set):String = "";
    public static var curModData:ModFolder = null;
    public static var modsList:Array<ModFolder> = [];
    public static var modsMap:Map<String, ModFolder> = [];

    static function set_curModFolder(?value:String) {
        curModData = (value ?? "").length > 0 ? modsMap.get(value) : null;
        return curModFolder = value;
    }
    
    public static var activeMods:Map<String, Bool> = [];
    public static var globalMods:Array<ModFolder> = [];
    
    //Scripts
    public static var scripts:Array<FunkScript> = [];
    public static var scriptsMap:Map<String, FunkScript> = [];

    inline public static function clearScripts():Void {
        FunkScript.globalVariables.clear();
        Main.console.clear();
        for (i in scripts) removeScript(i);
        FlxArrayUtil.clearArray(scripts);

        // Warn if the mod folder is outdated
        if (curModData != null && curModData.apiVersion != API_VERSION) {
            warningPrint('$curModFolder / Uses API version ${curModData.apiVersion} (Cur $API_VERSION)');
        }
    }

    public static function reloadMods():Void {
        FlxArrayUtil.clearArray(modsList);
        FlxArrayUtil.clearArray(globalMods);
        modsMap.clear();
        
        activeMods = SaveData.getSave('activeMods');
        modsList = getModsList();
        for (i in modsList) {
            modsMap.set(i.folder, i);
            if (i.global && activeMods.get(i.folder)) globalMods.push(i);
        }
        getDefaultMod();

        SaveData.flushData();
    }

    static function getModsList():Array<ModFolder> {
        var list:Array<ModFolder> = [];
		#if desktop
		if (FileSystem.exists('mods')) {
			for (folder in FileSystem.readDirectory('mods')) {
                if (!folderExceptions.contains(folder) && FileSystem.isDirectory('mods/$folder')) {
                    var data:ModFolder = null;
                    final _folder = "mods/" + folder + "/";
                    final _jsonPath = _folder + "mod.json";

                    if (Paths.exists(_jsonPath, TEXT)) {
                        data = JsonUtil.checkJsonDefaults(DEFAULT_MOD, Json.parse(CoolUtil.getFileContent(_jsonPath)));
                    } else {
                        data = JsonUtil.copyJson(DEFAULT_MOD);
                        data.title = folder;
                        data.description = CoolUtil.getFileContent(_folder + "info.txt");
                        data.apiVersion = -1; // PRE-BETA 2 MOD FOLDER
                    }
                    data.folder = folder;

                    if (!activeMods.exists(data.folder)) activeMods.set(data.folder, true); // Set new mod active
                    list.push(data);
                }
			}
		}
		#end
        list.sort(function (a,b) return CoolUtil.sortAlphabetically(a.folder, b.folder));
		return list;
    }

    static function getDefaultMod() {
        curModFolder = "";
        if (modsList.length > 0) {
            for (i in modsList) {
                if (activeMods.get(i.folder)) {
                    curModFolder = i.folder;
                    trace('Set default mod folder to ' + curModFolder);
                    return;
                }
            }
        }
    }

    inline public static function addScriptList(list:Array<String>, ?tags:Array<String>) {
        tags = tags ?? [];
        for (i in 0...list.length)
            addScript(list[i], tags[i]);
    }

    public static function addScript(path:String, ?tag:String):Null<FunkScript> {
        var scriptCode:String = CoolUtil.getFileContent(path);
        if (path.contains('//') || scriptCode.length <= 0) return null; // Dont load empty scripts
        addPrint(path);
        final scriptID = tag ?? path;
        
        if (path.startsWith("mods/")) {
            final _mod = ModdingUtil.modsMap.get(Paths.getFileMod(path)[0]);
            if (_mod != null && _mod.apiVersion != API_VERSION)
                scriptCode = updateScript(scriptCode, _mod.apiVersion);
        }

        final script:FunkScript = new FunkScript(scriptCode, scriptID);
        scriptsMap.set(scriptID, script);
        scripts.push(script);
        return script;
    }
    
    static function updateScript(code:String, version:Int) {
        switch (version) {
            case -1: // BETA 1
                code = code.replace("PlayState", "State");
                code = code.replace("GameVars", "PlayState");
        }
        return code;
    }

    inline public static function removeScript(?script:FunkScript) {
        if (script != null) {
            if (scriptsMap.exists(script.scriptID)) {
                scriptsMap.remove(script.scriptID);
            }
            script.destroy();
            scripts.remove(script);
        }
    }

    inline public static function removeScriptByTag(tag:String) {
        removeScript(scriptsMap.get(tag));
    }

    inline public static function setModActive(modID:String, active:Bool):Void {
        activeMods.set(modID, active);
        SaveData.flushData();
    }

    inline public static function addPrint(txt:String)      print(txt, ADD);
    inline public static function errorPrint(txt:String)    print(txt, ERROR);
    inline public static function warningPrint(txt:String)  print(txt, WARNING);
    inline public static function print(text:String, type:PrintType):Void {
        Main.console.print(text, type);
    }

    inline public static function addCall(name:String, ?args:Array<Dynamic>):Bool {
        var calledStop:Bool = false;
        for (script in scripts) {
            if (script.callback(name, args) == STOP_FUNCTION) {
                calledStop = true;
            }
        }
        return calledStop;
    }

    public static function getSubFolderScriptList(folder:String= 'data/scripts/global', ?subFolders:Array<String>) {
        subFolders = subFolders ?? [];
        var subFolderList:Array<String> = [];
        for (i in subFolders) subFolderList = subFolderList.concat(getScriptList(folder + "/" + i));
        return getScriptList(folder).concat(subFolderList);
    }

    public static function getScriptList(folder:String = 'data/scripts/global', assets:Bool = true, globalMod:Bool = true, curMod:Bool = true, allMods:Bool = false):Array<String> {
        final assetScripts = assets ? Paths.getFileList(TEXT, true, 'hx', 'assets/$folder') : [];
        final modScripts = Paths.getModFileList(folder, 'hx', true, globalMod, curMod, allMods);
        
        final scripts = modScripts.concat(assetScripts); // mods go firts cuz reasons
        return overrideScripts(scripts); 
    }

    static function overrideScripts(scripts:Array<String>) {
        final _overrides:Array<String> = [];
        final list:Array<String> = [];

        for (i in scripts) {
            final parts = i.split("/");
            final base = parts[parts.length - 2] + "/" + parts[parts.length - 1];
            if (_overrides.contains(base)) continue; // File has override already

            _overrides.push(base);
            list.push(i);
        }

        return list;
    }
}