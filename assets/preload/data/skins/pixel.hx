function postCreateDialogue() {
    PlayState.openDialogueFunc = function () {
        var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
        black.scrollFactor.set();
        add(black);
    
        if(PlayState.dialogueBox != null && PlayState.dialogueBox.skipIntro) black.alpha = 0;
        new FlxTimer().start(0.3, function(tmr:FlxTimer) {
            black.alpha -= 0.15;
            if (black.alpha > 0)	tmr.reset(0.3);
            else {
                PlayState.quickDialogueBox();
                remove(black);
            }
        });
    }
}