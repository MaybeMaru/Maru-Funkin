function beatHit(curBeat)
{
	// SHOFTCODING FOR MILF ZOOMS!
	if (curBeat >= 168 && curBeat < 200 && State.camZooming && getPref('camera-zoom'))
	{
		State.camGame.zoom += 0.015;
		State.camHUD.zoom += 0.03;
	}
}