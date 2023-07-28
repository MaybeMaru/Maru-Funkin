function createPost()
{
    if (GameVars.isStoryMode)
        PlayState.inCutscene = true;
}

function startCutscene()
{
    var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
    PlayState.add(blackScreen);
    blackScreen.scrollFactor.set();
    PlayState.camHUD.visible = false;

    new FlxTimer().start(0.1, function(tmr:FlxTimer)
    {
        PlayState.remove(blackScreen);
        FlxG.sound.play(Paths.sound('Lights_Turn_On'));
        PlayState.camFollow.setPosition(500,-1500);
        PlayState.camGame.focusOn(PlayState.camFollow.getPosition());
        PlayState.camGame.zoom = 1.5;

        new FlxTimer().start(0.8, function(tmr:FlxTimer)
        {
            PlayState.camHUD.visible = true;
            FlxTween.tween(PlayState.camGame, {zoom: PlayState.defaultCamZoom}, 2.5, {
                ease: FlxEase.quadInOut,
                onComplete: function(twn:FlxTween)
                {
                    PlayState.startCountdown();
                }
            });
        });
    });
}