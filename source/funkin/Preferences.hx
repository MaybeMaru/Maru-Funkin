package funkin;
import flixel.util.FlxSave;

class Preferences {
    private static var prefsSaveFile:FlxSave;
    public static var prefsArray:Array<String>;
    public static var preferences:Map<String, Dynamic>;
    public static var prefsLabels:Map<String, String>;

    inline public static function setupPrefs():Void {
        prefsArray = [];
        preferences = new Map<String, Dynamic>();
        prefsLabels = new Map<String, String>();

        // Miscellaneous
        addPref('naughty',        'naughtyness',     true);
        //addPref('cache-songs',      'preload songs',    true);

        // Gameplay
        addPref('botplay',        'botplay mode',    false);
        addPref('practice',       'practice mode',   false);
        addPref('downscroll',     'downscroll',      false);
        addPref('ghost-tap',      'ghost tapping',   false);
        addPref('deghost-tap',    'deghostify',      false);
        addPref('stack-rating',   'stack ratings',   false);

        //addPref('shit-off',      'shit mil offset',  127);
        //addPref('bad-off',       'bad  mil offset',  106);
        //addPref('good-off',      'good mil offset',  43);

        // UI
        addPref('framerate',      'framerate',       60);   #if !mobile
        addPref('fps-counter',    'fps counter',     true); #end
        addPref('vanilla-ui',     'vanilla ui',      false);
        addPref('flashing-light', 'flashing lights', true);
        addPref('camera-zoom',    'camera zooms',    true);
        addPref('antialiasing',   'antialiasing',    true); #if desktop
        addPref('auto-pause',     'auto pause',      false);#end

        loadPrefs();
        savePrefs();
        effectPrefs();
    }

    inline public static function addPref(identifier:String, label:String, defaultValue:Dynamic):Void {
        identifier = identifier.toLowerCase().trim();
        prefsArray.push(identifier);
        preferences.set(identifier, defaultValue);
        prefsLabels.set(identifier, label);
    }

    inline public static function loadPrefs():Void {
        prefsSaveFile = new FlxSave();
        prefsSaveFile.bind('funkinPrefs');
        (prefsSaveFile.data.preferences == null) ? savePrefs() : preferences = prefsSaveFile.data.preferences;

        //  Double check lol
        for (pref in prefsArray) {
            if (prefsSaveFile.data.preferences.get(pref) == null) {
                savePrefs();
                preferences = prefsSaveFile.data.preferences;
                break;
            }
        }
    }

    inline public static function effectPrefs():Void {
        var gameFramerate:Int = getPref('framerate');
        FlxG.drawFramerate = gameFramerate;
		FlxG.updateFramerate = gameFramerate;

        if(Main.fpsCounter != null) {
            Main.fpsCounter.visible = getPref('fps-counter');
        }
    }

    inline public static function savePrefs():Void {
        prefsSaveFile.data.preferences = new Map<String, Array<String>>();
        prefsSaveFile.data.preferences = preferences;
        prefsSaveFile.flush();
    }

    inline public static function getPref(pref:String):Dynamic {
        pref = pref.toLowerCase().trim();
        var prefVar:Dynamic = preferences.get(pref);
        return prefVar;
    }

    inline public static function setPref(pref:String, value:Dynamic):Void {
        preferences.set(pref.toLowerCase().trim(), value);
    }

    inline public static function getLabel(pref:String):String {
        var prefLabel:String = prefsLabels.get(pref.toLowerCase().trim());
        return prefLabel;
    }
}