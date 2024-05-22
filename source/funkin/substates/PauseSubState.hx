package funkin.substates;

import flixel.util.FlxStringUtil;

class PauseSubState extends MusicBeatSubstate {
	var menuItems:Array<String> = [
		'Resume',
		'Restart song',
		'Options',
		'Exit to menu'
	];
	var timeLeft:FunkinText;

	var pauseMusic:FlxSound;
	var pauseLength:Int = 0;

	var pauseItems:Array<FunkinText> = [];

	var items:Array<MenuAlphabet> = [];
	var curSelected:Int = 0;

	var maxTime:String = "";

	public function new():Void
	{
		super(false, 0x98000000);
		pauseMusic = CoolUtil.getSound("breakfast", MUSIC);
		pauseMusic.looped = true;
		pauseLength = Std.int(pauseMusic.length * 0.5);

		final levelInfo:FunkinText = new FunkinText(20,15,PlayState.SONG.song,32);
		final levelDifficulty:FunkinText = new FunkinText(20,15,(PlayState.curDifficulty.toUpperCase()),32);
		final deathCounter:FunkinText = new FunkinText(20,15,"Blue balled: " + PlayState.deathCounter,32);

		maxTime = FlxStringUtil.formatTime(Conductor.inst.length / 1000);
		timeLeft = new FunkinText(20,15,"Time left: 0 / 0",32);

		pauseItems = [levelInfo, levelDifficulty, deathCounter, timeLeft];
		pauseItems.fastForEach((item, i) -> {
			item.x = FlxG.width - (item.width + 20);
			add(item);
		});

		menuItems.fastForEach((item, i) -> {
			var menuItem:MenuAlphabet = new MenuAlphabet(0, 0, item, true, i);
			add(menuItem);
			items.push(menuItem);
		});
	}

	public function init()
	{
		pauseMusic.volume = 0;
		pauseMusic.play(true);
		pauseMusic.time = FlxG.random.int(0, pauseLength);

		pauseItems.fastForEach((item, i) -> {
			item.alpha = 0.00001;
			item.y = 15 + 32 * i;
			FlxTween.tween(item, {alpha: 1, y: item.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3 * (i + 1)});
		});
		
		final curTime = FlxStringUtil.formatTime(Math.max(Conductor.songPosition, 0) / 1000);
		timeLeft.text = "Time left: " + curTime + " / " + maxTime;
		timeLeft.x = FlxG.width - (timeLeft.width + 20);

		_bgSprite.alpha = 0.00001;
		FlxTween.tween(_bgSprite, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		items.fastForEach((item, i) -> item.setPosition(-100 * i, (70 * i) + 200));

		coolDown = 0.1;
		curSelected = 0;
		changeSelection();

		camera = CoolUtil.getTopCam();
		_bgSprite.camera = camera;
	}

	var coolDown:Float = 0.1; //Controllers have a lil lag

	override function update(elapsed:Float):Void
	{
		if (pauseMusic.volume < 0.6) {
			pauseMusic.volume += 0.01 * elapsed;
			pauseMusic.volume = FlxMath.bound(pauseMusic.volume, 0, 0.6);
		}

		super.update(elapsed);

		if (getKey('UI_UP', JUST_PRESSED)) 		changeSelection(-1);
		if (getKey('UI_DOWN', JUST_PRESSED)) 	changeSelection(1);

		if (coolDown > 0)
		{
			coolDown -= elapsed;
		}
		else if (getKey('ACCEPT', JUST_PRESSED))
		{
			selectItem(menuItems[curSelected]);
		}
	}

	// Easier to customize with hscript

	#if MODS_ALLOWED dynamic #else @:unreflective inline #end
	function selectItem(item:String) {
		switch (item) {
			case "Resume":	 		resumeSong();
			case "Restart song": 	restartSong();
			case "Options":			openOptions();
			case "Exit to menu":	exitSong();
		}
	}

	#if MODS_ALLOWED dynamic #else @:unreflective inline #end
	function resumeSong() {
		CoolUtil.resumeSounds();
		pauseMusic.stop();	
		close();
	}

	#if MODS_ALLOWED dynamic #else @:unreflective inline #end
	function restartSong() {
		PlayState.clearCache = false;
		CoolUtil.resetState();
	}

	#if MODS_ALLOWED dynamic #else @:unreflective inline #end
	function openOptions() {
		PlayState.clearCache = false;
		OptionsState.fromPlayState = true;
		CoolUtil.switchState(new OptionsState());
	}

	#if MODS_ALLOWED dynamic #else @:unreflective inline #end
	function exitSong() {
		PlayState.clearCache = true;
		PlayState.clearCacheData = null;
		PlayState.deathCounter = 0;
		CoolUtil.switchState((PlayState.isStoryMode) ? new StoryMenuState() : new FreeplayState());
	}

	#if MODS_ALLOWED dynamic #else @:unreflective inline #end
	function changeSelection(change:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		items.fastForEach((item, i) -> {
			item.targetY = i - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		});
	}

	override function destroy():Void {
		pauseMusic.destroy();
		super.destroy();
	}
}
