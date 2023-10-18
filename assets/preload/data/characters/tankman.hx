var ending:Bool = false;

function musicGameOver() {
    if (ScriptChar == State.dad) {
        FlxG.sound.music.volume = 0.2;
		var randomGameover = FlxG.random.int(1, 25, (getPref('naughty') ? [] : [1, 3, 8, 13, 17, 21]));
        FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + randomGameover, "weeks", "week7"), 1, false, null, true, function() {
            if (!ending)
                FlxG.sound.music.fadeIn(4, 0.2, 1);
        });
    }
}

function resetGameOver() {
    ending = true;
}

function opponentNoteHit(note) {
    if (ScriptChar == State.dad && note.noteData == 1) {
        ScriptChar.specialAnim = note.altAnim == '-alt';
    }
}

function goodNoteHit(note) {
    if (ScriptChar == State.boyfriend && note.noteData == 1) {
        ScriptChar.specialAnim = note.altAnim == '-alt';
    }
}