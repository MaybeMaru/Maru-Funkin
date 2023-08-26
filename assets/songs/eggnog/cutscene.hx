function endSong()
{
    if (GameVars.isStoryMode)
        PlayState.inCutscene = true;
}

function startCutscene(onEnd)
{
    if (onEnd)
    {
        var blackScreen:FlxSprite = new FlxSprite(-900, -450).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.fromRGB(0,0,0));
        PlayState.add(blackScreen);
        blackScreen.scrollFactor.set();
        PlayState.camHUD.visible = false;
        FlxG.sound.play(Paths.sound('Lights_Shut_off'));

        new FlxTimer().start(2, function(tmr:FlxTimer)
        {
            PlayState.switchSong();
        });
    }
}