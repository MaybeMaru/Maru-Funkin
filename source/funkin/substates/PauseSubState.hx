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
	var curSelected:Int = 0;

	var bg:FlxSprite;
	var timeLeft:FunkinText;

	var pauseMusic:FlxSound;
	var pauseLength:Int = 0;

	var _items:Array<FunkinText> = [];

	var maxTime:String = "";

	public function new():Void {
		super(false);
		pauseMusic = CoolUtil.getSound("breakfast", MUSIC);
		pauseMusic.looped = true;
		pauseLength = Std.int(pauseMusic.length * 0.5);

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scrollFactor.set();
		bg.antialiasing = false;
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.active = false;
		add(bg);

		final levelInfo:FunkinText = new FunkinText(20,15,PlayState.SONG.song,32);
		final levelDifficulty:FunkinText = new FunkinText(20,15,(PlayState.curDifficulty.toUpperCase()),32);
		final deathCounter:FunkinText = new FunkinText(20,15,"Blue balled: " + PlayState.deathCounter,32);

		maxTime = FlxStringUtil.formatTime(Conductor.inst.length / 1000);
		timeLeft = new FunkinText(20,15,"Time left: 0 / 0",32);

		for (i in _items = [levelInfo,levelDifficulty,deathCounter,timeLeft]) {
			i.x = FlxG.width - (i.width + 20);
			add(i);
		}

		grpMenuShit = new FlxTypedGroup<MenuAlphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length) {
			final songText:MenuAlphabet = new MenuAlphabet(0, 0, menuItems[i], true);
			songText.targetY = i;
			grpMenuShit.add(songText);
		}
	}

	public function init() {
		pauseMusic.volume = 0;
		pauseMusic.play(true);
		pauseMusic.time = FlxG.random.int(0, pauseLength);

		for (i in _items) {
			final _id = _items.indexOf(i);
			i.alpha = 0.00001;
			i.y = 15 + 32 * _id;
			FlxTween.tween(i, {alpha: 1, y: i.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3 * (_id + 1)});
		}
		
		final curTime = FlxStringUtil.formatTime(Math.max(Conductor.songPosition, 0) / 1000);
		timeLeft.text = "Time left: " + curTime + " / " + maxTime;
		timeLeft.x = FlxG.width - (timeLeft.width + 20);

		bg.alpha = 0.00001;
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
		if (pauseMusic.volume < 0.6) {
			pauseMusic.volume += 0.01 * elapsed;
			pauseMusic.volume = FlxMath.bound(pauseMusic.volume, 0, 0.6);
		}

		super.update(elapsed);

		if (getKey('UI_UP-P')) 		changeSelection(-1);
		if (getKey('UI_DOWN-P')) 	changeSelection(1);

		if (coolDown > 0) coolDown-=elapsed;
		else {
			if (getKey('ACCEPT-P')) {
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

	inline function changeSelection(change:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		for (i in 0...grpMenuShit.members.length) {
			final item = grpMenuShit.members[i];
			item.targetY = i - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		}
	}
}
