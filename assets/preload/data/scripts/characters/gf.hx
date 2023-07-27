var speaker:FlxSprite;

function createPost():Void {
    ScriptChar.x += 120;
    speaker = new FlxSprite(ScriptChar.x - 190, ScriptChar.y + 300);
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

function updatePost():Void {
    if (ScriptChar.animation.curAnim != null) {
        if (ScriptChar.forceDance) {
            ScriptChar.forceDance = !StringTools.startsWith(ScriptChar.animation.curAnim.name, 'hair');
        }

        switch (ScriptChar.animation.curAnim.name) {
            case 'singLEFT':            ScriptChar.danced = true;
            case 'singRIGHT':           ScriptChar.danced = false;
            case 'singUP' | 'singDOWN': ScriptChar.danced = !ScriptChar.danced;
            case 'hairFall':
                if (ScriptChar.animation.curAnim.finished) {
                    ScriptChar.forceDance = true;
                    ScriptChar.playAnim('danceRight', true);
                }
        }
    }
}