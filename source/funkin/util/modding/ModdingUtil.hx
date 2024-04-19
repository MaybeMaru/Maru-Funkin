package funkin.util.modding;

import flixel.util.FlxArrayUtil;

typedef ModFolder = {
    var title:String;
    var description:String;
    var icon:String;
    var global:Bool;
    var hideBaseGame:Bool;
    var apiVersion:Int;
    
    @:optional var ?folder:String; // This is used internally, dont worry about it
}

/*
 * API VERSIONS
 * -1 => Beta 1 (And earlier versions)
 * 0 => Beta 2
 */

class ModdingUtil
{
    public static var folderExceptions(default, never):Array<String> = ['data', 'fonts', 'images', 'music', 'songs', 'videos', 'sounds'];
    public static inline var API_VERSION:Int = 0;
    public static final DEFAULT_MOD:ModFolder = {
        title: "Empty Mod",
        description: "This mod has no description.",
        icon: "icon",
        global: false,
        hideBaseGame: false,
        apiVersion: API_VERSION
    }
    
    //Mod folders
    public static var curModFolder(default, set):String = "";
    public static var curModData:ModFolder = null;
    public static var modsList:Array<ModFolder> = [];
    public static var modsMap:Map<String, ModFolder> = [];

    static function set_curModFolder(?value:String) {
        if (value == null)
            value = "";

        curModFolder = value;
        curModData = value.length > 0 ? modsMap.get(value) : null;
        
        return value;
    }
    
    public static var activeMods:Map<String, Bool> = [];
    public static var globalMods:Array<ModFolder> = [];
    
    //Scripts
    public static var scripts:Array<FunkScript> = [];
    public static var scriptsMap:Map<String, FunkScript> = [];

    public static function clearScripts():Void
    {
        FunkScript.globalVariables.clear();
        #if DEV_TOOLS
        if (Main.console != null)
            Main.console.clear();
        #end
        
        scripts.copy().fastForEach((script, i) -> removeScript(script));
        scripts.clear();

        // Warn if the mod folder is outdated
        if (curModData != null) if (curModData.apiVersion != API_VERSION)
            warningPrint('$curModFolder / Uses API version ${curModData.apiVersion} (Cur $API_VERSION)');
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

                    if (Paths.exists(_jsonPath, TEXT))
                    {
                        data = JsonUtil.checkJson(DEFAULT_MOD, Json.parse(CoolUtil.getFileContent(_jsonPath)));
                    }
                    else
                    {
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

    inline public static function addScriptFolder(folder:String) {
        addScriptList(getScriptList(folder));
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

    public static function removeScript(?script:FunkScript) {
        if (script != null) {
            if (scriptsMap.exists(script.scriptID))
                scriptsMap.remove(script.scriptID);

            script.destroy();
            scripts.remove(script);
        }

        return null;
    }

    inline public static function removeScriptByTag(tag:String) {
        removeScript(scriptsMap.get(tag));
    }

    inline public static function setModActive(modID:String, active:Bool):Void {
        activeMods.set(modID, active);
        SaveData.flushData();
    }

    inline public static function getModActive(modID:String):Bool {
        return activeMods.get(modID) ?? false;
    }

    public static function existsModFolder(folder:String):Bool {
        for (mod in modsList) {
            if (mod.folder == folder)
                return true;
        }
        return false;
    }

    inline public static function addPrint(txt:String)      print(txt, ADD);
    inline public static function errorPrint(txt:String)    print(txt, ERROR);
    inline public static function warningPrint(txt:String)  print(txt, WARNING);
    inline public static function print(text:String, type:PrintType):Void {
        #if DEV_TOOLS
        Main.console.print(text, type);
        #else
        trace("[" + type + "] " + text);
        #end
    }

    /**Calls a method in all the scripts**/
    public static function addCall(name:String, args:Array<Dynamic> = null):Void
    {
        scripts.fastForEach((script, i) -> {
            if (script != null) if (script.active)
                script.safeCall(name, args);
        });
    }

    /**Calls a method in all the scripts and returns if they called ``STOP_FUNCTION`` or not**/
    public static function getCall(name:String, args:Array<Dynamic> = null):Bool
    {
        var calledStop:Bool = false;
        
        scripts.fastForEach((script, i) -> {
            if (script != null) if (script.active)
                if (script.safeCall(name, args) == STOP_FUNCTION)
                    calledStop = true;
        });

        return calledStop;
    }

    public static function getSubFolderScriptList(folder:String= 'data/scripts/global', ?subFolders:Array<String>)
    {
        if (subFolders == null)
            subFolders = new Array<String>();
        
        var subFolderList:Array<String> = getScriptList(folder);
        subFolders.fastForEach((subfolder, i) -> {
            getScriptList(folder + "/" + subfolder).fastForEach((item, i) -> subFolderList.push(item));
        });
        
        return subFolderList;
    }

    public static function getScriptList(folder:String = 'data/scripts/global', assets:Bool = true, globalMod:Bool = true, curMod:Bool = true, allMods:Bool = false):Array<String>
    {
        var scripts = assets ? Paths.getFileList(TEXT, true, 'hx', 'assets/$folder') : [];

        #if MODS_ALLOWED
        var modScripts = Paths.getModFileList(folder, 'hx', true, globalMod, curMod, allMods);
        scripts.fastForEach((script, i) -> modScripts.push(script));
        return overrideScripts(modScripts);
        #else
        return scripts;
        #end
    }

    static function overrideScripts(scripts:Array<String>) {
        final _overrides:Array<String> = [];
        final list:Array<String> = [];

        for (i in scripts) {
            final parts = i.split("/");
            final base = parts[parts.length - 2] + "/" + parts[parts.length - 1];
            if (_overrides.contains(base)) // File has override already
                continue;

            _overrides.push(base);
            list.push(i);
        }

        return list;
    }

    public static inline function runFunctionMod(mod:String, func:()->Void) {
        final lastMod = curModFolder;
        curModFolder = mod;
        func();
        curModFolder = lastMod;
    }

    public static inline function runFunctionMods(mods:Array<String>, func:()->Void) {
        final lastMod = curModFolder;
        mods.fastForEach((mod, i) -> {
            curModFolder = mod;
            func();
        });
        curModFolder = lastMod;
    }
}