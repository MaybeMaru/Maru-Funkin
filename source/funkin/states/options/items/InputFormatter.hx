package funkin.states.options.items;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

class InputFormatter {
	public static function getKeyName(?keyStr:String):String {
		if (keyStr == null) return "";
		if (Controls.gamepad != null) {
			/*switch (FlxGamepadInputID.fromString(keyStr)) {
				case FlxGamepadInputID.DPAD_UP: return 'DpUp';
				case FlxGamepadInputID.DPAD_LEFT: return 'DpLeft';
				case FlxGamepadInputID.DPAD_DOWN: return 'DpDown';
				case FlxGamepadInputID.DPAD_RIGHT: return 'DpRight';
			}*/
		} else {
			switch (FlxKey.fromString(keyStr)) {
				case BACKSPACE:		 return 'BckSpc'; case CONTROL: 		return 'Ctrl';
				case ALT:			 return 'Alt';    case CAPSLOCK: 		return 'Caps';
				case PAGEUP:		 return 'PgUp';   case PAGEDOWN: 		return 'PgDown';
				case ZERO:			 return '0';  	  case ONE: 			return '1';
				case TWO:			 return '2';  	  case THREE: 			return '3';
				case FOUR:			 return '4';  	  case FIVE: 			return '5';
				case SIX:			 return '6';  	  case SEVEN: 			return '7';
				case EIGHT:			 return '8';  	  case NINE: 			return '9';
				case NUMPADZERO:	 return '#0';  	  case NUMPADONE: 		return '#1';
				case NUMPADTWO:		 return '#2';  	  case NUMPADTHREE: 	return '#3';
				case NUMPADFOUR:	 return '#4';  	  case NUMPADFIVE: 		return '#5';
				case NUMPADSIX:		 return '#6';  	  case NUMPADSEVEN: 	return '#7';
				case NUMPADEIGHT:	 return '#8';  	  case NUMPADNINE: 		return '#9';
				case NUMPADMULTIPLY: return '#*';  	  case NUMPADPLUS: 		return '#+';
				case NUMPADMINUS:	 return '#-';  	  case NUMPADPERIOD:  	return '#.';
				case SEMICOLON:		 return ';';  	  case COMMA: 			return ',';
				case PERIOD:		 return '.';  	  case SLASH: 			return '/';
				case GRAVEACCENT:	 return '`';  	  case LBRACKET: 		return '[';
				case BACKSLASH:		 return '\\';  	  case RBRACKET: 		return ']';
				case QUOTE:			 return '\'';  	  case PRINTSCREEN: 	return 'PrtScrn';
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