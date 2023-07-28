/*importLib('Song', 'funkin.util.song');

var cutsceneTankman:FlxAnimate;
var cutscenePico:FlxAnimate;
var speakerPico:FlxAnimate;

var curCutscenePicoAnim:String = 'balls';
var curPicoAnim:Null<String> = null;

var animationNotes:Array<Dynamic> = [];

function create()
{
    speakerPico = new FlxAnimate(PlayState.gf.x, PlayState.gf.y, Paths.atlas('pico-speaker'));
    speakerPico.x += 20;
    speakerPico.y += 80;
    speakerPico.antialiasing = true;

    var gayAnims:Array<Dynamic> = [
        ['shot1', [15,25]],['shot2', [26,35]],['shot3', [36,45]],['shot4', [46,56]],
        ['shot1-loop', [19,25]],['shot2-loop', [30,35]],['shot3-loop', [40,45]],['shot4-loop', [50,56]]];

    for (anim in gayAnims)
        speakerPico.anim.addByAnimIndices(anim[0], CoolUtil.atlasIndices(anim[1][0],anim[1][1]), 24, StringTools.endsWith(anim[0],'-loop'));
    speakerPico.visible = false;

    PlayState.gf.visible = false;
    PlayState.add(speakerPico);
    animationNotes = Song.getSongNotes('picospeaker',  GameVars.SONG.song);

    if (GameVars.isStoryMode)
    {
        PlayState.inCutscene = true;

        cutsceneTankman = new FlxAnimate(PlayState.dad.x, PlayState.dad.y, Paths.getAtlas('captainLipsync'));
        cutsceneTankman.x += 114;
        cutsceneTankman.y -= 35;

        cutsceneTankman.antialiasing = true;
        cutsceneTankman.anim.addByAnimIndices('godEffingDamnIt', CoolUtil.numberArray(916,508), 24);
        cutsceneTankman.anim.addByAnimIndices('lookWhoItIs', CoolUtil.numberArray(1277,917), 24);

        //Pico
        cutscenePico = new FlxAnimate(PlayState.gf.x, PlayState.gf.y, Paths.getAtlas('pico-cutscene'));
        cutscenePico.x += 20;
        cutscenePico.y += 80;
        cutscenePico.antialiasing = true;
        cutscenePico.anim.addByAnimIndices('gfTurnDemon_1', CoolUtil.numberArray(30,1), 24);
        cutscenePico.anim.addByAnimIndices('gfTurnDemon_2', CoolUtil.numberArray(54,31), 24);
        cutscenePico.anim.addByAnimIndices('picoArrives_1', CoolUtil.numberArray(79,55), 24);
        cutscenePico.anim.addByAnimIndices('picoArrives_2', CoolUtil.numberArray(112,80), 24);
        cutscenePico.anim.addByAnimIndices('picoArrives_3', CoolUtil.numberArray(139,113), 24);

        //Layering
        cutscenePico.visible = false;
        PlayState.dad.visible = false;
        PlayState.gfGroup.add(cutscenePico);
        PlayState.dadGroup.add(cutsceneTankman);
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
        cutsceneTankman.anim.play('godEffingDamnIt');
        stressCutscene.play(true);
    });

    // Zoom to GF
    new FlxTimer().start(15.2, function(tmr:FlxTimer)
    {
        PlayState.gf.visible = false;
        cutscenePico.visible = true;
        playCutscenePicoAnim('gfTurnDemon_1');
        FlxTween.tween(PlayState.camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
        FlxTween.tween(PlayState.camGame, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
    });

    // Pico appears
    new FlxTimer().start(17.5, function(tmr:FlxTimer)
    {
        playCutscenePicoAnim('picoArrives_1');
        zoomBack();
    });

    // Look who it is
    new FlxTimer().start(19.5, function(tmr:FlxTimer)
    {
        cutsceneTankman.anim.play('lookWhoItIs', true);
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
        PlayState.dad.visible = true;
        cutsceneTankman.visible = false;
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom}, Conductor.crochet / 255, {ease: FlxEase.cubeInOut});
        PlayState.startCountdown();
    });

    if (!getPref('naughty'))
    {
        var censorBar:FunkinSprite = new FunkinSprite('censor', [300,450], [1,1], ['mouth censor'], true);
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

function startCountdown()
{
    speakerPico.visible = true;
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

function playCutscenePicoAnim(anim:String)
{
    curCutscenePicoAnim = anim;
    cutscenePico.anim.play(anim);
}

function playPicoAnim(anim:String)
{
    curPicoAnim = anim;
    speakerPico.anim.play(anim, true);
}

var catchedGF:Bool = false;
function update()
{
    if (curPicoAnim != null)
    {
        if (!StringTools.endsWith(curPicoAnim, '-loop'))
        {
            if (speakerPico.anim.get_curFrame() == speakerPico.anim.length-1)
                playPicoAnim(curPicoAnim+'-loop');
        }
    }

    switch(curCutscenePicoAnim)
    {
        case 'gfTurnDemon_1': if (cutscenePico.anim.get_curFrame() >= 27) playCutscenePicoAnim('gfTurnDemon_2');
        case 'picoArrives_1': if (cutscenePico.anim.get_curFrame() >= 22) playCutscenePicoAnim('picoArrives_2');
        case 'picoArrives_2': if (cutscenePico.anim.get_curFrame() >= 30) playCutscenePicoAnim('picoArrives_3');
        case 'picoArrives_3':
            if (cutscenePico.anim.get_curFrame() >= 24)
            {
                curCutscenePicoAnim = 'he died';
                speakerPico.visible = true;
                cutscenePico.visible = false;
                cutscenePico.kill();
                cutscenePico.destroy();
            }
    }

    if (curCutscenePicoAnim == 'picoArrives_1')
    {
        if (cutscenePico.anim.get_curFrame() >= 2 && !catchedGF)
        {
            catchedGF = true;
            PlayState.boyfriend.playAnim('catch');
            PlayState.boyfriend.animation.finishCallback = function(){PlayState.boyfriend.dance();};
        }
    }

    if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
    {
        var noteData:Int = 1;
        if(animationNotes[0][1] > 2) noteData = 3;
        noteData += FlxG.random.int(0, 1);
        playPicoAnim('shoot'+noteData);
        animationNotes.shift();
    }
}*/