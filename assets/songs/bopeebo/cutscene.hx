function createPost() {
    GameVars.isStoryMode && !GameVars.seenCutscene ? PlayState.inCutscene = true : closeScript();
}

function startCutscene() {
    PlayState.createDialogue();
}

function startCountdown() {
    closeScript();
}