package funkin.objects.dialogue;
import flixel.addons.text.FlxTypeText;

class PixelDialogueBox extends DialogueBoxBase {
	/*
	 *	Adding new dialogue box skins
	 *	Type => [imagePath, [openAnim, indices], [idleAnim, indices]]
	 */
	inline public static var PIXEL_ZOOM:Int = 6;
	public static var boxTypes:Map<String, Array<Dynamic>> = [
		'pixel'	=> 	['pixel/dialogueBox-pixel',		['Text Box Appear'],		 	['Text Box Appear', 		   [4]]],
		'mad'	=> 	['pixel/dialogueBox-senpaiMad',	['SENPAI ANGRY IMPACT SPEECH'], ['SENPAI ANGRY IMPACT SPEECH', [4]]],
		'evil'	=> 	['pixel/dialogueBox-evil', 		['Spirit Textbox spawn'], 		['Spirit Textbox spawn', 	   [11]]]
	];

	public var boxType:String = 'pixel';
	public var portraitGroup:FlxSpriteGroup;
	public var portraitLeft:PixelPortrait;
	public var portraitRight:PixelPortrait;

	public var box:FunkinSprite;
	public var swagDialogue:FlxTypeText;
	public var handSelect:FunkinSprite;
	public var bgFade:FlxSprite;

	public var clickSound:FlxSound = null;

	public function new(skin:String = 'pixel'):Void {
		super();

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.alpha = 0;
		bgFade.blend = OVERLAY;
		add(bgFade);

		new FlxTimer().start(0.4, function(tmr:FlxTimer) {
			bgFade.alpha = FlxMath.bound(bgFade.alpha + (1 / 5) * 0.7, 0, 0.7);
		}, 5);

		portraitGroup = new FlxSpriteGroup();
		add(portraitGroup);

		portraitLeft = new PixelPortrait('senpai-pixel');
		portraitRight = new PixelPortrait('bf-pixel', true);
		portraitGroup.add(portraitLeft);
		portraitGroup.add(portraitRight);

		boxType = boxTypes.exists(skin) ? skin : 'pixel';
		var boxData:Array<Dynamic> = boxTypes.get(boxType);

		box = new FunkinSprite('skins/${boxData[0]}', [0,0], [0,0]);
		box.addAnim('normalOpen', boxData[1][1], 24, false, boxData[1][2]);
		box.playAnim('normalOpen');
		box.setScale(PIXEL_ZOOM * 0.9);
		box.screenCenter();
		box.y += 69; // nice
		add(box);

		handSelect = new FunkinSprite('skins/pixel/hand_textbox', [FlxG.width * 0.82, FlxG.height * 0.81], [0,0]);
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

        skipCallback = skipDialogue;
        endCallback = clickDialogue;
        nextCallback = clickDialogue;
		startCallback = function nothing() {};

		clickSound = CoolUtil.getSound("clickText");
		clickSound.volume = 0.8;
	}

    override public function update(elapsed:Float):Void {

        textFinished = swagDialogue.text.length == targetDialogue.length;
		if (handSelect.animation.curAnim != null) {
			if (!textFinished && handSelect.animation.curAnim.finished) {
				handSelect.playAnim('load');
			} else if (textFinished && handSelect.animation.curAnim.name == 'load') {
				handSelect.playAnim('enter');
			}
		}

        if (box.animation.curAnim != null) {
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished) {
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		super.update(elapsed);
    }

    function skipDialogue():Void {
        swagDialogue.skip();
    }

    override public function endDialogue():Void {
        super.endDialogue();
        if (isEnding) {
            new FlxTimer().start(0.2, function(tmr:FlxTimer) {
				box.alpha -= 1 / 5;
				bgFade.alpha -= 1 / 5 * 0.7;

				portraitLeft.alpha -= 1 / 5;
				portraitRight.alpha -= 1 / 5;
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

class PixelPortrait extends FlxSprite {
	public function new(path:String, isPlayer:Bool = false):Void {
		super(isPlayer ? 0 : -20, 40);

		frames = Paths.getSparrowAtlas('portraits/$path');
		animation.addByPrefix('enter', 'Portrait Enter', 24, false);

		if (path.endsWith('-pixel')) {
			antialiasing = false;
			setGraphicSize(Std.int(width * PixelDialogueBox.PIXEL_ZOOM * 0.9));
			updateHitbox();
		}
		else {
			antialiasing = Preferences.getPref('antialiasing');
		}

		scrollFactor.set();
		visible = false;
	}
}