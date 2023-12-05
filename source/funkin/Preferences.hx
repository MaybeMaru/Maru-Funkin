package funkin;

typedef ArrayPref = {array:Array<String>, value:String};

class Preferences {
    public static var prefsArray:Array<String>;
    public static var preferences:Map<String, Dynamic>;
    public static var prefsLabels:Map<String, String>;
    
    public static var arrayPrefs:Map<String, ArrayPref> = [];

    public static function setupPrefs():Void {        
        prefsArray = [];
        preferences = SaveData.getSave('preferences');
        prefsLabels = new Map<String, String>();

        // Miscellaneous
        addPref('naughty',        'naughtyness',     true);

        // Gameplay
        addPref('botplay',        'botplay mode',    false);
        addPref('practice',       'practice mode',   false);
        addPref('downscroll',     'downscroll',      false);
        addPref('ghost-tap-style', 'ghost tapping', {array:["dad turn", "off", "on"], value: "off"});
        
        addPref('stack-rating',   'stack ratings',   false);
        addPref('use-const-speed', 'use constant speed', false);
        addPref('const-speed', 'constant speed', 1.0);

        // UI
        addPref('framerate',      'framerate',       60);
        addPref('fps-counter',    'fps counter',     true);
        addPref('vanilla-ui',     'vanilla ui',      false);
        addPref('flashing-light', 'flashing lights', true);
        addPref('camera-zoom',    'camera zooms',    true);
        
        // Performance
        addPref('antialiasing',   'antialiasing',    true);
        #if !hl
        addPref('clear-gpu',      'clear gpu cache', false);
        addPref('preload',        'preload at start', true);
        #end

        SaveData.flushData();
        effectPrefs();
        fixOldPrefs();
    }

    public static function addPref(id:String, label:String, defaultValue:Dynamic):Void {
        id = id.toLowerCase().trim();
        prefsArray.push(id);

        prefsLabels.set(id, label);
        if (Reflect.hasField(defaultValue, "array")) arrayPrefs.set(id, defaultValue);
        if (!preferences.exists(id)) preferences.set(id, defaultValue);
    }

    public static function effectPrefs():Void {
        FlxG.drawFramerate = FlxG.updateFramerate = getPref('framerate');
        FlxSprite.defaultAntialiasing = getPref('antialiasing');

        if (Main.fpsCounter != null) {
            Main.fpsCounter.visible = getPref('fps-counter');
        }
    }

    private static function fixOldPrefs() {
        if (preferences.exists("ghost-tap")) {
            if (preferences.get("deghost-tap")) {
                setPref("ghost-tap-style", "dad turn");
                preferences.remove("deghost-tap");
            }
            else setPref("ghost-tap-style", preferences.get("ghost-tap") ? "on" : "off");
            preferences.remove("ghost-tap");
            SaveData.flushData();
        }
    }

    inline public static function getPref(pref:String):Dynamic {
        final pref:Dynamic = preferences.get(pref.toLowerCase().trim());
        #if !hl return  pref?.value ?? pref;
        #else   return Reflect.hasField(pref, "value") ? pref.value : pref; #end
    }

    inline public static function setPref(pref:String, value:Dynamic):Void {
        final _id = pref.toLowerCase().trim();
        
        if (arrayPrefs.exists(_id)) {
            final _arrPref = arrayPrefs.get(_id);
            _arrPref.value = value;
            preferences.set(_id, _arrPref);
        }
        else {
            preferences.set(_id, value);
        }
        
        SaveData.flushData();
    }

    inline public static function getLabel(pref:String):String {
        return prefsLabels.get(pref.toLowerCase().trim());
    }
}