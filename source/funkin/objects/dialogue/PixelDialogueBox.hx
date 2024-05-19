package funkin.objects.dialogue;
import flixel.addons.text.FlxTypeText;

typedef PixelBox = {
	var box:String;
	var openAnim:String;
}

class PixelDialogueBox extends DialogueBoxBase
{
	public static inline var PIXEL_ZOOM:Int = 6;
	public static final boxTypes:Map<String, PixelBox> = [
		"pixel" => {
			box: "pixel/dialogueBox-pixel",
			openAnim: "Text Box Appear"
		},
		"mad" => {
			box: "pixel/dialogueBox-senpaiMad",
			openAnim: "SENPAI ANGRY IMPACT SPEECH"
		},
		"evil" => {
			box: "pixel/dialogueBox-evil",
			openAnim: "Spirit Textbox spawn"
		}
	];

	public var boxType:String = 'pixel';
	public var portraitGroup:FlxSpriteGroup;
	public var portraitLeft:PixelPortrait;
	public var portraitRight:PixelPortrait;

	public var box:FlxSpriteExt;
	public var swagDialogue:FlxTypeText;
	public var handSelect:FlxSpriteExt;
	public var bgFade:FlxSpriteExt;

	public var clickSound:FlxSound = null;

	public function new(skin:String = 'pixel'):Void {
		super();

		bgFade = new FlxSpriteExt(-200, -200).makeRect(FlxG.width * 1.3, FlxG.height * 1.3, 0xFFB3DFd8);
		bgFade.alpha = 0;
		bgFade.blend = OVERLAY;
		add(bgFade);

		new FlxTimer().start(0.4, (tmr) -> {
			bgFade.alpha = FlxMath.bound(bgFade.alpha + (1 / 5) * 0.7, 0, 0.7);
		}, 5);

		portraitGroup = new FlxSpriteGroup();
		add(portraitGroup);

		portraitLeft = new PixelPortrait('senpai-pixel');
		portraitRight = new PixelPortrait('bf-pixel', true);
		portraitGroup.add(portraitLeft);
		portraitGroup.add(portraitRight);

		boxType = boxTypes.exists(skin) ? skin : 'pixel';
		var data:PixelBox = boxTypes.get(boxType);

		box = new FlxSpriteExt().loadImage('skins/${data.box}', false, null, null, HIGH);
		box.antialiasing = false;
		box.scrollFactor.set();
		box.addAnim('normalOpen', data.openAnim);
		box.playAnim('normalOpen');
		box.setScale(PIXEL_ZOOM * 0.9);
		box.screenCenter();
		box.y += 69; // nice
		add(box);

		handSelect = new FlxSpriteExt(FlxG.width * 0.82, FlxG.height * 0.81).loadImage('skins/pixel/hand_textbox', false, null, null, HIGH);
		handSelect.antialiasing = false;
		handSelect.scrollFactor.set();
		handSelect.addAnim('enter', 'nextLine', 12);
		handSelect.addAnim('load', 'waitLine', 12, true);
		handSelect.addAnim('click', 'clickLine', 12);
		handSelect.setScale(PIXEL_ZOOM * 0.9);
		handSelect.playAnim('load');
		add(handSelect);
		handSelect.alpha = 0;

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.borderStyle = SHADOW;
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.borderColor = 0xFFD89494;
		swagDialogue.shadowOffset.set(4, 4);
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

        skipCallback = () -> swagDialogue.skip();
        endCallback = clickDialogue;
        nextCallback = clickDialogue;

		clickSound = CoolUtil.getSound("clickText");
		clickSound.volume = 0.8;
	}

    override public function update(elapsed:Float):Void
	{
		textFinished = swagDialogue.text.length == targetDialogue.length;

		final handAnim = handSelect.animation.curAnim;
		if (handAnim != null)
		{
			if (!textFinished && handAnim.finished) handSelect.playAnim("load");
			else if (textFinished && handAnim.name == "load") handSelect.playAnim("enter");
		}

		final boxAnim = box.animation.curAnim;
		if (boxAnim != null)
		{
			if (boxAnim.finished) if (boxAnim.name == "normalOpen") {
				box.playAnim("normal");
				dialogueOpened = true;
			}
		}

		super.update(elapsed);
    }

    override public function endDialogue():Void {
        super.endDialogue();
        if (isEnding) {
            new FlxTimer().start(0.2, (tmr) -> {
				box.alpha -= 0.2;
				bgFade.alpha -= 0.14;

				portraitLeft.alpha -= 0.2;
				portraitRight.alpha -= 0.2;
				portraitLeft.x -= 5;
				portraitRight.x += 5;

				swagDialogue.alpha = box.alpha;
				handSelect.alpha = box.alpha;
			}, 5);
        }    
    }

    function clickDialogue():Void {
		clickSound.play(true);
		handSelect.playAnim('click', true);
    }

    override public function startDialogue():Void  {
        super.startDialogue();
        swagDialogue.resetText(targetDialogue);
		swagDialogue.start(0.04, true);
		handSelect.alpha = 1;

		final targetPortrait = curCharData == 0 ? portraitLeft : portraitRight;
		(curCharData == 0 ? portraitRight : portraitLeft).visible = false; // Other portrait
		if (!targetPortrait.visible) {
			targetPortrait.visible = true;
			targetPortrait.animation.play('enter');
		}
    }
}

class PixelPortrait extends FlxSpriteExt
{
	public function new (char:String, isPlayer:Bool = false) {
		super(isPlayer ? 0 : -20, 40);

		loadImage('portraits/$char', false, null, null, HIGH);
		addAnim("enter", "Portrait Enter");

		antialiasing = false;
		setScale(PixelDialogueBox.PIXEL_ZOOM * .9);
		scrollFactor.set();
		visible = false;
	}
}