package funkin.input;

import funkin.input.*;

enum abstract KeySystem(Int) from Int to Int {
    var US = 0;
    var ES = 1;
    var PT = 2;
}

@:allow(funkin.Preferences)
abstract GlobalKey(Int) from Int to Int {
    public static var system:KeySystem = US;

	public static inline function fromString(s:String):Int {
        return switch (system) {
            case US: FlxKey.fromStringMap.exists(s) ? FlxKey.fromStringMap.get(s) : FlxKey.NONE;
            case ES: FlxKeyES.fromStringMap.exists(s) ? FlxKeyES.fromStringMap.get(s) : FlxKeyES.NONE;
            case PT: FlxKeyPT.fromStringMap.exists(s) ? FlxKeyPT.fromStringMap.get(s) : FlxKeyPT.NONE;
        }
	}

    public inline function toString():String {
        return switch(system) {
            case US: FlxKey.toStringMap.get(this);
            case ES: FlxKeyES.toStringMap.get(this);
            case PT: FlxKeyPT.toStringMap.get(this);
        }
    }
}