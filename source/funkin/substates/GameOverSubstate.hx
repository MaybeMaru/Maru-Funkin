package funkin.substates;

class GameOverSubstate extends MusicBeatSubstate {
	var char:Character;
	var camFollow:FlxObject;

	var skinFolder:String = 'default';
	var charName:String = 'bf-dead';

	public function new(x:Float, y:Float):Void {
		super();

		charName = PlayState.game.boyfriend.gameOverChar;
		skinFolder = PlayState.game.boyfriend.gameOverSuffix;
		skinFolder = (skinFolder != "") ? 'skins/$skinFolder/' : 'skins/default/';

		char = new Character(x, y, charName, true);
		add(char);
		
		camFollow = new FlxObject(char.getGraphicMidpoint().x - char.camOffsets.x, char.getGraphicMidpoint().y - char.camOffsets.y, 1, 1);
		add(camFollow);

		Conductor.songPosition = 0;
		Conductor.bpm = 100;

		CoolUtil.playSound('${skinFolder}fnf_loss_sfx');
		char.playAnim('firstDeath');

		ModdingUtil.addCall('startGameOver');
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (getKey('ACCEPT-P')) {
			endBullshit();
			ModdingUtil.addCall('resetGameOver');
		}
 
		if (getKey('BACK-P')) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.stop();
			}
			ModdingUtil.addCall('exitGameOver');
			PlayState.clearCache = true;
			FlxG.switchState((PlayState.isStoryMode) ? new StoryMenuState(): new FreeplayState());
		}

		if (char.animation.curAnim != null) {
			if (char.animation.curAnim.name == 'firstDeath') {
				if (char.animation.curAnim.curFrame == 12) {
					PlayState.game.camGame.follow(camFollow, LOCKON, 0.01);
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

	function endBullshit():Void {
		if (!isEnding) {
			isEnding = true;
			char.playAnim('deathConfirm', true);
			if (FlxG.sound.music != null) {
				FlxG.sound.music.stop();
			}
			CoolUtil.playMusic('${skinFolder}gameOverEnd');
			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				PlayState.game.camGame.fade(FlxColor.BLACK, 2, false, function() {
					PlayState.clearCache = false;
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
