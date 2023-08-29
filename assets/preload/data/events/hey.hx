function eventHit(event) {
    if (event.name == 'hey') {
        switch (event.values[0]) {
            case 'boyfriend':   PlayState.boyfriend.hey();
            case 'dad':         PlayState.dad.hey();
            case 'girlfriend':  PlayState.gf.hey();
        }
    }
}