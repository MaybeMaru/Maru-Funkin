var cutsceneTankman_Body:FunkinSprite;
var cutsceneTankman_Head:FunkinSprite;

// Cutscene stuff
var demonGf:FunkinSprite;
var john:FunkinSprite;
var steve:FunkinSprite;
var demonBg:FlxSprite;
var beef:FlxSpriteExt;

var loadedCutsceneAssets:Bool = false;

function create()
{
    if (GameVars.isStoryMode)
    {
        PlayState.inCutscene = true;
        var censored:Bool = !getPref('naughty');
        var censorStr:String = censored ? '-censor' : '';

        cutsceneTankman_Body = new FunkinSprite('tankmanCutscene_body', [PlayState.dad.x, PlayState.dad.y + 155], [1,1]);
        cutsceneTankman_Body.addAnim('godEffingDamnIt', 'body/BODY_3_10');
        cutsceneTankman_Body.addAnim('lookWhoItIs', 'body/BODY_3_20');
        cutsceneTankman_Body.addOffset('godEffingDamnIt', 95, 160);
        cutsceneTankman_Body.addOffset('lookWhoItIs', 5, 32);

        cutsceneTankman_Head = new FunkinSprite('tankmanCutscene_head', [PlayState.dad.x + 60, PlayState.dad.y - 10], [1,1]);
        cutsceneTankman_Head.addAnim('godEffingDamnIt', 'HEAD_3_10');
        cutsceneTankman_Head.addAnim('lookWhoItIs', 'HEAD_3_20');
        cutsceneTankman_Head.addOffset('godEffingDamnIt', 30, 25);
        cutsceneTankman_Head.addOffset('lookWhoItIs', 15, 15);

        demonGf = new FunkinSprite('cutscenes/demon_gf' + censorStr, [PlayState.gf.x - 920, PlayState.gf.y - 454], [0.95, 0.95]);
        demonGf.addAnim('demonGf', 'DEMON_GF');
        demonGf.addAnim('dancing', 'GF Dancing at Gunpoint', 24, true);
        demonGf.addOffset('dancing', -738, -464);
        if (censored) {
            demonGf.addOffset('demonGf', -152, 0);
        }
        john = new FunkinSprite('cutscenes/john' + censorStr, [PlayState.gf.x + 398, PlayState.gf.y - 45], [0.95, 0.95]);
        john.addAnim('john', 'JOHN');
        steve = new FunkinSprite('cutscenes/steve' + censorStr, [PlayState.gf.x - 887.5, PlayState.gf.y - 345], [0.95, 0.95]);
        steve.addAnim('steve', 'STEVE');

        PlayState.dad.visible = false;
        PlayState.dadGroup.add(cutsceneTankman_Body);
        PlayState.dadGroup.add(cutsceneTankman_Head);

        PlayState.add(john);
        PlayState.add(steve);
        PlayState.gfGroup.add(demonGf);

        john.visible = false;
        steve.visible = false;

        PlayState.gf.visible = false;
        demonGf.playAnim('dancing');

        loadedCutsceneAssets = true;

        initShader('demon_blur', 'demon_blur');
        setShaderFloat('demon_blur', 'u_size', 0);
        setShaderFloat('demon_blur', 'u_alpha', 0);

        PlayState.boyfriend.visible = false;
        beef = new FlxSpriteExt(PlayState.boyfriend.x, PlayState.boyfriend.y).loadImage('cutscenes/beef');
        PlayState.boyfriendGroup.add(beef);
    }
}

