package funkin.substates;

class PauseSubState extends MusicBeatSubstate {
	var menuItems:Array<String> = [
		'Resume',
		'Restart song',
		'Options',
		'Exit to menu'
	];
	var grpMenuShit:FlxTypedGroup<MenuAlphabet>;
	var pauseMusic:FlxSound;

	var curSelected:Int = 0;

	var bg:FlxSprite;
	var levelInfo:FunkinText;
	var levelDifficulty:FunkinText;
	var deathCounter:FunkinText;

	public function new():Void {
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);

		levelInfo = new FunkinText(20,15,PlayState.SONG.song,32);
		add(levelInfo);

		levelDifficulty = new FunkinText(20,15+32,(PlayState.curDifficulty.toUpperCase()),32);
		add(levelDifficulty);

		deathCounter = new FunkinText(20,15+64,"Blue balled: " + PlayState.deathCounter,32);
		add(deathCounter);

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		deathCounter.x = FlxG.width - (deathCounter.width + 20);

		grpMenuShit = new FlxTypedGroup<MenuAlphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length) {
			var songText:MenuAlphabet = new MenuAlphabet(0, 0, menuItems[i], true);
			songText.targetY = i;
			grpMenuShit.add(songText);
		}
	}

	public function init() {
		pauseMusic.volume = 0;
		pauseMusic.play(true, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		bg.alpha = 0;
		levelInfo.alpha = 0;
		levelDifficulty.alpha = 0;
		deathCounter.alpha = 0;
		
		levelInfo.y = 15;
		levelDifficulty.y = 15 + 32;
		deathCounter.y = 15 + 64;

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(deathCounter, {alpha: 1, y: deathCounter.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		for (i in 0...grpMenuShit.members.length) {
			grpMenuShit.members[i].setPosition(-100 * i, (70 * i) + 200);
		}

		coolDown = 0.1;
		curSelected = 0;
		changeSelection();
		cameras = [CoolUtil.getTopCam()];
	}

	var coolDown:Float = 0.1; //Controllers have a lil lag

	override function update(elapsed:Float):Void {
		if (pauseMusic.volume < 0.5) {
			pauseMusic.volume += 0.01 * elapsed;
		}

		super.update(elapsed);

		if (getKey('UI_UP-P')) 		changeSelection(-1);
		if ( getKey('UI_DOWN-P')) 	changeSelection(1);

		if (coolDown > 0) {
			coolDown-=elapsed;
		} else {
			if (getKey('ACCEPT-P')) {	
				switch (menuItems[curSelected]) {
					case "Resume":	
						CoolUtil.resumeSounds();
						pauseMusic.stop();	
						close();

					case "Restart song":
						PlayState.clearCache = false;
						FlxG.resetState();

					case "Options":			
						PlayState.clearCache = false;
						OptionsState.fromPlayState = true;
						FlxG.switchState(new OptionsState());

					case "Exit to menu":
						PlayState.clearCache = true;
						PlayState.deathCounter = 0;
						FlxG.switchState((PlayState.isStoryMode) ? new StoryMenuState() : new FreeplayState());
				}
			}
		}
	}

	override function destroy():Void {
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		for (i in 0...grpMenuShit.members.length) {
			var item = grpMenuShit.members[i];
			item.targetY = i - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		}
	}
}
