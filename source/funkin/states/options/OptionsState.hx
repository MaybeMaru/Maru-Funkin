package funkin.states.options;
import flixel.effects.FlxFlicker;

class OptionsState extends MusicBeatState {
	public static var fromPlayState:Bool = false;
	var optionItems:Array<String> = [
		'Preferences', 
		'Controls',
		'Latency'
	];
	var grpOptionsItems:FlxTypedGroup<Alphabet>;
	
	var curSelected:Int = 0;
	var selectedSomethin:Bool = false;

	override function create():Void {
		if (!fromPlayState) 				optionItems.push('Mod Folders');
		else if (FlxG.sound.music == null)	FlxG.sound.playMusic(Paths.music('freakyMenu'));
		optionItems.push('Exit');

		var bg:FunkinSprite = new FunkinSprite('menuBGMagenta');
        bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.screenCenter();
        add(bg);

		var optionsTitle:FunkinSprite = new FunkinSprite('options/titleOptions', [0,FlxG.height*0.08], [0,0]);
		optionsTitle.addAnim('loop', 'Options! instancia 1', 24, true);
		optionsTitle.playAnim('loop');
		optionsTitle.screenCenter(X);
		add(optionsTitle);

		grpOptionsItems = new FlxTypedGroup<Alphabet>();
		add(grpOptionsItems);

		var leSpace:Float = FlxG.height/1.5;
		for (i in 0...optionItems.length) {
			var optionItem:Alphabet = new Alphabet(0, (FlxG.height/3)+(leSpace/optionItems.length*(i+1)/1.25)-25, optionItems[i], true);
			optionItem.ID = i;
			optionItem.screenCenter(X);
			grpOptionsItems.add(optionItem);
		}
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * elapsed;
		}
		if (!selectedSomethin) controlShit();
	}

	function changeSelection(value:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + value, 0, optionItems.length - 1);
		if (value != 0) CoolUtil.playSound('scrollMenu');
		grpOptionsItems.forEach(function(item:Alphabet) {
			item.color = FlxColor.WHITE;
			item.alpha = 0.6;
	
			if (item.ID == curSelected) {
				item.color = FlxColor.YELLOW;
				item.alpha = 1;
			}
		});
	}

	function controlShit():Void {
		if (getKey('UI_UP-P')) changeSelection(-1);
		if (getKey('UI_DOWN-P')) changeSelection(1);

		if (getKey('ACCEPT-P')) {
			selectedSomethin = true;
			if (optionItems[curSelected] == 'Exit') {
				exitOptions();
			}
			else {
				for (item in grpOptionsItems) {
					if (item.ID == curSelected) {
						CoolUtil.playSound('confirmMenu');
						FlxFlicker.flicker(item, 0.6, 0.06, false, false, function(flick:FlxFlicker) {
							openOptions();
						});
					} else {
						FlxTween.tween(item, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) {
								item.destroy();
							}
						});
					}
				}
			}
		}

		if (Controls.getKey('BACK-P')) {
			selectedSomethin = true;
			exitOptions();
		}
	}

	function openOptions():Void {
		switch (optionItems[curSelected]) {
			case 'Preferences':	switchState(new funkin.states.options.PreferencesState());
			case 'Controls':	switchState(new funkin.states.options.ControlsState());
			case 'Latency':		switchState(new funkin.states.options.LatencyState());
			case 'Mod Folders':	switchState(new funkin.states.options.ModFoldersState());
			default:			exitOptions();
		}
	}

	function exitOptions():Void {
		CoolUtil.playSound('cancelMenu');
		switchState(fromPlayState ? new PlayState() : new MainMenuState());
	}
}