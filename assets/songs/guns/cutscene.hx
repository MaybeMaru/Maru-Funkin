var cutsceneTankman_Body:FunkinSprite;
var cutsceneTankman_Head:FunkinSprite;

function create() {
    if (PlayState.isStoryMode && !PlayState.seenCutscene) {
        State.inCutscene = true;

        cutsceneTankman_Body = new FunkinSprite('tankmanCutscene_body', [State.dad.x, State.dad.y + 150]);
        cutsceneTankman_Body.addAnim('tightBars', 'body/BODY_20');

        cutsceneTankman_Head = new FunkinSprite('tankmanCutscene_head', [State.dad.x + 50, State.dad.y]);
        cutsceneTankman_Head.addAnim('tightBars', 'HEAD_20');

        cutsceneTankman_Head.visible = cutsceneTankman_Body.visible = false;
        State.dadGroup.add(cutsceneTankman_Body);
        State.dadGroup.add(cutsceneTankman_Head);
    } else {
        closeScript();
    }
}

function startCutscene() {
    State.showUI(false);
    FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
    FlxG.sound.music.fadeIn(1, 0, 0.8);
    for (i in ['tankSong2']) getSound(i); // Cache sounds

    State.camFollow.x = State.dad.x + 400;
    State.camFollow.y = State.dad.y + 170;

    var manager = makeCutsceneManager();

    manager.pushEvent(0.1, function () { // Pretty thight bars
        State.dad.visible = false;
        cutsceneTankman_Head.visible = cutsceneTankman_Body.visible = true;
        cutsceneTankman_Body.playAnim('tightBars', true);
        cutsceneTankman_Head.playAnim('tightBars', true);
        manager.setSound(getSound("tankSong2"));

        FlxTween.tween(State.camGame, {zoom: State.defaultCamZoom * 1.2}, 4,            {ease: FlxEase.quadInOut});
        FlxTween.tween(State.camGame, {zoom: State.defaultCamZoom * 1.2 * 1.2}, 0.5,    {ease: FlxEase.quadInOut, startDelay: 4});
        FlxTween.tween(State.camGame, {zoom: State.defaultCamZoom * 1.2}, 1,            {ease: FlxEase.quadInOut, startDelay: 4.5});
    });

    manager.pushEvent(4, function () { // Sad gf :(
        State.gf.playAnim('sad', true);
        State.gf.animation.finishCallback = function(){State.gf.playAnim('sad', true); };
    });

    manager.pushEvent(11.5, function () { //End Cutscene
        State.dad.visible = true;
        cutsceneTankman_Body.visible = false;
        cutsceneTankman_Head.visible = false;
        FlxG.sound.music.fadeOut(1.5, 0);
        FlxTween.tween(State.camGame, {zoom: State.defaultCamZoom}, Conductor.crochet / 255, {ease: FlxEase.cubeInOut});
        State.gf.animation.finishCallback = null;
        State.startCountdown();
        closeScript();
    });

    manager.start();
}