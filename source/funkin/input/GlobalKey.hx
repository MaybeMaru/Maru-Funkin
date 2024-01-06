package funkin.input;

import funkin.input.FlxKeyBR;
import flixel.util.typeLimit.OneOfThree;
import funkin.input.FlxKeyES;
import funkin.input.FlxKeyUS;

typedef Key = OneOfThree<FlxKeyUS, FlxKeyES, FlxKeyBR>;

enum KeySystem {
    US;
    ES;
    BR;
}

abstract GlobalKey(Int) from Int from UInt to Int to UInt {
    public static var keySystem(default, null):KeySystem = US;

	public static inline function fromString(s:String):Key {
        return switch (keySystem) {
            case US: FlxKeyUS.fromStringMap.exists(s) ? FlxKeyUS.fromStringMap.get(s) : FlxKeyUS.NONE;
            case ES: FlxKeyES.fromStringMap.exists(s) ? FlxKeyES.fromStringMap.get(s) : FlxKeyES.NONE;
            case BR: FlxKeyBR.fromStringMap.exists(s) ? FlxKeyBR.fromStringMap.get(s) : FlxKeyBR.NONE;
        }
	}

    public inline function toString():String {
        return switch(keySystem) {
            case US: FlxKeyUS.toStringMap.get(this);
            case ES: FlxKeyES.toStringMap.get(this);
            case BR: FlxKeyBR.toStringMap.get(this);
        }
    }
}