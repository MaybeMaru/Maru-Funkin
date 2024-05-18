function createPost() {
    if (PlayState.isStoryMode && !PlayState.seenCutscene)   State.inCutscene = true;
    else                                                    closeScript();
}

var whiteFade = null;

function startCutscene()
{
    var red = new FlxSprite(-400, -100).makeRect(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
    add(red);

    var senpaiEvil = new FunkinSprite('weeb/senpaiCrazy', [0,0], [0,0]);
    senpaiEvil.addAnim('preCutscene', 'Senpai Pre Explosion instance 1', 24, false, [0]);
    senpaiEvil.addAnim('cutscene', 'Senpai Pre Explosion instance 1');
    senpaiEvil.playAnim('preCutscene');
    senpaiEvil.setScale(6, false);
    senpaiEvil.screenCenter();
    senpaiEvil.x += 50;
    senpaiEvil.alpha = 0;
    add(senpaiEvil);

    State.camHUD.visible = false;

    whiteFade = new FlxSprite().makeRect(FlxG.width, FlxG.height, FlxColor.WHITE);
    whiteFade.camera = State.camOther;
    whiteFade.alpha = 0;
    add(whiteFade);

    var manager = makeCutsceneManager(); 

    for (i in 0...8) manager.pushEvent(i*0.3, function () {
        senpaiEvil.alpha += 0.15;
    });

    manager.pushEvent(2, function () {
        senpaiEvil.playAnim('cutscene');
        FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function() {
            senpaiEvil.destroy();
            red.destroy();

            State.camHUD.visible = true;
            State.createDialogue();
            FlxTween.tween(whiteFade, {alpha: 0}, 0.6);
        });
    });

    manager.pushEvent(5.3, function () {
        FlxTween.tween(whiteFade, {alpha: 1}, 1.6);
    });

    manager.start();
}

var bgFade;
var dialogueBox;
var face;
var inDialogue = false;

function createDialogue()
{
    State.openDialogueFunc = function () {
        State.quickDialogueBox();
    }

    bgFade = new FlxSprite().makeRect(FlxG.width, FlxG.height, 0xff190005);
    bgFade.scrollFactor.set();
    bgFade.alpha = 0;
    add(bgFade);

    face = new FunkinSprite('weeb/spiritFaceForward', [320, 170]);
    face.setScale(6, false);
    face.cameras = [State.camHUD];
    add(face);

    initShader('thornsBg', 'faceShader');
    setShaderInt('faceShader', 'effectType', 1);
    setShaderFloat('faceShader', 'uFrequency', 10);
    setSpriteShader(face, 'faceShader');

    dialogueBox = new PixelDialogueBox('evil');
    dialogueBox.cameras = [State.camHUD];

    var handPos = dialogueBox.handSelect.getPosition();
    dialogueBox.handSelect = new FunkinSprite('skins/pixel/evil_hand', [handPos.x,handPos.y], [0,0]);
    
    var hand = dialogueBox.handSelect;
    hand.addAnim('enter', 'nextLine', 12);
    hand.addAnim('load', 'waitLine', 12, true);
    hand.addAnim('click', 'clickLine', 12);
    hand.setScale(6 * 0.9);
    hand.playAnim('load');
    dialogueBox.add(hand);

    dialogueBox.bgFade.visible = false;
    dialogueBox.portraitLeft.alpha = 0;
    dialogueBox.swagDialogue.color = FlxColor.WHITE;
    dialogueBox.swagDialogue.borderColor = FlxColor.TRANSPARENT;

    State.dialogueBox = dialogueBox;
    add(dialogueBox);
    inDialogue = true;
}

var timeElapsed = 0.0;
function updatePost(elapsed)
{
    if (dialogueBox != null && inDialogue) {
        bgFade.alpha = dialogueBox.bgFade.alpha;
        face.alpha = dialogueBox.box.alpha;
        face.offset.y = FlxMath.roundDecimal(FunkMath.sin(timeElapsed += elapsed), 1) * 10;
    }

    if (whiteFade != null)
        whiteFade.alpha = FlxMath.roundDecimal(whiteFade.alpha / 8, 2) * 8;
}

function startCountdown() {
    if (inDialogue) {
        inDialogue = false;
        face.destroy();
        bgFade.destroy();
        whiteFade.destroy();
        closeScript();
    }
}