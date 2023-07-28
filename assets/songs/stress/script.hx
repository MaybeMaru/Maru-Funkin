function musicGameOver() {
    CoolUtil.playSound('jeffGameover/jeffGameover-' + FlxG.random.int(0, 25));
}

function opponentNoteHit(note) {
    PlayState.dad.specialAnim = note.altAnim == '-alt';
}