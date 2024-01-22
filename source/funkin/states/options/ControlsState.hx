package funkin.states.options;

import flixel.input.gamepad.FlxGamepadInputID;
import funkin.states.options.items.ControlItem;
import flixel.input.gamepad.FlxGamepad;
import funkin.substates.PromptSubstate;

//	TODO: Clean this shit up!!!

class ControlsState extends MusicBeatState {
	var controlItems:FlxTypedGroup<ControlItem>;
	var menuItems:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var curBind:Int = 0;

	public static var controlList:Array<String> = [];
	private static var optionArray:Array<String> = ['LEFT','DOWN','UP','RIGHT','ACCEPT','BACK','PAUSE','RESET'];
	private static var menuList:Array<String> =  [
				    'NOTE',
		'LEFT', 'DOWN', 'UP', 'RIGHT',
		'', 		 'UI',
		'LEFT', 'DOWN', 'UP', 'RIGHT',
		'', 	   'GENERAL',
		'ACCEPT', 'BACK', 'PAUSE', 'RESET',
	];

	inline static function resetGamepad(gamepad:FlxGamepad) {
		FlxG.resetState();
	}

	var menuCam:FlxCamera;
	var camFollow:FlxObject;

	override function create():Void {
		FlxG.gamepads.deviceConnected.add(resetGamepad);
		FlxG.gamepads.deviceDisconnected.add(resetGamepad);

		menuCam = new FlxCamera();
		FlxG.cameras.add(menuCam);
		FlxG.cameras.setDefaultDrawTarget(menuCam, true);
		camFollow = new FlxObject(FlxG.width * .5, 0);
		add(camFollow);
		
		final bg:FunkinSprite = new FunkinSprite('menuBGBlue', [0,0], [0,0]);
		bg.setScale(1.1, false);
        add(bg);

		add(controlItems = new FlxTypedGroup<ControlItem>());
		add(menuItems = new FlxTypedGroup<Alphabet>());

		reloadValues();
		menuCam.follow(camFollow, null, 0.08);
		
		super.create();
	}

	function clearGroup(group:FlxTypedGroup<Dynamic>) {
		for (i in group) {
			group.remove(i);
			i.destroy();
		}
		group.clear();
	}

	private function reloadValues():Void {
		clearGroup(menuItems);
		clearGroup(controlItems);

		var c:Int = 0;
		controlList = Controls.controlArray;
		for (i in 0...menuList.length) {
			var item = menuList[i];
			if (item.length <= 0) continue;
			var itemY = i * 75;
			
			if (optionArray.contains(item)) {
				var bindArray:Array<String> = Controls.getBinding(controlList[c]);
				var controlItem:ControlItem = new ControlItem(item,
					InputFormatter.shortenButtonName(InputFormatter.getKeyName(bindArray[0])),
					InputFormatter.shortenButtonName(InputFormatter.getKeyName(bindArray[1])),
					itemY);
				controlItem.ID = c;
				controlItem.bindSelected = curBind;
				controlItems.add(controlItem);
				c++;
			} else {
				var titleTxt:Alphabet = new Alphabet(FlxG.width/2, itemY-50, item);
				titleTxt.alignment = CENTER;
				menuItems.add(titleTxt);
			}
		}

		changeSelection();
		menuCam.focusOn(camFollow.getPosition());
	}

	override function closeSubState():Void {
		super.closeSubState();
		SaveData.flushData();
		reloadValues();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (getKey('UI_UP-P'))		changeSelection(-1);
		if (getKey('UI_DOWN-P'))	changeSelection(1);

		if (getKey('UI_LEFT-P') || getKey('UI_RIGHT-P')) {
			curBind = (curBind + 1) % 2;
			CoolUtil.playSound('scrollMenu');
			for (item in controlItems.members) {
				item.bindSelected = curBind;
				item.updateDisplay();
			}
		}

		if (getKey('BACK-P')) {
			FlxG.gamepads.deviceConnected.remove(resetGamepad);
			FlxG.gamepads.deviceDisconnected.remove(resetGamepad);
			switchState(new OptionsState());
		}

		if (getKey('ACCEPT-P')) {
			openSubState(new PromptSubstate('Press any key to rebind\n\n\n\nEscape to cancel', function () {
				final keyCode:Int = Controls.inGamepad() ? Controls.gamepad.firstJustPressedID() : FlxG.keys.firstJustPressed();
				final pressedKey:String = Controls.inGamepad() ? FlxGamepadInputID.toStringMap.get(keyCode) : FlxKey.toStringMap.get(keyCode);
				if (pressedKey != 'ESCAPE') {
					Controls.setBinding(controlList[curSelected], pressedKey, curBind);
					CoolUtil.playSound('confirmMenu');
				}
			}, function ():Bool {
				return Controls.inGamepad() ? Controls.gamepad.firstJustPressedID() != FlxGamepadInputID.NONE : FlxG.keys.firstJustPressed() != FlxKey.NONE;
			}, 1));
		}
	}

	function changeSelection(change:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, controlItems.length - 1);
		if (change != 0)	CoolUtil.playSound('scrollMenu');

		for (item in controlItems.members) {
			item.selected = false;
			if (curSelected == item.ID) {
				item.selected = true;
				camFollow.y = item.targetY;
			}
			item.updateDisplay();
		}
	}
}

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