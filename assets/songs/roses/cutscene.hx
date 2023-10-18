function createPost() {
    if (PlayState.isStoryMode && !PlayState.seenCutscene)
        State.inCutscene = true;
}

function startCutscene() {
    State.createDialogue();
}

function createDialogue() {
    playSound("ANGRY");
    State.dialogueBox = new PixelDialogueBox('mad');
    State.dialogueBox.portraitLeft.alpha = 0;
}

function startDialogue() {
    playSound("ANGRY_TEXT_BOX");
}