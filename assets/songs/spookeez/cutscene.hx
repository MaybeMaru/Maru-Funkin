// It would be so awesome, it would be so cool
var scriptedThunder:Array<Int> = [4,144,160,176,192,208,224];

function createPost() {
    State.defaultCamZoom = 1.2;
    State.camGame.zoom = State.defaultCamZoom;
    var intro:FunkinSprite = new FunkinSprite('', [-200,-200], [1,1]).makeGraphic(FlxG.width*2, FlxG.height*2, 0xff150415);
    intro.blend = getBlendMode('multiply');
    intro.alpha = 0.6;
    addSpr(intro, 'intro', true);
}

function startCountdown() {
    State.showUI(false);
}

function beatHit(curBeat) {
    var closeThunder:Bool = false;
    for (i in scriptedThunder) {
        if (curBeat == i) {
            closeThunder = true;
            getSpr('bg')._dynamic.thunder(false);
            break;
        }
        if (curBeat + 8 > i && curBeat - 8 < i ) {
            closeThunder = true;
            break;
        }
    }
    if (!closeThunder) getSpr('bg')._dynamic.calcThunder();

    if (curBeat == 4) {
        getSpr('intro').visible = false;
        State.showUI(true);
        State.defaultCamZoom = 1.05;
    }
}