function startCountdown()
{
    for (strum in State.opponentStrums)
        strum.loadSkin('pixel');

    for (note in State.unspawnNotes)
    {
        if (!note.mustPress)
            note.changeSkin('pixel');
    }
}