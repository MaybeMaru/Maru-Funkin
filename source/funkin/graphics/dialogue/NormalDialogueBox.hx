package funkin.graphics.dialogue;

class NormalDialogueBox extends DialogueBoxBase {
    public var speechBubble:FunkinSprite;
    public var swagDialogue:TypedAlphabet;
    public var blackBG:FlxSprite;

    public var portraitGroup:FlxSpriteGroup;
	public var portraitDad:NormalPortrait;
	public var portraitBf:NormalPortrait;
    public var portraitGf:NormalPortrait;

    public function new():Void {
        super();
        blackBG = new FlxSprite(-100,-100).makeGraphic(FlxG.width*2, FlxG.height*2, FlxColor.BLACK);
        blackBG.alpha = 0;
        add(blackBG);

        portraitGroup = new FlxSpriteGroup();
		add(portraitGroup);

        portraitDad = new NormalPortrait(dialogueChars[0]);
        portraitDad.flipX = true;
		portraitBf = new NormalPortrait(dialogueChars[1], true);
		portraitGroup.add(portraitDad);
		portraitGroup.add(portraitBf);

        portraitGf = new NormalPortrait(dialogueChars[2]);
        portraitGroup.add(portraitGf);

        for (portrait in portraitGroup)
            portrait.visible = false;

        speechBubble = new FunkinSprite('speechBubble', [0, FlxG.height*0.5], [0,0]);
        speechBubble.addAnim('open-normal', 'normal-open');
        speechBubble.addAnim('idle-normal', 'normal-idle', 24, true);
        speechBubble.addAnim('open-loud', 'loud-open');
        speechBubble.addAnim('idle-loud', 'loud-idle', 24, true, null, [50,75]);
        speechBubble.playAnim('open-normal');
        speechBubble.screenCenter(X);
        speechBubble.x += 25;
        add(speechBubble);

        swagDialogue = new TypedAlphabet(speechBubble.x + 75, speechBubble.y + 125, "", false, Std.int(FlxG.width/2.25), 0.8);
        swagDialogue.sounds = ['pixelText'];
        add(swagDialogue);

        skipCallback = skipDialogue;
        endCallback = function playShit() {FlxG.sound.play(Paths.sound('clickText'), 0.8);};
        nextCallback = function playShit() {FlxG.sound.play(Paths.sound('clickText'), 0.8);};
		startCallback = function nothing() {};
    }

    override public function update(elapsed:Float):Void {
        textFinished = swagDialogue.text.length == targetDialogue.length;

        if (!isEnding)
            portraitGf.screenCenter(X);

        if (speechBubble.animation.curAnim != null) {
            if (speechBubble.animation.curAnim.name.startsWith('open') && speechBubble.animation.curAnim.finished) {
                FlxTween.tween(blackBG, {alpha: 0.4}, 0.5, {ease: FlxEase.circIn,});
                speechBubble.playAnim('idle-normal');
                dialogueOpened = true;
            }
        }

		super.update(elapsed);
    }

    function skipDialogue():Void {
        swagDialogue.skip();
    }

    override public function startDialogue():Void  {
        super.startDialogue();

        speechBubble.playAnim('idle-$curBubbleType');

        swagDialogue.resetText(targetDialogue);
		swagDialogue.start(0.04);

        portraitDad.talking = false;
        portraitBf.talking = false;
        portraitGf.talking = false;

        switch (curCharData) {
			case 0:
                portraitDad.talkAnim = curTalkAnim;
                portraitDad.talking = true;
                portraitDad.visible = true;
                speechBubble.flipX = true;
			case 1:
                portraitBf.talkAnim = curTalkAnim;
                portraitBf.talking = true;
                portraitBf.visible = true;
                speechBubble.flipX = false;
            case 2:
                portraitGf.talkAnim = curTalkAnim;
                portraitGf.talking = true;
                portraitGf.visible = true;
                speechBubble.flipX = false;
		}
    }

    override public function endDialogue():Void  {
        super.endDialogue();
        if (!isEnding) return;

        FlxTween.tween(blackBG, {alpha: 0}, 1, {ease: FlxEase.circIn,});
        FlxTween.tween(speechBubble, {y: speechBubble.y + 1000}, 1, {ease: FlxEase.circIn});
        FlxTween.tween(swagDialogue, {y: swagDialogue.y + 1000}, 1, {ease: FlxEase.circIn});

        FlxTween.tween(portraitDad, {x: portraitDad.x - 1000}, 1, {ease: FlxEase.circIn});
        FlxTween.tween(portraitBf, {x: portraitBf.x + 1000}, 1, {ease: FlxEase.circIn});
        FlxTween.tween(portraitGf, {x: portraitGf.x + 1000}, 1, {ease: FlxEase.circIn});
    }
}

typedef PortraitJson = {
    var offset:Array<Float>;
    var bigScale:Float;
    var smallScale:Float;
} & SpriteJson;

class NormalPortrait extends FunkinSprite {

    public var talkAnim:String = 'talk';
    public var talking:Bool = false;
    public var faceJsonData:PortraitJson;

    public function new(path:String, isPlayer:Bool = false):Void {
        super('portraits/$path', [0,0], [0,0]);
		faceJsonData = Json.parse(CoolUtil.getFileContent(Paths.getPath('images/portraits/$path.json', TEXT, null)));
        faceJsonData.offset[0] -= isPlayer ? FlxG.width*0.7: 0;

        x = -faceJsonData.offset[0];
        y = -faceJsonData.offset[1];
        for (anim in faceJsonData.anims) {
            addAnim(anim.animName, anim.animFile, anim.framerate, anim.loop, anim.indices, anim.offsets);
        }

        scale.set(faceJsonData.smallScale,faceJsonData.smallScale);
        color = FlxColor.GRAY;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        var anim:String = 'idle';
        var targetColor:Int = FlxColor.GRAY;
        var targetScale:Float = faceJsonData.smallScale;
        var targetY:Float = -(faceJsonData.offset[1] - (height * faceJsonData.smallScale) / 2);

        if (talking) {
            anim = talkAnim;
            targetColor = FlxColor.WHITE;
            targetScale = faceJsonData.bigScale;
            targetY = -faceJsonData.offset[1];
        }

        playAnim(anim);
        color = FlxColor.interpolate(color, targetColor, CoolUtil.getLerp(0.3));
        var scaleLerp = CoolUtil.coolLerp(scale.x, targetScale, 0.3);
        scale.set(scaleLerp, scaleLerp);
        y = CoolUtil.coolLerp(y, targetY, 0.3);
        updateHitbox();
    }
}