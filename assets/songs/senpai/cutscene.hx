function createPost()
{
    if (PlayState.isStoryMode && !PlayState.seenCutscene)
        State.inCutscene = true;
}

function startCutscene()
{
    State.createDialogue();
}