var cutsceneTankman_Body:FunkinSprite;
var cutsceneTankman_Head:FunkinSprite;

function create()
{
	if (GameVars.isStoryMode)
	{
		PlayState.inCutscene = true;

		cutsceneTankman_Body = new FunkinSprite('tankmanCutscene_body', [PlayState.dad.x, PlayState.dad.y + 155], [1, 1]);
		cutsceneTankman_Body.addAnim('wellWellWell', 'body/BODY_1_10');
		cutsceneTankman_Body.addAnim('killYou', 'body/BODY_1_20');
		cutsceneTankman_Body.addOffset('killYou', 40, 5);

		cutsceneTankman_Head = new FunkinSprite('tankmanCutscene_head', [PlayState.dad.x + 60, PlayState.dad.y - 10], [1, 1]);
		cutsceneTankman_Head.addAnim('wellWellWell', 'HEAD_1_10');
		cutsceneTankman_Head.addAnim('killYou', 'HEAD_1_20');
		cutsceneTankman_Head.addOffset('wellWellWell', 0, -5);

		PlayState.dad.visible = false;
		PlayState.dadGroup.add(cutsceneTankman_Body);
		PlayState.dadGroup.add(cutsceneTankman_Head);
	}
}

function startCutscene()
{
	PlayState.showUI(false);
	FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
	FlxG.sound.music.fadeIn(1, 0, 0.8);

	for (i in ['wellWellWell', 'bfBeep', 'killYou'])
		getSound(i);

	PlayState.camGame.zoom /= 0.75;
	PlayState.camFollow.x += 25;
	PlayState.camFollow.y -= 25;

	// Well Well Well
	new FlxTimer().start(0.1, function(tmr:FlxTimer)
	{
		cutsceneTankman_Body.playAnim('wellWellWell', true);
		cutsceneTankman_Head.playAnim('wellWellWell', true);
		CoolUtil.playSound('wellWellWell');
	});

	// Move to BF
	new FlxTimer().start(3, function(tmr:FlxTimer)
	{
		PlayState.camFollow.x += 450;
	});

	// BF beep
	new FlxTimer().start(4.5, function(tmr:FlxTimer)
	{
		CoolUtil.playSound('bfBeep');
		PlayState.boyfriend.playAnim('singUP', true);
	});

	// Go back to BF idle
	new FlxTimer().start(5, function(tmr:FlxTimer)
	{
		PlayState.boyfriend.dance();
	});

	// Kill You
	new FlxTimer().start(6, function(tmr:FlxTimer)
	{
		PlayState.camFollow.x -= 450;

		CoolUtil.playSound('killYou');
		cutsceneTankman_Body.playAnim('killYou', true);
		cutsceneTankman_Head.playAnim('killYou', true);
	});

	// End Cutscene
	new FlxTimer().start(12, function(tmr:FlxTimer)
	{
		PlayState.dad.visible = true;
		cutsceneTankman_Body.visible = false;
		cutsceneTankman_Head.visible = false;
		FlxG.sound.music.fadeOut(1.5, 0);
		FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom}, Conductor.crochet / 255, {ease: FlxEase.cubeInOut});
		PlayState.startCountdown();
	});
}
