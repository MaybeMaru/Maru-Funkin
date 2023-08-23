function createPost()
{
	if (GameVars.isStoryMode)
		PlayState.inCutscene = true;
}

function startCutscene()
{
	PlayState.createDialogue();
}
