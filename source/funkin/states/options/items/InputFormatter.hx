package funkin.states.options.items;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

class InputFormatter {
	public static function getKeyName(keyStr:String):String {
		if (Controls.gamepad != null) {
			/*switch (FlxGamepadInputID.fromString(keyStr)) {
				case FlxGamepadInputID.DPAD_UP: return 'DpUp';
				case FlxGamepadInputID.DPAD_LEFT: return 'DpLeft';
				case FlxGamepadInputID.DPAD_DOWN: return 'DpDown';
				case FlxGamepadInputID.DPAD_RIGHT: return 'DpRight';
			}*/
		} else {
			switch (FlxKey.fromString(keyStr)) {
				case FlxKey.BACKSPACE:		return 'BckSpc'; case FlxKey.CONTROL: 		return 'Ctrl';
				case FlxKey.ALT:			return 'Alt';    case FlxKey.CAPSLOCK: 		return 'Caps';
				case FlxKey.PAGEUP:			return 'PgUp';   case FlxKey.PAGEDOWN: 		return 'PgDown';
				case FlxKey.ZERO:			return '0';  	 case FlxKey.ONE: 			return '1';
				case FlxKey.TWO:			return '2';  	 case FlxKey.THREE: 		return '3';
				case FlxKey.FOUR:			return '4';  	 case FlxKey.FIVE: 			return '5';
				case FlxKey.SIX:			return '6';  	 case FlxKey.SEVEN: 		return '7';
				case FlxKey.EIGHT:			return '8';  	 case FlxKey.NINE: 			return '9';
				case FlxKey.NUMPADZERO:		return '#0';  	 case FlxKey.NUMPADONE: 	return '#1';
				case FlxKey.NUMPADTWO:		return '#2';  	 case FlxKey.NUMPADTHREE: 	return '#3';
				case FlxKey.NUMPADFOUR:		return '#4';  	 case FlxKey.NUMPADFIVE: 	return '#5';
				case FlxKey.NUMPADSIX:		return '#6';  	 case FlxKey.NUMPADSEVEN: 	return '#7';
				case FlxKey.NUMPADEIGHT:	return '#8';  	 case FlxKey.NUMPADNINE: 	return '#9';
				case FlxKey.NUMPADMULTIPLY:	return '#*';  	 case FlxKey.NUMPADPLUS: 	return '#+';
				case FlxKey.NUMPADMINUS:	return '#-';  	 case FlxKey.NUMPADPERIOD:  return '#.';
				case FlxKey.SEMICOLON:		return ';';  	 case FlxKey.COMMA: 		return ',';
				case FlxKey.PERIOD:			return '.';  	 case FlxKey.SLASH: 		return '/';
				case FlxKey.GRAVEACCENT:	return '`';  	 case FlxKey.LBRACKET: 		return '[';
				case FlxKey.BACKSLASH:		return '\\';  	 case FlxKey.RBRACKET: 		return ']';
				case FlxKey.QUOTE:			return '\'';  	 case FlxKey.PRINTSCREEN: 	return 'PrtScrn';
				default:
			}
		}
		return keyStr.charAt(0).toUpperCase() + keyStr.substr(1).toLowerCase();
	}

	private static var dirReg:EReg = new EReg("^(l|r).?-(left|right|down|up)$", "");

	public static function shortenButtonName(button:String = ''):String {
		button = button.toLowerCase();
		if (button == '') return '[?]';
		if (dirReg.match(button)) {
			var a = dirReg.matched(1).toUpperCase() + ' ';
			var b = dirReg.matched(2);
			return a + (b.charAt(0).toUpperCase() + b.substr(1).toLowerCase());
		}
		return button.charAt(0).toUpperCase() + button.substr(1).toLowerCase();
	}
}