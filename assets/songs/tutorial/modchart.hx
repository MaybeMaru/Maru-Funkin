function beatHit(curBeat)
{
    if (curBeat % 16 == 15 && curBeat > 16 && curBeat < 48)
	{
		State.boyfriend.playAnim('hey', true);
		State.dad.playAnim('cheer', true);
	}
}

function cameraMovement(move)
{
    switch(move)
    {
        case 0://IN
            FlxTween.tween(State.camGame, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
        case 1://OUT
            FlxTween.tween(State.camGame, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
    }
}

function opponentNoteHit()
{
    State.camZooming = false;
}