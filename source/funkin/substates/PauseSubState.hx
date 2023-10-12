package funkin.substates;

import flixel.util.FlxStringUtil;

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
	var timeLeft:FunkinText;

	var _items:Array<FunkinText> = [];

	var maxTime:String = "";

	public function new():Void {
		super(false);

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);

		levelInfo = new FunkinText(20,15,PlayState.SONG.song,32);
		add(levelInfo);

		levelDifficulty = new FunkinText(20,15,(PlayState.curDifficulty.toUpperCase()),32);
		add(levelDifficulty);

		deathCounter = new FunkinText(20,15,"Blue balled: " + PlayState.deathCounter,32);
		add(deathCounter);

		maxTime = FlxStringUtil.formatTime(Conductor.inst.length / 1000);
		timeLeft = new FunkinText(20,15,"Time left: 0 / 0",32);
		add(timeLeft);

		_items = [levelInfo,levelDifficulty,deathCounter,timeLeft];
		for (i in _items)
			i.x = FlxG.width - (i.width + 20);

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

		for (i in _items) {
			final _id = _items.indexOf(i);
			i.alpha = 0;
			i.y = 15 + 32 * _id;
			FlxTween.tween(i, {alpha: 1, y: i.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3 * (_id + 1)});
		}
		
		final curTime = FlxStringUtil.formatTime(Math.max(Conductor.songPosition, 0) / 1000);
		timeLeft.text = "Time left: " + curTime + " / " + maxTime;
		timeLeft.x = FlxG.width - (timeLeft.width + 20);

		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

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
		if (getKey('UI_DOWN-P')) 	changeSelection(1);

		if (coolDown > 0) coolDown-=elapsed;
		else {
			if (getKey('ACCEPT-P')) {
				CustomTransition.skipTrans = false;
				switch (menuItems[curSelected]) {
					case "Resume":	
						CoolUtil.resumeSounds();
						pauseMusic.stop();	
						close();

					case "Restart song":
						PlayState.clearCache = false;
						CoolUtil.resetState();

					case "Options":			
						PlayState.clearCache = false;
						OptionsState.fromPlayState = true;
						CoolUtil.switchState(new OptionsState());

					case "Exit to menu":
						PlayState.clearCache = true;
						PlayState.clearCacheData = null;
						PlayState.deathCounter = 0;
						CoolUtil.switchState((PlayState.isStoryMode) ? new StoryMenuState() : new FreeplayState());
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
