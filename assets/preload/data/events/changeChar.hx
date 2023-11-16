function eventHit(event) {
    if (event.name == "changeChar") {
        State.switchChar(event.values[0], event.values[1]);
    }
}

var cached = [];
var already = false;
function createPost(){
    for(char in State.SONG.players)
        if(char != null) cached.push(char);

    for(event in State.notesGroup.events){
        if(event.name == 'changeChar'){
            already = false;
            for(cachedChar in cached){
                if(cachedChar == event.values[1]){
                    already = true;
                    break; 
                }
            }
            if(already) continue; // they already cached fuck off to the next one!!!!!
            cached.push(event.values[1]);
            cacheCharacter(event.values[1]);
        }
    }
}