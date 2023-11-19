function eventHit(event) {
    if (event.name == "changeChar") {
        State.switchChar(event.values[0], event.values[1]);
    }
}

var cachedChars = [];
function createPost(){
    for (char in State.SONG.players)
        if (char != null) cachedChars.push(char);

    for (event in State.notesGroup.events){
        if (event.name == "changeChar"){
            var char = event.values[1];
            if (cachedChars.contains(char)) continue; // they already cached fuck off to the next one!!!!!
            cachedChars.push(char);
            cacheCharacter(char);
        }
    }
}