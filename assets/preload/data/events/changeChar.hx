function eventHit(event) {
    if (event.name == "changeChar") {
        PlayState.switchChar(event.values[0], event.values[1]);
    }
}