function goodNoteHit(note) {
    if (note.noteType == 'default-hey') {
        State.boyfriend.hey();
    }
}

function opponentNoteHit(note) {
    if (note.noteType == 'default-hey') {
        State.dad.hey();
    }
}