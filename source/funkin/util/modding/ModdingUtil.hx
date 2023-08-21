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
    public static var playStateScripts:Array<FunkScript> = [];
    public static var globalScripts:Array<FunkScript> = [];
    public static var scriptsMap:Map<String, FunkScript>;

    inline public static function clearScripts(global:Bool = false):Void {
        scriptsMap = new Map<String, FunkScript>();
        FunkScript.globalVariables = new Map<String, Dynamic>();
        global ? globalScripts : playStateScripts = [];
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

    inline public static function addScript(path:String, global:Bool = false, ?tag:String):Null<FunkScript> {
        var scriptCode:String = CoolUtil.getFileContent(path);
        if (path.contains('//') || scriptCode.length <= 0) return null; // Dont load empty scripts

        consoleTrace('[ADD] $path / $global', FlxColor.LIME);
        var script:FunkScript = new FunkScript(scriptCode);
        script.scriptID = path;
        scriptsMap.set(tag == null ? path : tag, script);
        (global ? globalScripts : playStateScripts).push(script);
        return script;
    }

    inline public static function setModFolder(modName:String, activated:Bool):Void {
        modFoldersMap.set(modName, activated);
        SaveData.flushData();
    }

    inline public static function errorTrace(text:String):Void {
        consoleTrace('[ERROR] $text', FlxColor.RED);
    }

    inline public static function consoleTrace(text:String, ?color:Int):Void {
        var console = MusicBeatState.game.scriptConsole;
        console.exists ? console.consoleTrace(text, color) : console.addToTraceList(text, color);
    }

    inline public static function addCall(name:String, ?args:Array<Dynamic>, global:Bool = false):Void {
        for (script in (global ? globalScripts : playStateScripts)) {
            script.callback(name, args);
        }
    }

    public static function getScriptList(folder:String = 'data/scripts/global', assets:Bool = true, globalMod:Bool = true, curMod:Bool = true, allMods:Bool = false):Array<String> {
        #if !desktop return []; #end
        var scriptList:Array<String> = assets ? Paths.getFileList(TEXT, true, 'hx', 'assets/$folder') : [];
        return scriptList.concat(Paths.getModFileList(folder, 'hx', true, globalMod, curMod, allMods));
    }
}