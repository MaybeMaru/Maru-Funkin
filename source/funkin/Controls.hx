package funkin;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxSave;

class Controls {
    private static var controlSaveFile:FlxSave;
    public static var controlBindings:Map<String, Array<String>>;
    public static var controlGamepadBindings:Map<String, Array<String>>;
    public static var controlArray:Array<String> = [];
    public static var gamepad:FlxGamepad = null;

    inline public static function addGamepad(newGamepad:FlxGamepad):Void {
        gamepad = newGamepad;
    }

    inline public static function removeGamepad(deviceDisconnected:FlxGamepad):Void {
        gamepad = null;
    }

    inline public static function initGamepads():Void {
        /*gamepad = new FlxGamepad(0,FlxG.gamepads);
        if (FlxG.gamepads.lastActive != null) {
            gamepad = FlxG.gamepads.lastActive;
        }*/
        FlxG.gamepads.deviceConnected.add(addGamepad);
        FlxG.gamepads.deviceDisconnected.add(removeGamepad);
        if (FlxG.gamepads.lastActive != null) {
            gamepad = FlxG.gamepads.lastActive;
        }
    }

    inline public static function setupBindings():Void {
        controlArray = [];
        controlBindings = new Map<String, Array<String>>();
        controlGamepadBindings = new Map<String, Array<String>>();
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

        loadBindings();
        saveBindings();
    }

    inline public static function getKey(bind:String):Bool {
        bind = bind.toUpperCase().trim();
        var bindParts:Array<String> = bind.split('-');
        var bindName:String  = bindParts[0];
        var bindType:String = (bindParts[1] != null) ? bindParts[1] : '';

        var bindArray:Array<FlxKey> = [];
        for (bind in controlBindings.get(bindName)) {
            bindArray.push(FlxKey.fromString(bind));
        }
        var gamepadBindArray:Array<FlxGamepadInputID> = [];
        for (bind in controlGamepadBindings.get(bindName)) {
            gamepadBindArray.push(FlxGamepadInputID.fromString(bind));
        }
        
        return checkKey(bindType,bindArray,gamepadBindArray);
    }

    inline private static function checkKey(bindType:String = '', bindArray:Array<FlxKey>, gamepadBindArray:Array<FlxGamepadInputID>) {
        if (gamepad != null) {
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

    inline public static function loadBindings():Void {
        controlSaveFile = new FlxSave();
        controlSaveFile.bind('funkinControls');
        if (controlSaveFile.data.controlBindings == null || controlSaveFile.data.controlGamepadBindings == null) {
            saveBindings();
        } else {
            controlBindings = controlSaveFile.data.controlBindings;
            controlGamepadBindings = controlSaveFile.data.controlGamepadBindings;
        }
    }

    inline public static function saveBindings():Void {
        controlSaveFile.data.controlBindings = new Map<String, Array<String>>();
        controlSaveFile.data.controlBindings = controlBindings;
        controlSaveFile.data.controlGamepadBindings = new Map<String, Array<String>>();
        controlSaveFile.data.controlGamepadBindings = controlGamepadBindings;
        controlSaveFile.flush();
    }

    inline public static function getBinding(bind:String):Array<String> {
        bind = bind.toUpperCase().trim();
        var bindingStuff:Array<String> = gamepad != null ? controlGamepadBindings.get(bind) : controlBindings.get(bind);
        return bindingStuff;
    }

    inline public static function setBinding(bind:String, key:String, index:Int):Void {
        bind = bind.toUpperCase().trim();
        key = key.toUpperCase().trim();
        var lastSettings:Array<String> = (gamepad != null ? controlGamepadBindings : controlBindings).get(bind);
        lastSettings[index] = key;
        (gamepad != null ? controlGamepadBindings : controlBindings).set(bind, lastSettings);
    }

    inline public static function addBinding(bind:String, keys:Array<String>, gamepadKeys:Array<String>):Void {
        bind = bind.toUpperCase().trim();
        for (i in 0...keys.length) {
            keys[i] = keys[i].toUpperCase().trim();
        }
        controlArray.push(bind);
        controlBindings.set(bind, keys);
        controlGamepadBindings.set(bind, gamepadKeys);
    }
}