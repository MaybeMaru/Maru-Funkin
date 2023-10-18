function beatHit(curBeat) {
    if (curBeat % 8 == 7) {
        State.boyfriend.hey();
    }
}

var stepHeys:Array<Int> = [190,446];
function stepHit(curStep) {
    if (stepHeys.contains(curStep)) {
        State.boyfriend.playAnim(State.boyfriend.isGF ? 'cheer' : 'hey',true);
    }
}