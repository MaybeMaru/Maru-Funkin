package funkin.substates;

import openfl.media.Sound;

enum abstract GameOverSound(Int) {
	var DEATH = 0;
	var MUSIC = 1;
	var MUSIC_END = 2;
}

class GameOverSubstate extends MusicBeatSubstate
{
	static var instance:GameOverSubstate;
	var char:Character;
	var camFollow:FlxObject;

	var skinFolder:String;
	var deathSound:FlxSound;
	var lockedOn:Bool = false;

	static var soundsID:Map<GameOverSound, String> = [
		DEATH => "",
		MUSIC => "",
		MUSIC_END => ""
	];

	public static function cacheSounds():Void {
		soundsID.set(DEATH, resolveSoundPath("fnf_loss_sfx", true));
		soundsID.set(MUSIC, resolveSoundPath("gameOver"));
		soundsID.set(MUSIC_END, resolveSoundPath("gameOverEnd"));

		Paths.sound(soundsID.get(DEATH));
		Paths.music(soundsID.get(MUSIC));
		Paths.music(soundsID.get(MUSIC_END));
	}

	inline static function resolveChar() {
		return PlayState.instance?.boyfriend ?? null;
	}

	inline static function resolveFolder(?char:Character) {
		var suffix = (char == null || char.gameOverSuffix == "") ? "default" : char.gameOverSuffix;
		return "skins/" + (suffix.endsWith("/") ? suffix.substr(0, suffix.length - 1) : suffix) + "/";
	}

	static function resolveSoundPath(id:String, isSound:Bool = false):String {
		final trySound = (path:String) -> {
			var id = isSound ? Paths.soundFolder(path) : Paths.musicFolder(path);
			if (Paths.exists(id, isSound ? SOUND : MUSIC)) {
				return path;
			}
			return "";
		}
		
		var curFolderSound = trySound(resolveFolder(resolveChar()) + id);
		if (curFolderSound != "")
			return curFolderSound;

		// Using defaults, if this is also null then sowwy :<
		return trySound(resolveFolder(null) + id);
	}

	public function new(x:Float, y:Float):Void {
		super();
		instance = this;

		FlxG.camera.bgColor = FlxColor.BLACK;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		if (PlayState.instance.startTimer != null)
			PlayState.instance.startTimer.cancel();

		#if mobile MobileTouch.setLayout(NONE); #end

		var bf = resolveChar();
		skinFolder = resolveFolder(bf);

		char = new Character(x, y, bf != null ? bf.gameOverChar : "bf-dead", true);
		PlayState.instance.boyfriend.stageOffsets.copyTo(char.stageOffsets);
		char.setXY(x,y);
		add(char);

		Conductor.songPosition = 0;
		Conductor.bpm = 100;

		deathSound = soundsID.get(DEATH) != "" ? CoolUtil.playSound(soundsID.get(DEATH)) : new FlxSound();
		char.playAnim('firstDeath');

		camFollow = new FlxObject();
		add(camFollow);

		var midPoint = char.getGraphicMidpoint();
		camFollow.x = midPoint.x - char.camOffsets.x;
		camFollow.y = midPoint.y - char.camOffsets.y;

		ModdingUtil.addCall('startGameOver');
	}

	function lockCamToChar() {
		PlayState.instance.camGame.follow(camFollow, LOCKON, 0.01);
		lockedOn = true;
	}

	public var lockFrame:Int = 12;

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (char.animation.curAnim != null)
		{
			if (char.animation.curAnim.name == 'firstDeath')
			{
				if (char.animation.curAnim.curFrame >= lockFrame) if (!lockedOn)
					lockCamToChar();
		
				if (char.animation.curAnim.finished) {
					if (soundsID.get(MUSIC) != "") {
						CoolUtil.playMusic(soundsID.get(MUSIC));
						musicBeat.targetSound = FlxG.sound.music;
					}

					gameOverDance();
					ModdingUtil.addCall('musicGameOver');
				}
			}
		}

		if (!isEnding)
		{
			if (getKey('BACK', JUST_PRESSED))
			{
				exitSong();
			}
			else if (#if mobile MobileTouch.justPressed() #else getKey('ACCEPT', JUST_PRESSED) #end)
			{
				restartSong();
			}
		}
		else if (exitTimer > 0)
		{
			exitTimer -= elapsed;
			if (exitTimer <= 0) {
				PlayState.clearCache = false;
				SkinUtil.setCurSkin('default');
				FlxG.resetState();
			}
		}
	}

	override function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		ModdingUtil.addCall('beatHitGameOver', [curBeat]);

		if (!isEnding) {
			gameOverDance();
		}
	}

	#if MODS_ALLOWED dynamic #end function gameOverDance():Void {
		if (char.animOffsets.exists('deathLoopRight') && char.animOffsets.exists('deathLoopLeft')) {
			char.danced = !char.danced;
			char.playAnim((char.danced) ? 'deathLoopRight' : 'deathLoopLeft');
		}
		else if (char.animOffsets.exists('deathLoop')) {
			char.playAnim('deathLoop');
		}
	}

	var isEnding:Bool = false;
	var exitTimer:Float = 0;

	function exitSong():Void
	{
		PlayState.deathCounter = 0;
		PlayState.clearCache = true;
		isEnding = true;

		// Able to stop n override gameover exit
		if (ModdingUtil.getCall("exitGameOver"))
			return;

		var fadeTime:Float = 0.15;

		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(fadeTime);

		if (deathSound != null)
			deathSound.fadeOut(fadeTime);

		FlxG.camera.fade(FlxColor.BLACK, fadeTime, false, () -> {
			CoolUtil.switchState((PlayState.isStoryMode) ? new StoryMenuState(): new FreeplayState(), true, false);
		});
	}

	function restartSong():Void
	{
		isEnding = true;
		char.playAnim('deathConfirm', true);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (soundsID.get(MUSIC_END) != "") {
			var endSound = new FlxSound().loadEmbedded(Paths.music(soundsID.get(MUSIC_END)));
			endSound.autoDestroy = true;
			endSound.play();
		}
			
		deathSound.stop();

		if (!lockedOn)
			lockCamToChar();

		new FlxTimer().start(0.7, (tmr:FlxTimer) -> {
			exitTimer = 2;
			PlayState.instance.camGame.fade(FlxColor.BLACK, 2);
		});

		ModdingUtil.addCall('resetGameOver');
	}

	override function destroy() {
		super.destroy();
		if (instance == this)
			instance = null;
	}
}
