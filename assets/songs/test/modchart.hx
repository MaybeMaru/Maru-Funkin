function startCountdown()
{
	for (strum in PlayState.opponentStrums)
		strum.loadSkin('pixel');

	for (note in PlayState.unspawnNotes)
	{
		if (!note.mustPress)
			note.changeSkin('pixel');
	}
}
