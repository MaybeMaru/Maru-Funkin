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
		final bindParts:Array<String> = bind.split('-');
		final bindName:String = bindParts[0];
		final bindType:String = bindParts[1] ?? '';

        if (!inGamepad()) {
            final bindArray:Array<FlxKey> = [];
            for (bind in controlBindings.get(bindName)) bindArray.push(FlxKey.fromString(bind));
            return checkKey(bindType, FlxG.keys, bindArray);
        }
        else {
            final gamepadBindArray:Array<FlxGamepadInputID> = [];
            for (bind in controlGamepadBindings.get(bindName)) gamepadBindArray.push(FlxGamepadInputID.fromString(bind));
            return checkKey(bindType, gamepad, gamepadBindArray);
        }
    }

    inline private static function checkKey(bindType:String, controller:Dynamic, binds:Array<Dynamic>):Bool {
        return switch (bindType.toUpperCase().trim()) {
            case 'R':   controller.anyJustReleased(binds);    //  Release Key
            case 'P':   controller.anyJustPressed(binds);     //  Press Key
            default:    controller.anyPressed(binds);         //  Hold Key
        }
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

    inline public static function addBinding(bind:String, keys:Array<String>, gamepadKeys:Array<String>):Void {
        bind = bind.toUpperCase().trim();
        for (i in 0...keys.length) keys[i] = keys[i].toUpperCase().trim();
        controlArray.push(bind);
        if (!controlBindings.exists(bind))          controlBindings.set(bind, keys);
        if (!controlGamepadBindings.exists(bind))   controlGamepadBindings.set(bind, gamepadKeys);
    }
}