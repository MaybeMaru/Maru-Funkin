function eventHit(event) {
    if (event.name == 'playAnim') {
        var anim = event.values[1];
        var forced = event.values[2];
        var special = event.values[3];
        switch (event.values[0]) {
            case 'boyfriend':
                PlayState.boyfriend.playAnim(anim, forced);
                PlayState.boyfriend.specialAnim = special;
            case 'dad':
                PlayState.dad.playAnim(anim, forced);
                PlayState.dad.specialAnim = special;
            case 'girlfriend':
                PlayState.gf.playAnim(anim, forced);
                PlayState.gf.specialAnim = special;
        }
    }
}