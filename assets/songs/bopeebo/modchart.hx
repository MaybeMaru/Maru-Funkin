function beatHit(curBeat)
{
	if (curBeat % 8 == 7)
	{
		PlayState.boyfriend.hey();
	}
}

var stepHeys:Array<Int> = [190, 446];

function stepHit(curStep)
{
	if (stepHeys.contains(curStep))
	{
		PlayState.boyfriend.playAnim(PlayState.boyfriend.isGF ? 'cheer' : 'hey', true);
	}
}
