function createPost()
{
    if (PlayState.isStoryMode)
        State.inCutscene = true;
}

function startCutscene()
{
    State.createDialogue();
}