package funkin.input;

import funkin.input.FlxKeyBR;
import funkin.input.FlxKeyES;
import funkin.input.FlxKeyUS;

enum abstract KeySystem(Int) from Int to Int {
    var US = 0;
    var ES = 1;
    var BR = 2;
}

@:allow(funkin.Preferences)
abstract GlobalKey(Int) from Int to Int {
    public static var system(default, null):KeySystem = US;

	public static inline function fromString(s:String):Int {
        return switch (system) {
            case US: FlxKeyUS.fromStringMap.exists(s) ? FlxKeyUS.fromStringMap.get(s) : FlxKeyUS.NONE;
            case ES: FlxKeyES.fromStringMap.exists(s) ? FlxKeyES.fromStringMap.get(s) : FlxKeyES.NONE;
            case BR: FlxKeyBR.fromStringMap.exists(s) ? FlxKeyBR.fromStringMap.get(s) : FlxKeyBR.NONE;
        }
	}

    public inline function toString():String {
        return switch(system) {
            case US: FlxKeyUS.toStringMap.get(this);
            case ES: FlxKeyES.toStringMap.get(this);
            case BR: FlxKeyBR.toStringMap.get(this);
        }
    }
}