package funkin.states.options;

import funkin.states.options.items.ControlItem;
import funkin.states.options.items.InputFormatter;
import flixel.input.gamepad.FlxGamepad;

class ControlsState extends MusicBeatState {
	var controlItems:FlxTypedGroup<ControlItem>;
	var menuItems:FlxTypedGroup<ControlItem>;
	var curSelected:Int = 0;
	var curBind:Int = 0;

	public static var controlList:Array<String> = [];
	private static var optionArray:Array<String> = ['LEFT','DOWN','UP','RIGHT','ACCEPT','BACK','PAUSE','RESET'];
	private static var menuList:Array<String> =  [
		'NOTE',
		'LEFT', 'DOWN', 'UP', 'RIGHT',
		'', 'UI',
		'LEFT', 'DOWN', 'UP', 'RIGHT',
		'', 'GENERAL',
		'ACCEPT', 'BACK', 'PAUSE', 'RESET',
	];

	inline static function resetGamepad(gamepad:FlxGamepad) {
		FlxG.resetState();
	}

	override function create():Void {
		FlxG.gamepads.deviceConnected.add(resetGamepad);
		FlxG.gamepads.deviceDisconnected.add(resetGamepad);
		
		var bg:FunkinSprite = new FunkinSprite('menuBGBlue');
        bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.screenCenter();
        add(bg);

		controlItems = new FlxTypedGroup<ControlItem>();
		add(controlItems);
		menuItems = new FlxTypedGroup<ControlItem>();
		add(menuItems);

		reloadValues();
		super.create();
	}

	private function reloadValues():Void {
		for (item in menuItems) {
			item.visible = false;
			item.kill();
			item.destroy();
			menuItems.remove(item);
		}

		for (item in controlItems) {
			item.visible = false;
			item.kill();
			item.destroy();
			controlItems.remove(item);
		}

		controlList = Controls.controlArray;
		var leCount:Int = 0;
		var realCount:Int = 0;
		for (control in menuList) {
			if (control != '') {
				if (optionArray.contains(control)) {
					var bindArray:Array<String> = Controls.getBinding(controlList[realCount]);
					var bind1Name:String = InputFormatter.getKeyName(bindArray[0]);
					var bind2Name:String = InputFormatter.getKeyName(bindArray[1]);
					var controlItem:ControlItem = new ControlItem(control,
					InputFormatter.shortenButtonName(bind1Name),
					InputFormatter.shortenButtonName(bind2Name),
					(leCount-curSelected-1+controlList.length/6)*75);
					controlItem.indexID = realCount;
					controlItem.orderID = leCount;
					controlItem.bindSelected = curBind;
					controlItem.x += 100;
					controlItems.add(controlItem);
					realCount++;
				}
				else {
					var menuItem:ControlItem = new ControlItem(control, '', '', ((leCount-curSelected-1+controlList.length/6)*75)-(75/2), true);
					menuItem.orderID = leCount;
					menuItem.screenCenter(X);
					menuItems.add(menuItem);
				}
			}
			leCount++;
		}
		changeSelection();
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
			curBind++;
			curBind = curBind%2;
			CoolUtil.playSound('scrollMenu');
			for (item in controlItems.members)
				item.bindSelected = curBind;
		}

		if (getKey('BACK-P')) {
			FlxG.gamepads.deviceConnected.remove(resetGamepad);
			FlxG.gamepads.deviceDisconnected.remove(resetGamepad);
			FlxG.switchState(new OptionsState());
		}

		if (getKey('ACCEPT-P')) {
			funkin.states.options.PromptSubstate.keyToChange = controlList[curSelected];
			funkin.states.options.PromptSubstate.keyBindIndex = curBind;
			openSubState(new funkin.states.options.PromptSubstate());
		}
	}

	function changeSelection(change:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, controlItems.length - 1);
		if (change != 0)	CoolUtil.playSound('scrollMenu');

		for (item in controlItems.members) {
			item.targetY = (item.orderID - curSelected + (controlItems.length/6))*75;
			item.selected = false;
			if (curSelected == item.indexID) {
				item.selected = true;
			}
		}

		for (item in menuItems.members) {
			item.targetY = (item.orderID - curSelected + (controlItems.length/6))*75;
			item.targetY -= 75/2;
		}
	}
}