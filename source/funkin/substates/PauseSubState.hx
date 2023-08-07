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

	public function new():Void {
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FunkinText = new FunkinText(20,15,PlayState.SONG.song,32);
		add(levelInfo);

		var levelDifficulty:FunkinText = new FunkinText(20,15+32,(PlayState.curDifficulty.toUpperCase()),32);
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<MenuAlphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length) {
			var songText:MenuAlphabet = new MenuAlphabet(0, (70 * i) + 30, menuItems[i], true);
			songText.targetY = i;
			grpMenuShit.add(songText);
		}
		
		changeSelection();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var coolDown:Float = 0.1; //Controllers have a lil lag that fuck this fuck

	override function update(elapsed:Float):Void {
		if (pauseMusic.volume < 0.5) {
			pauseMusic.volume += 0.01 * elapsed;
		}

		super.update(elapsed);

		if (getKey('UI_UP-P')) {
			changeSelection(-1);
		}
		if ( getKey('UI_DOWN-P')) {
			changeSelection(1);
		}

		if (coolDown > 0) {
			coolDown-=elapsed;
		} else {
			if (getKey('ACCEPT-P')) {	
				switch (menuItems[curSelected]) {
					case "Resume":			close(); CoolUtil.playSounds();
					case "Restart song":	FlxG.resetState();
					case "Options":			OptionsState.fromPlayState = true;	FlxG.switchState(new OptionsState());
					case "Exit to menu":	FlxG.switchState((PlayState.isStoryMode) ? new StoryMenuState() : new FreeplayState());
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
