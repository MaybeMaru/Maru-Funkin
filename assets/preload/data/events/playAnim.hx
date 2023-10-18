function eventHit(event) {
    if (event.name == 'playAnim') {
        var anim = event.values[1];
        var forced = event.values[2];
        var special = event.values[3];
        switch (event.values[0]) {
            case 'boyfriend':
                State.boyfriend.playAnim(anim, forced);
                State.boyfriend.specialAnim = special;
            case 'dad':
                State.dad.playAnim(anim, forced);
                State.dad.specialAnim = special;
            case 'girlfriend':
                State.gf.playAnim(anim, forced);
                State.gf.specialAnim = special;
        }
    }
}