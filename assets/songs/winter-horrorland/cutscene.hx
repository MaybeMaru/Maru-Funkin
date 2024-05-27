function createPost()
{
    if (PlayState.isStoryMode && !PlayState.seenCutscene)
        State.inCutscene = true;
    else closeScript();
}

function startCutscene()
{
    State.showUI(false);
    State.camGame.visible = false;
    State.camHUD.visible = false;

    var manager = makeCutsceneManager();
    
    manager.pushEvent(0.1, function() {
        State.camGame.visible = true;
        State.camHUD.visible = true;
        playSound("Lights_Turn_On");

        State.camFollow.setPosition(500,-1500);
        State.camGame.focusOn(State.camFollow.getPosition());
        State.camGame.zoom = 1.5;
    });

    manager.pushEvent(0.9, function () {
        State.camHUD.visible = true;
        FlxTween.tween(State.camGame, {zoom: State.defaultCamZoom}, 2.5, {
            ease: FlxEase.quadInOut,
            onComplete: function(twn:FlxTween)
            {
                State.startCountdown();
                closeScript();
            }
        });
    });

    manager.start();
}