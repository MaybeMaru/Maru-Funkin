function postCreateDialogue() {
    State.openDialogueFunc = function () {
        var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
        black.scrollFactor.set();
        add(black);
    
        if(State.dialogueBox != null && State.dialogueBox.skipIntro) black.alpha = 0;
        new FlxTimer().start(0.3, function(tmr:FlxTimer) {
            black.alpha -= 0.15;
            if (black.alpha > 0)	tmr.reset(0.3);
            else {
                State.quickDialogueBox();
                remove(black);
            }
        });
    }
}

function updatePost() {
    for (i in State.strumLineNotes) {
        i.alpha = Math.round(i.alpha / 0.2) * 0.2;
        i.y = Math.round(i.y / 0.6) * 0.6;
    }
}

function startSong() {
    closeScript();
}