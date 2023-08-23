function goodNoteHit(note)
{
	if (note.noteType == 'default-hey')
	{
		PlayState.boyfriend.hey();
	}
}

function opponentNoteHit(note)
{
	if (note.noteType == 'default-hey')
	{
		PlayState.dad.hey();
	}
}
