function beatHit(curBeat)
{
	// SHOFTCODING FOR MILF ZOOMS!
	if (curBeat >= 168 && curBeat < 200 && PlayState.camZooming)// && PlayState.camGame.zoom < 1.35
	{
		PlayState.camGame.zoom += 0.015;
		PlayState.camHUD.zoom += 0.03;
	}
}