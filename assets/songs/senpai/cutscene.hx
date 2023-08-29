function createPost()
{
    if (GameVars.isStoryMode && !GameVars.seenCutscene)
        PlayState.inCutscene = true;
}

function startCutscene()
{
    PlayState.createDialogue();
}