package funkin.states.options;

import flixel.input.gamepad.FlxGamepadInputID;
import funkin.states.options.items.ControlItem;
import flixel.input.gamepad.FlxGamepad;
import funkin.substates.PromptSubstate;

//	TODO: Clean this shit up!!!

class ControlsState extends MusicBeatState {
	var controlItems:TypedGroup<ControlItem>;
	var curSelected:Int = 0;
	var curBind:Int = 0;

	inline static function resetGamepad(gamepad:FlxGamepad) {
		FlxG.resetState();
	}

	var menuCam:FlxCamera;
	var camFollow:FlxObject;
	var selectRect:FlxSpriteExt;

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

		selectRect = new FlxSpriteExt(150 + 380).makeRect(320, 85);
		selectRect.ID = Std.int(selectRect.offset.x);
		selectRect.alpha = 0.4;
		add(selectRect);

		add(controlItems = new TypedGroup<ControlItem>());

		var y:Float = 0;
		for (header in Controls.headers) {
			var back = new FlxSpriteExt(0, y - 10).makeRect(FlxG.width, 85, FlxColor.BLACK);
            back.alpha = 0.4;
            add(back);

			var title = new Alphabet(FlxG.width * .5, y, header);
            title.alignment = CENTER;
            add(title);

			y += 130 + (Controls.headerContents.get(header).length * 100);
		}

		reloadValues();
		menuCam.follow(camFollow, null, 0.16);
		
		super.create();
	}

	private function reloadValues():Void {
		controlItems.members.fastForEach((basic, i) -> {
			basic.destroy();
		});
		controlItems.clear();

		var id:Int = 0;
        var y:Float = 0;

		var formatKey = function (key:String) {
			return InputFormatter.shortenButtonName(InputFormatter.getKeyName(key));
		}
		
		for (header in Controls.headers) {
			y += 40;

            for (control in Controls.headerContents.get(header)) {
				var binds = Controls.getBinding(control);
				var item = new ControlItem(control, formatKey(binds[0]), formatKey(binds[1]));
				item.ID = id;
				item.y = y + 75;

				item.bindSelected = curBind;
				controlItems.add(item);

                id++;
                y += 100;
            }

            y += 90;
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

		if (getKey('UI_UP', JUST_PRESSED))		changeSelection(-1);
		if (getKey('UI_DOWN', JUST_PRESSED))	changeSelection(1);

		if (getKey('UI_LEFT', JUST_PRESSED) || getKey('UI_RIGHT', JUST_PRESSED)) {
			curBind = (curBind + 1) % 2;
			CoolUtil.playSound('scrollMenu');
			for (item in controlItems.members) {
				item.bindSelected = curBind;
				item.updateDisplay();
			}
		}

		selectRect.offset.x = FlxMath.lerp(selectRect.offset.x, (curBind * -400) + selectRect.ID, elapsed * 30);

		if (getKey('BACK', JUST_PRESSED)) {
			FlxG.gamepads.deviceConnected.remove(resetGamepad);
			FlxG.gamepads.deviceDisconnected.remove(resetGamepad);
			switchState(new OptionsState());
		}

		if (getKey('ACCEPT', JUST_PRESSED) && curItem != null) {
			final gamepad = Controls.inGamepad();

			openSubState(new PromptSubstate('Press any key to rebind\n\n\n\nEscape to cancel', function ()
			{	
				var code:Int = gamepad ? Controls.gamepad.firstJustPressedID() : FlxG.keys.firstJustPressed();
				var keyPress:String = gamepad ? FlxGamepadInputID.toStringMap.get(code) : FlxKey.toStringMap.get(code);
				
				if (keyPress != 'ESCAPE') {
					Controls.setBinding(curItem.key, keyPress, curBind);
					CoolUtil.playSound('confirmMenu');
				}
			},
			function ():Bool {
				return gamepad ? Controls.gamepad.firstJustPressedID() != FlxGamepadInputID.NONE : FlxG.keys.firstJustPressed() != FlxKey.NONE;
			}, 1));
		}
	}

	var curItem:ControlItem;

	function changeSelection(change:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, controlItems.length - 1);
		if (change != 0)	CoolUtil.playSound('scrollMenu');

		for (item in controlItems.members) {
			item.selected = false;
			if (curSelected == item.ID) {
				curItem = item;
				item.selected = true;
				camFollow.y = item.y;
				selectRect.y = item.y - 10;
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