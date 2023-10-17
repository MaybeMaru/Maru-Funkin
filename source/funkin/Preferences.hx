package funkin;

class Preferences {
    public static var prefsArray:Array<String>;
    public static var preferences:Map<String, Dynamic>;
    public static var prefsLabels:Map<String, String>;

    inline public static function setupPrefs():Void {
        prefsArray = [];
        preferences = SaveData.getSave('preferences');
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
        addPref('use-const-speed', 'use constant speed', false);
        addPref('const-speed', 'constant speed', 1.0);

        //addPref('shit-off',      'shit mil offset',  127);
        //addPref('bad-off',       'bad  mil offset',  106);
        //addPref('good-off',      'good mil offset',  43);

        // UI
        addPref('framerate',      'framerate',       60);
        addPref('fps-counter',    'fps counter',     true);
        addPref('vanilla-ui',     'vanilla ui',      false);
        addPref('flashing-light', 'flashing lights', true);
        addPref('camera-zoom',    'camera zooms',    true);
        
        addPref('antialiasing',   'antialiasing',    true);
        addPref('clear-gpu',      'clear gpu cache', false);
        addPref('preload',        'preload at start', true);

        SaveData.flushData();
        effectPrefs();
    }

    inline public static function addPref(id:String, label:String, defaultValue:Dynamic):Void {
        id = id.toLowerCase().trim();
        prefsArray.push(id);

        prefsLabels.set(id, label);
        if (!preferences.exists(id)) preferences.set(id, defaultValue);
    }

    inline public static function effectPrefs():Void {
        final gameFramerate:Int = getPref('framerate');
        FlxG.drawFramerate = gameFramerate;
		FlxG.updateFramerate = gameFramerate;
        
        FlxSprite.defaultAntialiasing = getPref('antialiasing');

        if(Main.fpsCounter != null) {
            Main.fpsCounter.visible = getPref('fps-counter');
        }
    }

    inline public static function getPref(pref:String):Dynamic {
        return cast preferences.get(pref.toLowerCase().trim());
    }

    inline public static function setPref(pref:String, value:Dynamic):Void {
        preferences.set(pref.toLowerCase().trim(), value);
        SaveData.flushData();
    }

    inline public static function getLabel(pref:String):String {
        var prefLabel:String = prefsLabels.get(pref.toLowerCase().trim());
        return prefLabel;
    }
}