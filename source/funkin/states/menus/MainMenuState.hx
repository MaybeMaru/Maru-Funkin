package funkin.states.menus;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;

class MainMenuState extends MusicBeatState {
	var magenta:FunkinSprite;
	var camFollow:FlxObject;

	var optionShit:Array<String> = [
		'story mode',
		'freeplay',
		'options',
		'donate'
	];
	var curSelected:Int = 0;
	var menuItems:FlxTypedGroup<FunkinSprite>;

	override function create():Void {
		#if cpp 		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing) {
			CoolUtil.playMusic('freakyMenu');
		}

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		persistentUpdate = persistentDraw = true;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		var bg:FunkinSprite = new FunkinSprite('menuBG', [0,0], [0,0.18]);
		bg.setGraphicSize(Std.int(bg.width * 1.15));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		magenta = new FunkinSprite('menuDesat', [0,0], [0,0.18]);
		magenta.color = 0xFFfd719b;
		magenta.visible = false;
		magenta.setGraphicSize(Std.int(magenta.width * 1.15));
		magenta.updateHitbox();
		magenta.screenCenter();
		if (getPref('flashing-light'))	add(magenta);

		menuItems = new FlxTypedGroup<FunkinSprite>();
		add(menuItems);
		
		for (i in 0...optionShit.length) {
			var item:String = optionShit[i];
			var menuItem:FunkinSprite = new FunkinSprite('mainmenu/$item', [0,60+(i*160)], [0,0]);
			menuItem.addAnim('idle', '$item basic', 24, true);
			menuItem.addAnim('selected', '$item white', 24, true);
			menuItem.playAnim('idle');
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.ID = i;
		}

		var menuCam:SwagCamera = new SwagCamera();
		FlxG.cameras.add(menuCam);
		FlxG.cameras.setDefaultDrawTarget(menuCam, true);
		menuCam.follow(camFollow, null, 0.06);

		var versionText:String = 'Mau Engin v${Main.engineVersion}\nFriday Night Funkin v${Application.current.meta.get('version')}';

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18*2, 0, versionText, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float):Void {
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin) {
			if (getKey('UI_UP-P')) {
				changeItem(-1);
			}
			if (getKey('UI_DOWN-P')) {
				changeItem(1);
			}

			if (getKey('BACK-P')) {
				FlxG.switchState(new TitleState());
			}

			if (getKey('ACCEPT-P')) {
				if (optionShit[curSelected] == 'donate') {
					var itchioUrl:String = 'https://ninja-muffin24.itch.io/funkin';
					#if linux
					Sys.command('/usr/bin/xdg-open', [itchioUrl, "&"]);
					#else
					FlxG.openURL(itchioUrl);
					#end
				}
				else {
					selectedSomethin = true;
					CoolUtil.playSound('confirmMenu');
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FunkinSprite) {
						if (curSelected != spr.ID) {
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween) {
									spr.kill();
								}
							});
						}
						else {
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
								var daChoice:String = optionShit[curSelected];
								trace('${daChoice.toUpperCase()} Menu Selected');

								switch (daChoice) {
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
									case 'freeplay':
										FreeplayState.curSelected = 0;
										FreeplayState.curDifficulty = 1;
										FlxG.switchState(new FreeplayState());
									case 'options':
										OptionsState.fromPlayState = false;
										FlxG.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);
	}

	function changeItem(add:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + add, 0, menuItems.length - 1);
		if (add != 0) CoolUtil.playSound('scrollMenu');

		menuItems.forEach(function(spr:FunkinSprite) {
			spr.playAnim('idle');
			if (spr.ID == curSelected) {
				spr.playAnim('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
			spr.updateHitbox();
			spr.screenCenter(X);
		});

		menuItems.sort(function(int:Int, obj1:FunkinSprite, obj2:FunkinSprite) {
			return FlxSort.byValues(FlxSort.DESCENDING, obj1.ID-curSelected, obj2.ID-curSelected);
		});
	}
}