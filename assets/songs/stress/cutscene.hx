/*var cutsceneTankman:FlxAnimate;
var cutscenePico:FlxAnimate;
var speakerPico:FlxAnimate;*/

function create()
{
    if (!GameVars.isStoryMode)
    {
        PlayState.inCutscene = true;

        /*cutsceneTankman = new FlxAnimate(PlayState.dad.x, PlayState.dad.y, Paths.getAtlas('captainLipsync'));
        cutsceneTankman.x += 114;
        cutsceneTankman.y -= 35;

        cutsceneTankman.antialiasing = true;
        cutsceneTankman.anim.addByAnimIndices('godEffingDamnIt', CoolUtil.numberArray(916,508), 24);
        cutsceneTankman.anim.addByAnimIndices('lookWhoItIs', CoolUtil.numberArray(1277,917), 24);

        //Layering
        PlayState.dad.visible = false;
        PlayState.gfGroup.add(cutscenePico);
        PlayState.dadGroup.add(cutsceneTankman);*/
    }
}

function startCutscene()
{
    PlayState.showUI(false);

    var soundPath:String = 'stressCutscene';
    if (!getPref('naughty'))
        soundPath = 'song3censor';

    var stressCutscene:FlxSound = new FlxSound().loadEmbedded(Paths.sound(soundPath));
    FlxG.sound.list.add(stressCutscene);

    PlayState.camFollow.x = PlayState.dad.x + 400;
    PlayState.camFollow.y = PlayState.dad.y + 170;
    FlxTween.tween(PlayState.camGame, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});

    // God effing damn it
    new FlxTimer().start(0.1, function(tmr:FlxTimer)
    {
        //cutsceneTankman.anim.play('godEffingDamnIt');
        stressCutscene.play(true);
    });

    // Zoom to GF
    new FlxTimer().start(15.2, function(tmr:FlxTimer)
    {
        //PlayState.gf.visible = false;
        FlxTween.tween(PlayState.camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
        FlxTween.tween(PlayState.camGame, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
    });

    // Pico appears
    new FlxTimer().start(17.5, function(tmr:FlxTimer)
    {
        zoomBack();
    });

    // Look who it is
    new FlxTimer().start(19.5, function(tmr:FlxTimer)
    {
        //cutsceneTankman.anim.play('lookWhoItIs', true);
    });

    //Focus to tankman
    new FlxTimer().start(20, function(tmr:FlxTimer)
    {
        PlayState.camFollow.x = PlayState.dad.x + 500;
        PlayState.camFollow.y = PlayState.dad.y + 170;
    });

    //Little Cunt
    new FlxTimer().start(31.2, function(tmr:FlxTimer)
    {
        PlayState.boyfriend.playAnim('singUPmiss', true);

        //Snap the camera
        PlayState.camFollow.x = PlayState.boyfriend.x + 260;
        PlayState.camFollow.y = PlayState.boyfriend.y + 160;
        //PlayState.camGame.focusOn(PlayState.camFollow.getPosition());

        FlxTween.tween(PlayState.camGame, {zoom: 0.9 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
    });

    new FlxTimer().start(32.2, function(tmr:FlxTimer)
    {
        PlayState.boyfriend.dance();
        zoomBack();
    });

    //Fade Sound
    new FlxTimer().start(34.5, function(tmr:FlxTimer)
    {
        stressCutscene.fadeOut(1.5, 0);
    });

    //End Cutscene
    new FlxTimer().start(35.5, function(tmr:FlxTimer)
    {
        //PlayState.dad.visible = true;
        //cutsceneTankman.visible = false;
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom}, Conductor.crochet / 255, {ease: FlxEase.cubeInOut});
        PlayState.startCountdown();
    });

    if (!getPref('naughty'))
    {
        var censorBar:FunkinSprite = new FunkinSprite('censor', [300,450], [1,1]);
        censorBar.addAnim('mouth censor', 'mouth censor', 24, true);
        censorBar.playAnim('mouth censor', true);
        censorBar.updateHitbox();
        censorBar.visible = false;
        PlayState.add(censorBar);
    
        var censorTimes:Array<Dynamic> =
        [
            [4.63,true,[300,450]],      [4.77,false],   //SHIT
            [25,true,[275,435]],        [25.27,false],  //SCHOOL
            [25.38,true],               [25.86,false],
            [30.68,true,[375,475]],     [31.06,false],  //CUNT
            [33.79,true,[300,450]],     [34.28,false],
        ];
    
        for (censorThing in censorTimes)
        {
            new FlxTimer().start(censorThing[0], function(tmr:FlxTimer)
            {
                censorBar.visible = censorThing[1];
                if (censorThing[2] != null)
                {
                    censorBar.x = censorThing[2][0];
                    censorBar.y = censorThing[2][1];
                }
            });
        }
    }
}

function startSong()
{
    FlxG.sound.music.volume = 1;
}

function zoomBack()
{
	PlayState.camFollow.x = 630;
    PlayState.camFollow.y = 425;
	PlayState.camGame.zoom = 0.8;
}

var catchedGF:Bool = false;
function updatePost()
{
    /*if (curCutscenePicoAnim == 'picoArrives_1')
    {
        if (cutscenePico.anim.get_curFrame() >= 2 && !catchedGF)
        {
            catchedGF = true;
            PlayState.boyfriend.playAnim('catch');
            PlayState.boyfriend.animation.finishCallback = function(){PlayState.boyfriend.dance();};
        }
    }*/
}