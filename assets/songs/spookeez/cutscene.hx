// It would be so awesome, it would be so cool
var scriptedThunder:Array<Int> = [4,144,160,176,192,208,224];
var overlay;

function createPost() {
    State.defaultCamZoom = 1.2;
    State.camGame.zoom = State.defaultCamZoom;
    overlay = new FlxSprite(-500, -500).makeRect(FlxG.width*2, FlxG.height*2, 0xff32325a);
    overlay.blend = getBlendMode('multiply');
    overlay.alpha = 0.8;
    addSpr(overlay, 'overlay', true);
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
        overlay.visible = false;
        State.showUI(true);
        State.defaultCamZoom = 1.05;
    }
}