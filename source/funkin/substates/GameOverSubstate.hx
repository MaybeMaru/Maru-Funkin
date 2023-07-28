package funkin.substates;

class GameOverSubstate extends MusicBeatSubstate {
	var bf:Character;
	var camFollow:FlxObject;

	var skinFolder:String = 'default';
	var daBf:String = 'bf-dead';

	public function new(x:Float, y:Float):Void {
		super();

		daBf = PlayState.game.boyfriend.gameOverChar;
		skinFolder = PlayState.game.boyfriend.gameOverSuffix;
		skinFolder = (skinFolder!="") ? 'skins/$skinFolder/' : 'skins/default/';
		trace(daBf);
		trace(skinFolder);

		bf = new Character(x, y, daBf, true);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		Conductor.songPosition = 0;
		Conductor.changeBPM(100);

		CoolUtil.playSound('${skinFolder}fnf_loss_sfx');
		bf.playAnim('firstDeath');

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
			FlxG.switchState((PlayState.isStoryMode) ? new StoryMenuState(): new FreeplayState());
		}

		if (bf.animation.curAnim != null) {
			if (bf.animation.curAnim.name == 'firstDeath') {
				if (bf.animation.curAnim.curFrame == 12) {
					PlayState.game.camGame.follow(camFollow, LOCKON, 0.01);
				}
		
				if (bf.animation.curAnim.finished) {
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
		if (bf.animOffsets.exists('deathLoopRight') && bf.animOffsets.exists('deathLoopLeft')) {
			bf.danced = !bf.danced;
			bf.playAnim((bf.danced) ? 'deathLoopRight' : 'deathLoopLeft');
		}
		else if (bf.animOffsets.exists('deathLoop')) {
			bf.playAnim('deathLoop');
		}
	}

	var isEnding:Bool = false;

	function endBullshit():Void {
		if (!isEnding) {
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			if (FlxG.sound.music != null) {
				FlxG.sound.music.stop();
			}
			CoolUtil.playMusic('${skinFolder}gameOverEnd');
			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				PlayState.game.camGame.fade(FlxColor.BLACK, 2, false, function() {
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
