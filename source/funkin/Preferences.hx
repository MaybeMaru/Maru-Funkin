package funkin;

typedef ArrayPref = {array:Array<String>, value:String};

class Preferences
{
    public static var prefsArray:Array<String>;
    public static var preferences:Map<String, Dynamic>;
    public static var prefsLabels:Map<String, String>;
    
    public static var arrayPrefs:Map<String, ArrayPref> = [];
    
    #if desktop
    static inline var default_resolution:String = "1280x720";
    public static final resolutions:Array<String> = [
        "256x144",
        "640x360",
        "854x480",
        "960x540",
        "1024x576",
        "1280x720",
        "native"
    ];
    #end

    public static function setupPrefs():Void {        
        prefsArray = [];
        preferences = SaveData.getSave('preferences');
        prefsLabels = new Map<String, String>();

        /****/addHeader("GAMEPLAY");/****/

        addPref('botplay',        'botplay mode',    false);
        addPref('practice',       'practice mode',   false);
        addPref('downscroll',     'downscroll',      false);
        addPref('ghost-tap-style', 'ghost tapping', {array:["dad turn", "off", "on"], value:"off"});
        addPref('use-const-speed', 'use constant speed', false);
        addPref('const-speed', 'constant speed', 1.0);

        /****/addHeader("UI");/****/

        #if !mobile
        #if !web
        addPref('framerate',      'framerate',       60);
        #end
        addPref('fps-counter',    'fps counter',     true);
        #end
        addPref('vanilla-ui',     'vanilla ui',      false);
        addPref('stack-rating',   'stack ratings',   false);
        addPref('flashing-light', 'flashing lights', true);
        addPref('camera-zoom',    'camera zooms',    true);
        
        /****/addHeader("PERFORMANCE");/****/

        #if desktop
        addPref('resolution', 'resolution', {array:resolutions, value:default_resolution});
        #end
        addPref('antialiasing', 'antialiasing', true);
        addPref('quality', 'quality', {array:["rudy", "low", "medium", "high"], value:"high"});
        #if !TEXTURES_OFF
        addPref('gpu-textures', 'gpu textures', true);
        #end
        #if desktop
        #if lime_vorbis
        addPref('song-stream', 'stream songs', false);
        #end
        addPref('preload', 'preload at start', false);
        #end

        /****/addHeader("MISCELLANEOUS");/****/

        addPref('naughty', 'naughtyness', true);

        SaveData.flushData();
        fixOldPrefs();
    }

    private static var curHeader:String;
    public static var headers:Array<String> = [];
    public static var headerContents:Map<String, Array<String>> = [];

    static function addHeader(name:String) {
        if (name != curHeader) {
            curHeader = name;
            headerContents.set(name, []);
            headers.push(name);
        }
    }

    public static function addPref(id:String, label:String, defaultValue:Dynamic):Void {
        id = id.toLowerCase().trim();

        prefsArray.push(id);
        prefsLabels.set(id, label);
        headerContents.get(curHeader).push(id);
        
        if (Reflect.hasField(defaultValue, "array")) arrayPrefs.set(id, defaultValue);
        if (!preferences.exists(id)) preferences.set(id, defaultValue);
    }

    public static inline function updateFramerate():Void
        FlxG.drawFramerate = FlxG.updateFramerate = #if (mobile || web) 60; #else getPref('framerate'); #end

    public static inline function updateFpsCounter():Void
        #if !mobile Main.fpsCounter.visible = getPref('fps-counter'); #else {} #end

    public static inline function updateResolution():Void
        #if desktop Main.resizeGame(getPref('resolution')); #else {} #end

    public static inline function updateGpuTextures():Void
        #if TEXTURES_OFF {} #else AssetManager.gpuTextures = getPref('gpu-textures'); #end

    public static inline function updateAntialiasing():Void {
        var anti:Bool = getPref('antialiasing');
        FlxSprite.defaultAntialiasing = anti;
        for (key => data in NoteUtil.skinSpriteMap) {
            data.baseSprite.antialiasing = data.skinJson.antialiasing ? anti : false;
        }
    }

    public static function effectPrefs():Void {
        updateFramerate();
        updateFpsCounter();
        updateAntialiasing();
        AssetManager.setLodQuality(getPref('quality'));
        updateGpuTextures();
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

    public static function getPref(pref:String):Dynamic {
        final value:Dynamic = preferences.get(pref);
        
        if (arrayPrefs.exists(pref))
            return value.value;

        return value;
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