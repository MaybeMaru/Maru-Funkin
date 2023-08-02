var speaker:FlxSprite;
var parts:Array<FlxSprite> = [];

function createPost():Void {
    ScriptChar.x += 120;
    speaker = new FlxSprite(ScriptChar.x - 190, ScriptChar.y + 305.5);
    speaker.loadImage('characters/speakers');
    speaker.addAnim('speakers', 'speakers');
    ScriptChar.group.insert(0, speaker);

    for (i in 0...2) {
        var body:FlxSprite = new FlxSprite(speaker.x, speaker.y - 85).loadImage('characters/speakers/tankmanBodyPart');
        body.addAnim('idle', 'tankmanBody');
        body.flipX = i == 0;
        body.x += (i == 0 ? -100 : 510);
        ScriptChar.group.insert(0, body);
        parts.push(body);

        var headStr = 'tankmanTop'+ (i + 1);
        var head:FlxSprite = new FlxSprite(speaker.x, speaker.y - 215).loadImage('characters/speakers/' + headStr);
        head.x += (i != 0 ? -120 : 445);
        head.addAnim('idle', headStr);
        head.flipX = i != 0;
        ScriptChar.group.add(head);
        parts.push(head);
    }

    speaker.flippedOffsets =  ScriptChar.flippedOffsets;
    speaker.flipX = ScriptChar.flipX;
    if (speaker.flippedOffsets) {
        speaker.x += 140;
    }
}

function dance():Void {
    speaker.playAnim('speakers', true);
    for (i in parts) {
        i.playAnim('idle', true);
    }
}

function beatHit():Void {
    dance();
}

function startTimer():Void {
    dance();
}

function startCutscene() {
    dance();
    ScriptChar.animation.curAnim.finish();
    speaker.animation.curAnim.finish();
    for (i in parts) {
        i.animation.curAnim.finish();
    }
}