package funkin;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

class Controls {
    public static var controlBindings:Map<String, Array<String>>;
    public static var controlGamepadBindings:Map<String, Array<String>>;
    public static var controlArray:Array<String> = [];
    public static var gamepad:FlxGamepad = null;

    // Returns if the controler is being used
	inline public static function inGamepad():Bool
    {
        var bool = gamepad == null;
        if (!bool)
            bool = gamepad.connected;
        return !bool;
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
        if (FlxG.gamepads.lastActive != null) {
            gamepad = FlxG.gamepads.lastActive;
        }
    }

    inline public static function setupBindings():Void {
        controlArray = [];
		controlBindings = SaveData.getSave('controls').get('keyboardBinds');
		controlGamepadBindings = SaveData.getSave('controls').get('gamepadBinds');
        initGamepads();

        addBinding('NOTE_LEFT',  ['D', 'LEFT'],           ['DPAD_LEFT',  'LEFT_STICK_DIGITAL_LEFT']);
        addBinding('NOTE_DOWN',  ['F', 'DOWN'],           ['DPAD_DOWN',  'LEFT_STICK_DIGITAL_DOWN']);
        addBinding('NOTE_UP',    ['J', 'UP'],             ['DPAD_UP',    'LEFT_STICK_DIGITAL_UP']);
        addBinding('NOTE_RIGHT', ['K', 'RIGHT'],          ['DPAD_RIGHT', 'LEFT_STICK_DIGITAL_RIGHT']);

        addBinding('UI_LEFT',    ['A', 'LEFT'],           ['DPAD_LEFT',  'LEFT_STICK_DIGITAL_LEFT']);
        addBinding('UI_DOWN',    ['S', 'DOWN'],           ['DPAD_DOWN',  'LEFT_STICK_DIGITAL_DOWN']);
        addBinding('UI_UP',      ['W', 'UP'],             ['DPAD_UP',    'LEFT_STICK_DIGITAL_UP']);
        addBinding('UI_RIGHT',   ['D', 'RIGHT'],          ['DPAD_RIGHT', 'LEFT_STICK_DIGITAL_RIGHT']);

        addBinding('ACCEPT',     ['ENTER', 'SPACE'],      ['START','A']);
        addBinding('BACK',       ['BACKSPACE', 'ESCAPE'], ['BACK','B']);
        addBinding('PAUSE',      ['ENTER', 'ESCAPE'],     ['START','A']);
        addBinding('RESET',      ['R'],                   ['RIGHT_STICK_CLICK']);

        SaveData.flushData();
    }

    inline public static function getKey(bind:String):Bool {
        bind = bind.toUpperCase().trim();
		var bindParts:Array<String> = bind.split('-');
		var bindName:String = bindParts[0];
		var bindType:String = (bindParts[1] != null) ? bindParts[1] : '';

		var bindArray:Array<FlxKey> = [];
		for (bind in controlBindings.get(bindName))
			bindArray.push(FlxKey.fromString(bind));

		var gamepadBindArray:Array<FlxGamepadInputID> = [];
        for (bind in controlGamepadBindings.get(bindName))
            gamepadBindArray.push(FlxGamepadInputID.fromString(bind));

		return checkKey(bindType, bindArray, gamepadBindArray);
    }

    inline private static function checkKey(bindType:String = '', bindArray:Array<FlxKey>, gamepadBindArray:Array<FlxGamepadInputID>):Bool {
        if (inGamepad()) {
            switch (bindType.toUpperCase().trim()) {
                case 'R':   return gamepad.anyJustReleased(gamepadBindArray);    //  Release Key
                case 'P':   return gamepad.anyJustPressed(gamepadBindArray);     //  Press Key
                default:    return gamepad.anyPressed(gamepadBindArray);         //  Hold Key
            }
        } else {
            switch (bindType.toUpperCase().trim()) {
                case 'R':   return FlxG.keys.anyJustReleased(bindArray);    //  Release Key
                case 'P':   return FlxG.keys.anyJustPressed(bindArray);     //  Press Key
                default:    return FlxG.keys.anyPressed(bindArray);         //  Hold Key
            }
        }
    }

    inline public static function getBinding(bind:String):Array<String> {
        bind = bind.toUpperCase().trim();
        var bindingStuff:Array<String> = inGamepad() ? controlGamepadBindings.get(bind) : controlBindings.get(bind);
        return bindingStuff;
    }

    inline public static function setBinding(bind:String, key:String, index:Int):Void {
        bind = bind.toUpperCase().trim();
        key = key.toUpperCase().trim();
        var lastSettings:Array<String> = (inGamepad() ? controlGamepadBindings : controlBindings).get(bind);
        lastSettings[index] = key;
        (inGamepad() ? controlGamepadBindings : controlBindings).set(bind, lastSettings);
        SaveData.flushData();
    }

    inline public static function addBinding(bind:String, keys:Array<String>, gamepadKeys:Array<String>):Void {
        bind = bind.toUpperCase().trim();
        for (i in 0...keys.length) {
            keys[i] = keys[i].toUpperCase().trim();
        }
        controlArray.push(bind);
        if (!controlBindings.exists(bind))          controlBindings.set(bind, keys);
        if (!controlGamepadBindings.exists(bind))   controlGamepadBindings.set(bind, gamepadKeys);
    }

    inline public static function getNoteKeys(type:String = ""):Array<Bool> {
        return [getKey('NOTE_LEFT$type'), getKey('NOTE_DOWN$type'), getKey('NOTE_UP$type'), getKey('NOTE_RIGHT$type')];
    }
}