function startCutscene()
{
    PlayState.showUI(false);

    var stressCutscene:FlxSound = getSound(getPref('naughty') ? 'stressCutscene' : 'song3censor');
    FlxG.sound.list.add(stressCutscene);

    PlayState.camFollow.x = PlayState.dad.x + 400;
    PlayState.camFollow.y = PlayState.dad.y + 170;
    FlxTween.tween(PlayState.camGame, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});

    // God effing damn it
    new FlxTimer().start(0.1, function(tmr:FlxTimer) {
        cutsceneTankman_Body.playAnim('godEffingDamnIt', true);
        cutsceneTankman_Head.playAnim('godEffingDamnIt', true);
        stressCutscene.play(true);
    });

    demonBg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
    demonBg.scrollFactor.set();
    demonBg.alpha = 0;
    addSpr(demonBg, 'demonBg');

    // Zoom to GF
    new FlxTimer().start(15.2, function(tmr:FlxTimer)
    {
        demonGf.playAnim('demonGf');
        FlxTween.tween(PlayState.camFollow, {x: 700, y: 300}, 1, {ease: FlxEase.sineOut});
        FlxTween.tween(PlayState.camGame, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
        FlxTween.tween(demonBg, {alpha: 0.9}, 2.25, {ease: FlxEase.quadOut});
        setCameraShader(PlayState.camGame, 'demon_blur');
    });

    // Pico appears
    new FlxTimer().start(17.5, function(tmr:FlxTimer)
    {
        demonBg.alpha = 0;
        PlayState.camGame.setFilters([]);
        zoomBack();
    });

    // Look who it is
    new FlxTimer().start(19.5, function(tmr:FlxTimer)
    {
        cutsceneTankman_Body.playAnim('lookWhoItIs', true);
        cutsceneTankman_Head.playAnim('lookWhoItIs', true);
        cutsceneTankman_Head.visible = true;
    });

    //Focus to tankman
    new FlxTimer().start(20, function(tmr:FlxTimer)
    {
        PlayState.camFollow.x = PlayState.dad.x + 500;
        PlayState.camFollow.y = PlayState.dad.y + 170;
    });

    //Small anticipation
    new FlxTimer().start(21, function(tmr:FlxTimer) {
        PlayState.gf.dance();
    });

    //Little friend
    new FlxTimer().start(21.5, function(tmr:FlxTimer) {
        PlayState.gf.playAnim('shoot1-loop');
    });

    //Little Cunt
    new FlxTimer().start(31.2, function(tmr:FlxTimer)
    {
        PlayState.boyfriend.playAnim('singUPmiss', true);

        //Snap the camera
        PlayState.camFollow.x = PlayState.boyfriend.x + 260;
        PlayState.camFollow.y = PlayState.boyfriend.y + 160;

        FlxTween.tween(PlayState.camGame, {zoom: 0.9 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
    });

    new FlxTimer().start(32.2, function(tmr:FlxTimer)
    {
        PlayState.boyfriend.dance();
        PlayState.boyfriend.animation.curAnim.finish();
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
        cutsceneTankman_Body.visible = false;
        cutsceneTankman_Head.visible = false;
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom}, Conductor.crochet / 255, {ease: FlxEase.cubeInOut});
        PlayState.startCountdown();
    });

    if (!getPref('naughty'))
    {
        var censorBar:FunkinSprite = new FunkinSprite('censor', [300,450], [1,1]);
        censorBar.addAnim('mouth censor', 'mouth censor', 24, true);
        censorBar.addOffset('mouth censor', 75, 0);
        censorBar.playAnim('mouth censor', true);
        censorBar.visible = false;
        PlayState.add(censorBar);
    
        var censorTimes:Array<Dynamic> = [
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

function zoomBack()
{
	PlayState.camFollow.x = 630;
    PlayState.camFollow.y = 425;
	PlayState.camGame.zoom = 0.8;
}

var addedPico:Bool = false;
var killedDudes:Bool = false;
var catchedGF:Bool = false;

function updatePost()
{
    if (loadedCutsceneAssets) {
        if (demonGf.animation.curAnim != null) {
            if (demonGf.animation.curAnim.name == 'demonGf') {
                demonGf.visible = !demonGf.animation.curAnim.finished;
                PlayState.gf.visible = !demonGf.visible;
                if (PlayState.gf.visible && !addedPico) {
                    PlayState.gf.dance();
                    addedPico = true;
                }
        
                if (demonGf.animation.curAnim.curFrame >= 55 && !killedDudes) { // Pico kills
                    killedDudes = true;
                    john.playAnim('john');
                    steve.playAnim('steve');
                    john.visible = true;
                    steve.visible = true;
                }
        
                if (demonGf.animation.curAnim.curFrame >= 57 && !catchedGF) { // Catch Geef
                    catchedGF = true;
                    beef.visible = false;
                    PlayState.boyfriend.visible = true;
                    PlayState.boyfriend.playAnim('catch');
                    new FlxTimer().start(1, function(tmr) {
                        PlayState.boyfriend.dance();
                        PlayState.boyfriend.animation.curAnim.finish();
                    });
                }
            }
        }
        
        if (cutsceneTankman_Head.animation.curAnim.name == 'godEffingDamnIt') {
            cutsceneTankman_Head.visible = !cutsceneTankman_Head.animation.curAnim.finished;
        }
        
        if (killedDudes) {
            john.visible = !john.animation.curAnim.finished;
            steve.visible = !steve.animation.curAnim.finished;
        }

        if (demonBg.alpha != 0) {
            setShaderFloat('demon_blur', 'u_size', demonBg.alpha);
            setShaderFloat('demon_blur', 'u_alpha', demonBg.alpha);
        }
    }
}