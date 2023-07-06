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
        cutsceneTankman.anim.addByAnimIndices('tightBars', CoolUtil.numberArray(507,228), 24);
        PlayState.dad.visible = false;
        PlayState.dadGroup.add(cutsceneTankman);
    }
}

function startCutscene()
{
    PlayState.showUI(false);
    FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
    FlxG.sound.music.fadeIn(1, 0, 0.8);

    FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.sound('tankSong2')));

    PlayState.camFollow.x = PlayState.dad.x + 400;
    PlayState.camFollow.y = PlayState.dad.y + 170;
    FlxTween.tween(PlayState.camGame, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});

    // Pretty thight bars
    new FlxTimer().start(0.1, function(tmr:FlxTimer)
    {
        cutsceneTankman.anim.play('tightBars', true);
        CoolUtil.playSound('tankSong2');

        //Im too lazy, just took the Psych Engine variables LOL
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom * 1.2}, 4,            {ease: FlxEase.quadInOut});
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom * 1.2 * 1.2}, 0.5,    {ease: FlxEase.quadInOut, startDelay: 4});
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom * 1.2}, 1,            {ease: FlxEase.quadInOut, startDelay: 4.5});
    });

    // Sad GF
    new FlxTimer().start(4, function(tmr:FlxTimer)
    {
        PlayState.gf.playAnim('sad', true);
        PlayState.gf.animation.finishCallback = function(){PlayState.gf.playAnim('sad', true); };
    });

    //End Cutscene
    new FlxTimer().start(11.5, function(tmr:FlxTimer)
    {
        PlayState.dad.visible = true;
        cutsceneTankman.visible = false;
        FlxG.sound.music.fadeOut(1.5, 0);
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom}, Conductor.crochet / 255, {ease: FlxEase.cubeInOut});
        PlayState.gf.animation.finishCallback = null;
        PlayState.startCountdown();
    });
}

function startSong()
    FlxG.sound.music.volume = 1;