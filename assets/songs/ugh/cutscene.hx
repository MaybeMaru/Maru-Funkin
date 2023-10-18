var cutsceneTankman_Body:FunkinSprite;
var cutsceneTankman_Head:FunkinSprite;

function create() {
   if (PlayState.isStoryMode && !PlayState.seenCutscene) {
        State.inCutscene = true;

        cutsceneTankman_Body = new FunkinSprite('tankmanCutscene_body', [State.dad.x, State.dad.y + 155], [1,1]);
        cutsceneTankman_Body.addAnim('wellWellWell', 'body/BODY_1_10');
        cutsceneTankman_Body.addAnim('killYou', 'body/BODY_1_20');
        cutsceneTankman_Body.addOffset('killYou', 40, 5);

        cutsceneTankman_Head = new FunkinSprite('tankmanCutscene_head', [State.dad.x + 60, State.dad.y - 10], [1,1]);
        cutsceneTankman_Head.addAnim('wellWellWell', 'HEAD_1_10');
        cutsceneTankman_Head.addAnim('killYou', 'HEAD_1_20');
        cutsceneTankman_Head.addOffset('wellWellWell', 0, -5);

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
    for (i in ['wellWellWell', 'bfBeep', 'killYou']) getSound(i); // Precaching sounds
    
    State.camGame.zoom /= 0.75;
    State.camFollow.x += 25;
    State.camFollow.y -= 25;

    var manager = makeCutsceneManager();
    
    manager.pushEvent(0.1, function () { // Well Well Well
        State.dad.visible = false;
        cutsceneTankman_Head.visible = cutsceneTankman_Body.visible = true;
        cutsceneTankman_Body.playAnim('wellWellWell', true);
        cutsceneTankman_Head.playAnim('wellWellWell', true);
        manager.setSound(getSound("wellWellWell"));
    });

    manager.pushEvent(3, function () { // Move to bf
        State.camFollow.x += 450;
    });

    manager.pushEvent(4.5, function () { // Bf beep
        manager.setSound(getSound("bfBeep"));
        State.boyfriend.playAnim('singUP', true);
    });
    
    manager.pushEvent(5, function () { // Back to bf idle 
        State.boyfriend.dance();
    });

    manager.pushEvent(6, function () { // Kill you
        State.camFollow.x -= 450;
        manager.setSound(getSound("killYou"));
        cutsceneTankman_Body.playAnim('killYou', true);
        cutsceneTankman_Head.playAnim('killYou', true);
    });

    manager.pushEvent(12, function () { // End cutscene
        State.dad.visible = true;
        cutsceneTankman_Body.visible = false;
        cutsceneTankman_Head.visible = false;
        FlxG.sound.music.fadeOut(1.5, 0);
        FlxTween.tween(State.camGame, {zoom: State.defaultCamZoom}, Conductor.crochet / 255, {ease: FlxEase.cubeInOut});
        State.startCountdown();
        closeScript(); // Close script for better performance
    });

    manager.start();
}