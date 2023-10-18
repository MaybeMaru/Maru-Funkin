function endSong()
{
    if (PlayState.isStoryMode)
        State.inCutscene = true;
}

function startCutscene(onEnd)
{
    if (onEnd)
    {
        var blackScreen:FlxSprite = new FlxSprite(-900, -450).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.fromRGB(0,0,0));
        add(blackScreen);
        blackScreen.scrollFactor.set();
        State.camHUD.visible = false;
        playSound("Lights_Shut_off");

        new FlxTimer().start(2, function(tmr:FlxTimer) {
            State.exitSong();
        });
    }
}