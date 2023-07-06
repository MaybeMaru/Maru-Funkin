var cutsceneTankman:FlxAnimate;

function create()
{
   if (GameVars.isStoryMode)
    {
        PlayState.inCutscene = true;

        cutsceneTankman = new FlxAnimate(PlayState.dad.x, PlayState.dad.y, Paths.atlas('captainLipsync'));
        cutsceneTankman.x += 114;
        cutsceneTankman.y -= 35;

        cutsceneTankman.antialiasing = true;
        cutsceneTankman.anim.addByAnimIndices('wellWellWell', CoolUtil.numberArray(79,1), 24);
        cutsceneTankman.anim.addByAnimIndices('killYou', CoolUtil.numberArray(226,81), 24);
        PlayState.dad.visible = false;
        PlayState.dadGroup.add(cutsceneTankman);
    }
}

function startCutscene()
{
    PlayState.showUI(false);
    FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
    FlxG.sound.music.fadeIn(1, 0, 0.8);

    for (sound in ['wellWellWell', 'bfBeep', 'killYou'])
        FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.sound(sound)));

    PlayState.camGame.zoom /= 0.75;
    PlayState.camFollow.x += 25;
    PlayState.camFollow.y -= 25;

    // Well Well Well
    new FlxTimer().start(0.1, function(tmr:FlxTimer)
    {
        cutsceneTankman.anim.play('wellWellWell', true);
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
        cutsceneTankman.anim.play('killYou');
    });

    //End Cutscene
    new FlxTimer().start(12, function(tmr:FlxTimer)
    {
        PlayState.dad.visible = true;
        cutsceneTankman.visible = false;
        FlxG.sound.music.fadeOut(1.5, 0);
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom}, Conductor.crochet / 255, {ease: FlxEase.cubeInOut});
        PlayState.startCountdown();
    });
}

function startSong()
    FlxG.sound.music.volume = 1;