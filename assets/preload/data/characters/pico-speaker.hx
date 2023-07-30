importLib('Song', 'funkin.util.song');

var speaker:FlxSprite;
var picoNotes_ = [];

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

    if (Paths.exists(Paths.chart(GameVars.SONG.song, 'picospeaker'), "TEXT")) {
        picoNotes_ = Song.getSongNotes('picospeaker',  GameVars.SONG.song);
    }
}

function beatHit():Void {
    speaker.playAnim('speakers', true);
}

function startTimer():Void {
    speaker.playAnim('speakers', true);
}

function updatePost()
{
    if (picoNotes_.length > 0) {
        if(Conductor.songPosition > picoNotes_[0][0])
        {
            var shootAnim:Int = 1;
            if (picoNotes_[0][1] >= 2)
                shootAnim = 3;
            shootAnim += FlxG.random.int(0, 1);

            ScriptChar.playAnim('shoot'+shootAnim, true);
            ScriptChar.specialAnim = true;
            ScriptChar.forceDance = false;
            picoNotes_.shift();
        }
    }
}