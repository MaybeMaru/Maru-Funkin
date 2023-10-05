package funkin.substates;

class GameOverSubstate extends MusicBeatSubstate {
	var char:Character;
	var camFollow:FlxObject;

	var skinFolder:String = 'default';
	var charName:String = 'bf-dead';
	var deathSound:FlxSound = null;
	var lockedOn:Bool = false;

	public static function cacheSounds() {
		var skinFolder = PlayState.instance.boyfriend.gameOverSuffix;
		skinFolder = (skinFolder != "") ? 'skins/$skinFolder/' : 'skins/default/';
		Paths.sound(skinFolder+"fnf_loss_sfx");
		Paths.music(skinFolder+"gameOverEnd");
		Paths.music(skinFolder+"gameOver");
	}

	public function new(x:Float, y:Float):Void {
		super();

		if (FlxG.sound.music != null) FlxG.sound.music.stop();
		if (PlayState.instance.startTimer != null) {
			PlayState.instance.startTimer.cancel();
		}

		charName = PlayState.instance.boyfriend.gameOverChar;
		skinFolder = PlayState.instance.boyfriend.gameOverSuffix;
		skinFolder = (skinFolder != "") ? 'skins/$skinFolder/' : 'skins/default/';

		char = new Character(x, y, charName, true);
		PlayState.instance.boyfriend.stageOffsets.copyTo(char.stageOffsets);
		char.setXY(x,y);
		add(char);
		
		camFollow = new FlxObject(char.getGraphicMidpoint().x - char.camOffsets.x, char.getGraphicMidpoint().y - char.camOffsets.y, 1, 1);
		add(camFollow);

		Conductor.songPosition = 0;
		Conductor.bpm = 100;

		deathSound = CoolUtil.playSound('${skinFolder}fnf_loss_sfx');
		char.playAnim('firstDeath');

		ModdingUtil.addCall('startGameOver');
	}

	function lockCamToChar() {
		PlayState.instance.camGame.follow(camFollow, LOCKON, 0.01);
		lockedOn = true;
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (getKey('ACCEPT-P')) {
			endBullshit();
			ModdingUtil.addCall('resetGameOver');
		}
 
		if (getKey('BACK-P')) {
			if (FlxG.sound.music != null) FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.clearCache = true;
			ModdingUtil.addCall('exitGameOver');
			CoolUtil.switchState((PlayState.isStoryMode) ? new StoryMenuState(): new FreeplayState());
		}

		if (char.animation.curAnim != null) {
			if (char.animation.curAnim.name == 'firstDeath') {
				if (char.animation.curAnim.curFrame == 12) {
					lockCamToChar();
				}
		
				if (char.animation.curAnim.finished) {
					CoolUtil.playMusic('${skinFolder}gameOver');
					gameOverDance();
					ModdingUtil.addCall('musicGameOver');
				}
			}
		}

		if (FlxG.sound.music != null) {
			if (FlxG.sound.music.playing) {
				Conductor.songPosition = FlxG.sound.music.time;
			}
		}

		if (exitTimer > 0) {
			exitTimer -= elapsed;
			if (exitTimer <= 0) {
				PlayState.clearCache = false;
				SkinUtil.setCurSkin('default');
				FlxG.resetState();
			}
		}
	}

	override function destroy() {
		super.destroy();
		CustomTransition.skipTrans = false;
	}

	override function beatHit():Void {
		super.beatHit();
		ModdingUtil.addCall('beatHitGameOver', [curBeat]);

		if (!isEnding) {
			gameOverDance();
		}
	}

	function gameOverDance():Void {
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

	function endBullshit():Void {
		if (!isEnding) {
			isEnding = true;
			char.playAnim('deathConfirm', true);
			if (FlxG.sound.music != null) FlxG.sound.music.stop();

			var endSound = new FlxSound().loadEmbedded(Paths.music('${skinFolder}gameOverEnd'));
			endSound.play();
			deathSound.stop();

			if (!lockedOn) lockCamToChar();

			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				exitTimer = 2;
				PlayState.instance.camGame.fade(FlxColor.BLACK, 2);
			});
		}
	}
}
