package funkin.util.modding;

class ModdingUtil {
    //Mod folders
    public static var curModFolder:String = "";
    public static var modFolders:Array<String> = [];
    public static var modFoldersMap:Map<String, Bool> = [];
    private static var folderExceptions:Array<String> = [
        'data',
        'fonts',
        'images',
        'music',
        'songs',
        'sounds'
    ];
    
    //Scripts
    public static var scripts:Array<FunkScript> = [];
    public static var scriptsMap:Map<String, FunkScript> = [];

    inline public static function clearScripts():Void {
        scriptsMap.clear();
        FunkScript.globalVariables.clear();
        scripts = [];
    }

    inline public static function reloadModFolders():Void {
        modFoldersMap = SaveData.getSave('activeMods');
        modFolders = getModFolderList();
        getDefModFolder();

        SaveData.flushData();
    }

    public static function getDefModFolder():Void {
        if (modFolders.length > 0) {
            for (mod in modFolders) {
                if (modFoldersMap.get(mod)) {
                    curModFolder = mod;
                    trace(curModFolder);
                    return;
                }
            }
        }
        curModFolder = "";
    }

    inline public static function getModFolderList():Array<String> {
		var list:Array<String> = [];
		#if desktop
		if (FileSystem.exists('mods')) {
			for (folder in FileSystem.readDirectory('mods')) {
                if (!folderExceptions.contains(folder) && FileSystem.isDirectory('mods/$folder')) {
                    if (!modFoldersMap.exists(folder)) {
                        modFoldersMap.set(folder, true);
                    }
                    list.push(folder);
                }
			}
		}
		#end
		return list;
	}

    inline public static function addScript(path:String, ?tag:String):Null<FunkScript> {
        var scriptCode:String = CoolUtil.getFileContent(path);
        if (path.contains('//') || scriptCode.length <= 0) return null; // Dont load empty scripts
        consoleTrace('[ADD] $path', FlxColor.LIME);
        var script:FunkScript = new FunkScript(scriptCode);
        script.scriptID = path;
        scriptsMap.set(tag == null ? path : tag, script);
        scripts.push(script);
        return script;
    }

    inline public static function removeScript(tag:String) {
        if (!scriptsMap.exists(tag)) return;
        var script = scriptsMap.get(tag);
        scriptsMap.remove(tag);
        scripts.remove(script);
    }

    inline public static function setModFolder(modName:String, activated:Bool):Void {
        modFoldersMap.set(modName, activated);
        SaveData.flushData();
    }

    inline public static function errorTrace(text:String):Void {
        consoleTrace('[ERROR] $text', FlxColor.RED);
    }

    inline public static function consoleTrace(text:String, ?color:Int):Void {
        var console = MusicBeatState.instance.scriptConsole;
        console.exists ? console.consoleTrace(text, color) : ScriptConsole.addToTraceList(text, color);
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
        subFolders = subFolders == null ? [] : subFolders;
        var subFolderList:Array<String> = [];
        for (i in subFolders)
            subFolderList = subFolderList.concat(getScriptList(folder + "/" + i));
        return getScriptList(folder).concat(subFolderList);
    }

    public static function getScriptList(folder:String = 'data/scripts/global', assets:Bool = true, globalMod:Bool = true, curMod:Bool = true, allMods:Bool = false):Array<String> {
        var scriptList:Array<String> = assets ? Paths.getFileList(TEXT, true, 'hx', 'assets/$folder') : [];
        return scriptList.concat(Paths.getModFileList(folder, 'hx', true, globalMod, curMod, allMods));
    }
}