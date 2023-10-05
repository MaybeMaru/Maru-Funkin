var blackOverlay:FunkinSprite;
var picoText:FunkinText;

function startCountdown() {
    blackOverlay = new FunkinSprite().makeGraphic(FlxG.width*2, FlxG.height*2, FlxColor.BLACK);
    blackOverlay.cameras = [PlayState.camHUD];
    blackOverlay.visible = false;
    add(blackOverlay);

    var picoString:String =
    'Your computer is unable to process the
    inmmense amounts of notes flying around the
    screen at this time.

    The genocide will be over in just a moment.
    Thank you.';

    picoText = new FunkinText(0,0,picoString,40,0,'center');
    picoText.cameras = [PlayState.camHUD];
    picoText.visible = false;
    picoText.screenCenter();
    picoText.x -= FlxG.width/20;
    add(picoText);
}

function stepHit(curStep) {
    switch(curStep) {
        case 4: PlayState.camZooming = false;
        case 20: blackOverlay.visible = picoText.visible = true;
        case 32:
            blackOverlay.visible = picoText.visible = false;
            PlayState.camZooming = true;
            closeScript();
    }
}