function createPost()
{
    if (GameVars.isStoryMode)
        PlayState.inCutscene = true;
}

function startCutscene()
{
    PlayState.createDialogue();
}

function createDialogue()
{
    playSound("ANGRY");
    PlayState.dialogueBox = new PixelDialogueBox('mad');
    PlayState.dialogueBox.portraitLeft.alpha = 0;
}