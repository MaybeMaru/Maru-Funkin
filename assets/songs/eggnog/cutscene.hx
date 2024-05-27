function endSong()
{
    if (PlayState.isStoryMode)
        State.inCutscene = true;
    else closeScript();
}

function startCutscene(onEnd)
{
    if (onEnd)
    {
        State.camGame.visible = false;
        State.camHUD.visible = false;
        playSound("Lights_Shut_off");

        new FlxTimer().start(2, function(tmr:FlxTimer) {
            State.exitSong();
        });
    }
}