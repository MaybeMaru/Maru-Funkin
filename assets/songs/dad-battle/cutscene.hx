function createPost() {
    PlayState.isStoryMode && !PlayState.seenCutscene ? State.inCutscene = true : closeScript();
}

function startCutscene() {
    State.createDialogue();
}

function startCountdown() {
    closeScript();
}