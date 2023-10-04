var cutsceneTankman_Body:FunkinSprite;
var cutsceneTankman_Head:FunkinSprite;

function create() {
    if (GameVars.isStoryMode && !GameVars.seenCutscene) {
        PlayState.inCutscene = true;

        cutsceneTankman_Body = new FunkinSprite('tankmanCutscene_body', [PlayState.dad.x, PlayState.dad.y + 150]);
        cutsceneTankman_Body.addAnim('tightBars', 'body/BODY_20');

        cutsceneTankman_Head = new FunkinSprite('tankmanCutscene_head', [PlayState.dad.x + 60, PlayState.dad.y - 10]);
        cutsceneTankman_Head.addAnim('tightBars', 'HEAD_20');

        cutsceneTankman_Head.visible = cutsceneTankman_Body.visible = false;
        PlayState.dadGroup.add(cutsceneTankman_Body);
        PlayState.dadGroup.add(cutsceneTankman_Head);
    } else {
        closeScript();
    }
}

function startCutscene() {
    PlayState.showUI(false);
    FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
    FlxG.sound.music.fadeIn(1, 0, 0.8);
    for (i in ['tankSong2']) getSound(i); // Cache sounds

    PlayState.camFollow.x = PlayState.dad.x + 400;
    PlayState.camFollow.y = PlayState.dad.y + 170;

    var manager = makeCutsceneManager();

    manager.pushEvent(0.1, function () { // Pretty thight bars
        PlayState.dad.visible = false;
        cutsceneTankman_Head.visible = cutsceneTankman_Body.visible = true;
        cutsceneTankman_Body.playAnim('tightBars', true);
        cutsceneTankman_Head.playAnim('tightBars', true);
        manager.setSound(getSound("tankSong2"));

        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom * 1.2}, 4,            {ease: FlxEase.quadInOut});
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom * 1.2 * 1.2}, 0.5,    {ease: FlxEase.quadInOut, startDelay: 4});
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom * 1.2}, 1,            {ease: FlxEase.quadInOut, startDelay: 4.5});
    });

    manager.pushEvent(4, function () { // Sad gf :(
        PlayState.gf.playAnim('sad', true);
        PlayState.gf.animation.finishCallback = function(){PlayState.gf.playAnim('sad', true); };
    });

    manager.pushEvent(11.5, function () { //End Cutscene
        PlayState.dad.visible = true;
        cutsceneTankman_Body.visible = false;
        cutsceneTankman_Head.visible = false;
        FlxG.sound.music.fadeOut(1.5, 0);
        FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom}, Conductor.crochet / 255, {ease: FlxEase.cubeInOut});
        PlayState.gf.animation.finishCallback = null;
        PlayState.startCountdown();
        closeScript();
    });

    manager.start();
}