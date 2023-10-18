function beatHit(curBeat)
{
	// SHOFTCODING FOR MILF ZOOMS!
	if (curBeat >= 168 && curBeat < 200 && State.camZooming)// && PlayState.camGame.zoom < 1.35
	{
		State.camGame.zoom += 0.015;
		State.camHUD.zoom += 0.03;
	}
}