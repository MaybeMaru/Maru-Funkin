function eventHit(event) {
    if (event.name == "changeChar") {
        State.switchChar(event.values[0], event.values[1]);
    }
}