function createPost()
{
    if (GameVars.isStoryMode)
        PlayState.inCutscene = true;
}

function switchSong() {
    GameVars.clearCache = true;
}

function startCutscene()
{
    PlayState.createDialogue();
}

function createDialogue()
{
    FlxG.sound.play(Paths.sound('ANGRY'));
    PlayState.dialogueBox = new PixelDialogueBox('mad');
    PlayState.dialogueBox.portraitLeft.alpha = 0;
}

function updatePost()
{
    if (PlayState.inCutscene) FlxG.sound.music.volume = 0;
}