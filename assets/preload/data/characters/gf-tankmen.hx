var speaker:FlxSprite;

function createPost():Void {
    ScriptChar.x += 120;
    speaker = new FlxSprite(ScriptChar.x - 190, ScriptChar.y + 305.5);
    speaker.loadImage('characters/speakers');
    speaker.addAnim('speakers', 'speakers');
    ScriptChar.group.insert(0, speaker);

    speaker.flippedOffsets =  ScriptChar.flippedOffsets;
    speaker.flipX = ScriptChar.flipX;
    if (speaker.flippedOffsets) {
        speaker.x += 140;
    }
}

function beatHit():Void {
    speaker.playAnim('speakers', true);
}

function startTimer():Void {
    speaker.playAnim('speakers', true);
}