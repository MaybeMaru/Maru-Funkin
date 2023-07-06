function createPost()
{
   if (GameVars.isStoryMode)
        PlayState.inCutscene = true;
}

function startCutscene()
{
    var red:FlxSprite = new FlxSprite(-400, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
    PlayState.add(red);

    var senpaiEvil:FlxSprite = new FlxSprite();
    senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
    senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
    senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
    senpaiEvil.scrollFactor.set();
    senpaiEvil.updateHitbox();
    senpaiEvil.screenCenter();
    senpaiEvil.alpha = 0;
    PlayState.add(senpaiEvil);

    PlayState.camHUD.visible = false;

    new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
    {
        senpaiEvil.alpha += 0.15;
        if (senpaiEvil.alpha < 1)
        {
            swagTimer.reset();
        }
        else
        {
            senpaiEvil.animation.play('idle');
            FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
            {
                PlayState.remove(senpaiEvil);
                PlayState.remove(red);
                PlayState.camGame.fade(FlxColor.fromRGB(255,255,255), 0.01, true, function()
                {
                    PlayState.camHUD.visible = true;
                    PlayState.createDialogue();
                }, true);
            });
            new FlxTimer().start(3.2, function(deadTime:FlxTimer)
            {
                PlayState.camGame.fade(FlxColor.fromRGB(255,255,255), 1.6, false);
            });
        }
    });
}

var face:FlxSprite;
var bgFade:FlxSprite;
var dialogueBox:DialogueBox;

function createDialogue()
{
    bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), FlxColor.fromRGB(25,0,5));
    bgFade.scrollFactor.set();
    bgFade.alpha = 0;
    PlayState.add(bgFade);

    face = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
    face.setGraphicSize(Std.int(face.width * 6));
    face.cameras = [PlayState.camHUD];
    PlayState.add(face);

    dialogueBox = new PixelDialogueBox('evil');
    dialogueBox.cameras = [PlayState.camHUD];

    dialogueBox.handSelect = new FlxSprite(FlxG.width * 0.79, FlxG.height * 0.78);
    dialogueBox.handSelect.frames = Paths.getSparrowAtlas('pixelUI/evil_hand');
    dialogueBox.handSelect.animation.addByPrefix('enter', 'nextLine', 12, false);
    dialogueBox.handSelect.animation.addByPrefix('load', 'waitLine', 12, true);
    dialogueBox.handSelect.animation.addByPrefix('click', 'clickLine', 12, false);
    dialogueBox.handSelect.setGraphicSize(Std.int(dialogueBox.handSelect.width * GameVars.daPixelZoom * 0.9));
    dialogueBox.handSelect.updateHitbox();
    dialogueBox.handSelect.alpha = 0;
    dialogueBox.handSelect.animation.play('load');
    dialogueBox.add(dialogueBox.handSelect);

    dialogueBox.bgFade.visible = false;
    dialogueBox.portraitLeft.alpha = 0;
    dialogueBox.swagDialogue.color = FlxColor.fromRGB(255,255,255);
    dialogueBox.swagDialogue.borderColor = FlxColor.fromRGB(0,0,0);

    PlayState.dialogueBox = dialogueBox;
    PlayState.add(dialogueBox);
}

function updatePost()
{
    if (dialogueBox != null)
    {
        face.alpha = dialogueBox.box.alpha;
        bgFade.alpha = dialogueBox.bgFade.alpha;
    }
}

function startCountdown()
{
    if (GameVars.isStoryMode)
    {
        face.destroy();
        bgFade.destroy();
    }
}