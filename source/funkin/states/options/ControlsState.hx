package funkin.states.options;

import flixel.input.gamepad.FlxGamepadInputID;
import funkin.states.options.items.ControlItem;
import funkin.states.options.items.InputFormatter;
import flixel.input.gamepad.FlxGamepad;
import funkin.substates.PromptSubstate;

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
		camFollow = new FlxObject(FlxG.width/2, 0);
		
		var bg:FunkinSprite = new FunkinSprite('menuBGBlue', [0,0], [0,0]);
		bg.setScale(1.1, false);
        add(bg);

		controlItems = new FlxTypedGroup<ControlItem>();
		add(controlItems);
		menuItems = new FlxTypedGroup<Alphabet>();
		add(menuItems);

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
				var keyCode:Int = Controls.inGamepad() ? Controls.gamepad.firstJustPressedID() : FlxG.keys.firstJustPressed();
				var pressedKey:String = Controls.inGamepad() ? FlxGamepadInputID.toStringMap.get(keyCode) : FlxKey.toStringMap.get(keyCode);
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