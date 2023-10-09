function createPost() {
    if (GameVars.isStoryMode && !GameVars.seenCutscene)
        PlayState.inCutscene = true;
}

function startCutscene() {
    PlayState.createDialogue();
}

function createDialogue() {
    playSound("ANGRY");
    PlayState.dialogueBox = new PixelDialogueBox('mad');
    PlayState.dialogueBox.portraitLeft.alpha = 0;
}

function startDialogue() {
    playSound("ANGRY_TEXT_BOX");
}