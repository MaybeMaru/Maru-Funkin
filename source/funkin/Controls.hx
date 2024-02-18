package funkin;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

enum abstract InputType(Int) from Int to Int {
    var RELEASED = -1;
    var PRESSED = 0;
    var JUST_PRESSED = 1;
    var JUST_RELEASED = 2;
}

class Controls
{
    public static var controlBindings:Map<String, Array<String>>;
    public static var controlGamepadBindings:Map<String, Array<String>>;
    public static var controlArray:Array<String> = [];
    public static var gamepad:FlxGamepad = null;

    // Returns if the controler is being used
	inline public static function inGamepad():Bool {
        return gamepad?.connected ?? false;
    }

    inline public static function addGamepad(newGamepad:FlxGamepad):Void {
        gamepad = newGamepad;
    }

    inline public static function removeGamepad(deviceDisconnected:FlxGamepad):Void {
        gamepad = null;
    }

    inline public static function initGamepads():Void {
        FlxG.gamepads.deviceConnected.add(addGamepad);
        FlxG.gamepads.deviceDisconnected.add(removeGamepad);
        if (FlxG.gamepads.lastActive != null)
            gamepad = FlxG.gamepads.lastActive;
    }

    inline public static function setupBindings():Void {
        controlArray = [];
		controlBindings = SaveData.getSave('controls').get('keyboardBinds');
		controlGamepadBindings = SaveData.getSave('controls').get('gamepadBinds');
        initGamepads();

        /****/addHeader("NOTES");/****/
        
        addBinding('NOTE_LEFT',  ['D', 'LEFT'],           ['DPAD_LEFT',  'LEFT_STICK_DIGITAL_LEFT']);
        addBinding('NOTE_DOWN',  ['F', 'DOWN'],           ['DPAD_DOWN',  'LEFT_STICK_DIGITAL_DOWN']);
        addBinding('NOTE_UP',    ['J', 'UP'],             ['DPAD_UP',    'LEFT_STICK_DIGITAL_UP']);
        addBinding('NOTE_RIGHT', ['K', 'RIGHT'],          ['DPAD_RIGHT', 'LEFT_STICK_DIGITAL_RIGHT']);

        /****/addHeader("UI");/****/

        addBinding('UI_LEFT',    ['A', 'LEFT'],           ['DPAD_LEFT',  'LEFT_STICK_DIGITAL_LEFT']);
        addBinding('UI_DOWN',    ['S', 'DOWN'],           ['DPAD_DOWN',  'LEFT_STICK_DIGITAL_DOWN']);
        addBinding('UI_UP',      ['W', 'UP'],             ['DPAD_UP',    'LEFT_STICK_DIGITAL_UP']);
        addBinding('UI_RIGHT',   ['D', 'RIGHT'],          ['DPAD_RIGHT', 'LEFT_STICK_DIGITAL_RIGHT']);

        /****/addHeader("MISCELLANEOUS");/****/

        addBinding('ACCEPT',     ['ENTER', 'SPACE'],      ['START','A']);
        addBinding('BACK',       ['BACKSPACE', 'ESCAPE'], ['BACK','B']);
        addBinding('PAUSE',      ['ENTER', 'ESCAPE'],     ['START','A']);
        addBinding('RESET',      ['R'],                   ['RIGHT_STICK_CLICK']);

        SaveData.flushData();
    }

    inline public static function getKey(key:String, inputType:InputType = PRESSED):Bool {
        final gamepad = inGamepad();
        var keys:Array<Int> = [];
        key = key.toUpperCase();

        if (gamepad) {
            controlGamepadBindings.get(key).fastForEach((string, i) -> {
                keys.push(FlxGamepadInputID.fromStringMap.get(string));
            });
        }
        else {
            controlBindings.get(key).fastForEach((string, i) -> {
                keys.push(FlxKey.fromStringMap.get(string));
            });
        }

        return checkKey(inputType, keys, gamepad);
    }

    inline private static function checkKey(inputType:InputType, keys:Array<Int>, isGamepad:Bool):Bool {
        return switch (inputType) {
            case RELEASED: isGamepad ? !gamepad.anyPressed(keys) : !FlxG.keys.anyPressed(keys);
            case PRESSED: isGamepad ? gamepad.anyPressed(keys) : FlxG.keys.anyPressed(keys);
            case JUST_PRESSED: isGamepad ? gamepad.anyJustPressed(keys) : FlxG.keys.anyJustPressed(keys);
            case JUST_RELEASED: isGamepad ? gamepad.anyJustReleased(keys) : FlxG.keys.anyJustReleased(keys);
        }
    }

    //@:deprecated("Use getKey with the inputType argument instead")
    inline public static function getKeyOld(key:String):Bool {
        key = key.toUpperCase();
		var parts:Array<String> = key.split('-');

        return getKey(parts[0], switch (parts[1]) {
            case "R": JUST_RELEASED;
            case "P": JUST_PRESSED;
            default: PRESSED;
        });
    }

    inline public static function getBinding(bind:String):Array<String> {
        bind = bind.toUpperCase().trim();
        return inGamepad() ? controlGamepadBindings.get(bind) : controlBindings.get(bind);
    }

    inline public static function setBinding(bind:String, key:String, index:Int):Void {
        bind = bind.toUpperCase().trim();
        key = key.toUpperCase().trim();
        final lastSettings:Array<String> = (inGamepad() ? controlGamepadBindings : controlBindings).get(bind);
        lastSettings[index] = key;
        (inGamepad() ? controlGamepadBindings : controlBindings).set(bind, lastSettings);
        SaveData.flushData();
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

    inline public static function addBinding(bind:String, keys:Array<String>, gamepadKeys:Array<String>):Void {
        bind = bind.toUpperCase().trim();
        for (i in 0...keys.length)
            keys[i] = keys[i].toUpperCase().trim();
       
        controlArray.push(bind);
        headerContents.get(curHeader).push(bind);
        
        if (!controlBindings.exists(bind))          controlBindings.set(bind, keys);
        if (!controlGamepadBindings.exists(bind))   controlGamepadBindings.set(bind, gamepadKeys);
    }
}