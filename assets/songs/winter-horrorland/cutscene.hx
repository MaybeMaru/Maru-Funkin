function createPost()
{
    if (PlayState.isStoryMode && !PlayState.seenCutscene)
        State.inCutscene = true;
}

function startCutscene()
{
    var blackScreen:FlxSprite = new FlxSprite(0, 0).makeRect(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
    add(blackScreen);
    blackScreen.scrollFactor.set();
    State.camHUD.visible = false;

    new FlxTimer().start(0.1, function(tmr:FlxTimer)
    {
        remove(blackScreen);
        FlxG.sound.play(Paths.sound('Lights_Turn_On'));
        State.camFollow.setPosition(500,-1500);
        State.camGame.focusOn(State.camFollow.getPosition());
        State.camGame.zoom = 1.5;

        new FlxTimer().start(0.8, function(tmr:FlxTimer)
        {
            State.camHUD.visible = true;
            FlxTween.tween(State.camGame, {zoom: State.defaultCamZoom}, 2.5, {
                ease: FlxEase.quadInOut,
                onComplete: function(twn:FlxTween)
                {
                    State.startCountdown();
                }
            });
        });
    });
}