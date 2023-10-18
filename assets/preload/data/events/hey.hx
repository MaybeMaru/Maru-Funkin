function eventHit(event) {
    if (event.name == 'hey') {
        switch (event.values[0]) {
            case 'boyfriend':   State.boyfriend.hey();
            case 'dad':         State.dad.hey();
            case 'girlfriend':  State.gf.hey();
        }
    }
}