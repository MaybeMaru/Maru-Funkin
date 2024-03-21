package funkin;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

class Controls
{
    public static var keyboardBinds:Map<String, Array<FlxKey>>;
    public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;
    public static var controlArray:Array<String> = [];
    public static var gamepad:FlxGamepad = null;

    // Returns if the controler is being used
	inline public static function inGamepad():Bool {
        return gamepad != null ? gamepad.connected : false;
    }

    public static function connectGamepad(deviceConnected:FlxGamepad):Void {
        gamepad = deviceConnected;
    }

    public static function disconnectGamepad(deviceDisconnected:FlxGamepad):Void {
        gamepad = null;
    }

    inline public static function initGamepad():Void {
        FlxG.gamepads.deviceConnected.add(connectGamepad);
        FlxG.gamepads.deviceDisconnected.add(disconnectGamepad);
        if (FlxG.gamepads.lastActive != null)
            gamepad = FlxG.gamepads.lastActive;
    }

    static function initSave():Void {
        var save:Dynamic = SaveData.getSave("controls");
        var keyboardSave:Map<String, Array<Dynamic>> = save.get("keyboardBinds");
        var gamepadSave:Map<String, Array<Dynamic>> = save.get("gamepadBinds");

        // Fix for old versions
        var isOldSave:Bool = keyboardSave.exists("NOTE_LEFT") ? keyboardSave.get("NOTE_LEFT")[0] is String : false;
        if (isOldSave)
        {
            keyboardBinds = [];
            gamepadBinds = [];

            for (key => binds in keyboardSave) {
                var keyboard:Array<Int> = [-1, -1];
                var gamepad:Array<Int> = [-1, -1];

                binds.fastForEach((bind, i) -> {keyboard[i] = fromString(bind, false);});
                gamepadSave.get(key).fastForEach((bind, i) -> {gamepad[i] = fromString(bind, true);});

                keyboardBinds.set(key, keyboard);
                gamepadBinds.set(key, gamepad);
            }

            save.set("keyboardBinds", keyboardBinds);
            save.set("gamepadBinds", gamepadBinds);
        }
        else
        {
            keyboardBinds = cast keyboardSave;
            gamepadBinds = cast gamepadSave;
        }
    }

    public static function setupBindings():Void {
        controlArray = new Array<String>();
        initGamepad();
        initSave();

        /****/addHeader("NOTES");/****/
        
        addBind('NOTE_LEFT',  [D, LEFT],            [DPAD_LEFT,  LEFT_STICK_DIGITAL_LEFT]);
        addBind('NOTE_DOWN',  [F, DOWN],            [DPAD_DOWN,  LEFT_STICK_DIGITAL_DOWN]);
        addBind('NOTE_UP',    [J, UP],              [DPAD_UP,    LEFT_STICK_DIGITAL_UP]);
        addBind('NOTE_RIGHT', [K, RIGHT],           [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]);

        /****/addHeader("UI");/****/

        addBind('UI_LEFT',    [A, LEFT],            [DPAD_LEFT,  LEFT_STICK_DIGITAL_LEFT]);
        addBind('UI_DOWN',    [S, DOWN],            [DPAD_DOWN,  LEFT_STICK_DIGITAL_DOWN]);
        addBind('UI_UP',      [W, UP],              [DPAD_UP,    LEFT_STICK_DIGITAL_UP]);
        addBind('UI_RIGHT',   [D, RIGHT],           [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]);

        /****/addHeader("MISCELLANEOUS");/****/

        addBind('ACCEPT',     [ENTER, SPACE],       [START, A]);
        addBind('BACK',       [BACKSPACE, ESCAPE],  [BACK, B]);
        addBind('PAUSE',      [ENTER, ESCAPE],      [START, A]);
        addBind('RESET',      [R, NONE],            [RIGHT_STICK_CLICK, NONE]);

        SaveData.flushData();
    }

    public static function getKey(key:String, inputType:InputType = PRESSED):Bool {
        final isGamepad = inGamepad();
        key = key.toUpperCase();

        var keys:Array<Int> = isGamepad ? gamepadBinds.get(key) : keyboardBinds.get(key);

        return switch (inputType) {
            case RELEASED: isGamepad ? !gamepad.anyPressed(keys) : !checkPressed(keys);
            case PRESSED: isGamepad ? gamepad.anyPressed(keys) : checkPressed(keys);
            case JUST_PRESSED: isGamepad ? gamepad.anyJustPressed(keys) : checkJustPressed(keys);
            case JUST_RELEASED: isGamepad ? gamepad.anyJustReleased(keys) : checkJustReleased(keys);
        }
    }

    inline static function checkJustReleased(keys:Array<Int>)   return checkKeys(keys, -1);
    inline static function checkPressed(keys:Array<Int>)        return checkKeys(keys, 1);
    inline static function checkJustPressed(keys:Array<Int>)    return checkKeys(keys, 2);

    // Bindings will always be 2 keys that arent ANY, so we can make this unsafe
    static function checkKeys(keys:Array<Int>, status:Int):Bool @:privateAccess
    {
        for (i in 0...2) {
            final key = keys[i];
            if (key != NONE) if (FlxG.keys.checkStatusUnsafe(key, status))
                return true;
        }
        return false;
    }

    //@:deprecated("Use getKey with the inputType argument instead")
    public static function getKeyOld(key:String):Bool {
        key = key.toUpperCase();
		var parts:Array<String> = key.split('-');

        return getKey(parts[0], switch (parts[1]) {
            case "R": JUST_RELEASED;
            case "P": JUST_PRESSED;
            default: PRESSED;
        });
    }

    public static function getBindNames(bind:String):Array<String>
    {
        bind = bind.toUpperCase().trim();
        var names:Array<String> = ["", ""];
        
        if (inGamepad()) {
            var gamepadKeys = gamepadBinds.get(bind);
            gamepadKeys.fastForEach((key, i) -> {
                names[i] = FlxGamepadInputID.toStringMap.get(key);
            });
        }
        else {
            var keyboardKeys = keyboardBinds.get(bind);
            keyboardKeys.fastForEach((key, i) -> {
                names[i] = FlxKey.toStringMap.get(key);
            });
        }

        return names;
    }

    public static function setBind(bind:String, key:String, index:Int):Void {
        bind = bind.toUpperCase().trim();
        key = key.toUpperCase().trim();

        final gamepad:Bool = inGamepad();
        var binds:Array<Int> = gamepad ? gamepadBinds.get(bind) : keyboardBinds.get(bind);
        binds[index] = fromString(key, gamepad);

        gamepad ? gamepadBinds.set(bind, binds) : keyboardBinds.set(bind, binds);
        SaveData.flushData();
    }

    inline static function toString(int:Int, gamepad:Bool):String {
        return gamepad ? FlxGamepadInputID.toStringMap.get(int) : FlxKey.toStringMap.get(int);
    }

    inline static function fromString(str:String, gamepad:Bool):Int {
        return gamepad ? FlxGamepadInputID.fromStringMap.get(str) : FlxKey.fromStringMap.get(str);
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

    private static function addBind(bind:String, keys:Array<FlxKey>, gamepadKeys:Array<FlxGamepadInputID>):Void {
        bind = bind.toUpperCase().trim();       
        controlArray.push(bind);
        headerContents.get(curHeader).push(bind);
        
        if (!keyboardBinds.exists(bind))  keyboardBinds.set(bind, keys);
        if (!gamepadBinds.exists(bind))   gamepadBinds.set(bind, gamepadKeys);
    }
}