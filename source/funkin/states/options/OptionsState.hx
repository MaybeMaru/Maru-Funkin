package funkin.states.options;
import flixel.effects.FlxFlicker;

class OptionsState extends MusicBeatState {
	public static var fromPlayState:Bool = false;
	var optionItems:Array<String> = [
		'Preferences', 
		#if !mobile
		'Controls',
		#end
		'Latency'
	];
	var grpOptionsItems:TypedGroup<Alphabet>;
	
	var curSelected:Int = 0;
	var selectedSomethin:Bool = false;

	override function create():Void
	{
		if (fromPlayState) {
			if (FlxG.sound.music == null)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		#if MODS_ALLOWED
		else
		{
			optionItems.push('Mod Folders');
		}
		#end

		optionItems.push('Exit');

		#if mobile MobileTouch.setMode(MENU); #end

		var bg:FunkinSprite = new FunkinSprite('menuBGMagenta');
		bg.setScale(1.1);
		bg.screenCenter();
        add(bg);

		var optionsTitle:FunkinSprite = new FunkinSprite('options/titleOptions', [0,FlxG.height*0.08], [0,0]);
		optionsTitle.addAnim('loop', 'Options!', 24, true);
		optionsTitle.playAnim('loop');
		optionsTitle.screenCenter(X);
		add(optionsTitle);

		grpOptionsItems = new TypedGroup<Alphabet>();
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
		if (getKey('UI_UP', JUST_PRESSED)) changeSelection(-1);
		if (getKey('UI_DOWN', JUST_PRESSED)) changeSelection(1);

		if (getKey('ACCEPT', JUST_PRESSED)) {
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

		if (Controls.getKey('BACK', JUST_PRESSED)) {
			selectedSomethin = true;
			exitOptions();
		}
	}

	function openOptions():Void {
		switch (optionItems[curSelected]) {
			case 'Preferences':	switchState(new funkin.states.options.PreferencesState());
			#if !mobile
			case 'Controls':	switchState(new funkin.states.options.ControlsState());
			#end
			case 'Latency':		switchState(new funkin.states.options.LatencyState());
			#if MODS_ALLOWED
			case 'Mod Folders':	switchState(new funkin.states.options.ModFoldersState());
			#end
			default:			exitOptions();
		}
	}

	function exitOptions():Void {
		CoolUtil.playSound('cancelMenu');
		switchState(fromPlayState ? new PlayState() : new MainMenuState());
	}
}