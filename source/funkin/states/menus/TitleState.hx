package funkin.states.menus;

typedef IntroPart = {
	var create:Array<String>;
	var add:String;
	var sprite:String;
	var makeRandom:Null<Int>;
	var addRandom:Null<Int>;
	var clear:Bool;
	var skip:Bool;
}

typedef IntroJson = {
	var beats:Array<IntroPart>;
	var bpm:Float;
}

class TitleState extends MusicBeatState {
	static var initialized:Bool = false;
	static var openedGame:Bool = false;
	var skippedIntro:Bool = false;

	var blackScreen:FlxSprite;
	var titleGroup:FlxGroup;
	var textSprite:Alphabet;
	var spriteGroup:FlxGroup;

	var curWacky:Array<String> = [];
	var introJson:IntroJson = null;

	override public function create():Void {
		FlxG.mouse.visible = false;

		curWacky = FlxG.random.getObject(getIntroTextShit());
		introJson = Json.parse(CoolUtil.getFileContent(Paths.json('introJson')));
		Conductor.bpm = introJson.bpm;
		persistentUpdate = true;

		titleGroup = new FlxGroup();
		add(titleGroup);
		titleGroup.add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		logoBump = new FunkinSprite('title/logoBumpin', [-115,-100]);
		logoBump.addAnim('idle', 'logo bumpin');
		logoBump.dance();
		FlxTween.tween(logoBump, {y: logoBump.y + 50}, 1.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		titleGroup.add(logoBump);

		gfDance = new FunkinSprite('title/gfDanceTitle', [FlxG.width*0.42,FlxG.height*0.0675]);
		gfDance.addAnim('danceLeft', 'gfDance', 24, false, [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]);
		gfDance.addAnim('danceRight', 'gfDance', 24, false, [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29]);
		titleGroup.add(gfDance);

		Shader.initShader('colorSwap');
		Shader.setSpriteShader(logoBump, 'colorSwap');
		Shader.setSpriteShader(gfDance, 'colorSwap');

		titleText = new FunkinSprite('title/titleEnter', [100,FlxG.height*0.8]);
		titleText.addAnim('idle', 'Press Enter to Begin');
		titleText.addAnim('press', 'ENTER PRESSED', 24, true);
		titleText.playAnim('idle');
		titleText.color = 0xFF3333CC;
		titleText.screenCenter(X);
		titleGroup.add(titleText);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);
		blackScreen.visible = !initialized;

		textSprite = new Alphabet(FlxG.width/2,FlxG.height/4,'');
		textSprite.alignment = CENTER;
		add(textSprite);
		spriteGroup = new FlxGroup();
		add(spriteGroup);

		initialized = true;
		super.create();
	}

	var danceLeft:Bool = false;
	var gfDance:FunkinSprite;
	var titleText:FunkinSprite;
	var logoBump:FunkinSprite;

	function makeIntroShit(index:Int):Void {
		var nuggets:IntroPart = introJson.beats[cast Math.max(index, 0)];
		if (nuggets == null) return;
		if (nuggets.sprite != null) {
			var introSpr:FunkinSprite = new FunkinSprite(nuggets.sprite, [0, textSprite.y + 20 + textSprite.height*0.5]);
			introSpr.setGraphicSize(introSpr.width*0.7);
			introSpr.screenCenter(X);
			spriteGroup.add(introSpr);
		}
		if (nuggets.create != null)			makeText(nuggets.create);
		if (nuggets.add != null)			addText(nuggets.add);
		if (nuggets.makeRandom != null)		makeText([curWacky[nuggets.makeRandom]]);
		if (nuggets.addRandom != null)		addText(curWacky[nuggets.addRandom]);
		if (nuggets.clear)					clearText();
		if (nuggets.skip)					skipIntro();
	}

	function makeText(text:Array<String>):Void {
		var newText:String = '';
		for (i in 0...text.length) {
			newText += '${text[i]}${(i == text.length-1 ? '' : '\n')}';
		}
		textSprite.text = newText.trim();
	}

	function addText(text:String):Void {
		var newText:String = '${textSprite.text}\n$text'.trim();
		textSprite.text = newText;
	}

	function clearText():Void {
		textSprite.text = '';
		for (spr in spriteGroup) {
			spr.kill();
		}
	}

	function getIntroTextShit():Array<Array<String>> {
		var convIntroLines:Array<Array<String>> = [];
		var introLines:Array<String> = CoolUtil.coolTextFile(Paths.txt('introText'));
		for (line in introLines) {
			convIntroLines.push(line.trim().split('--'));
		}
		return convIntroLines;
	}

	var transitioning:Bool = false;
	var titleSine:Float = 0;
	var timeElp:Float = 0;

	override function update(elapsed:Float):Void {
		if (FlxG.sound.music != null) {
			Conductor.songPosition = FlxG.sound.music.time;
			if (FlxG.sound.music.volume < 0.6) FlxG.sound.music.volume += elapsed * 0.1;
		}

		if (FlxG.keys.justPressed.F) FlxG.fullscreen = !FlxG.fullscreen;

		if (initialized && !transitioning && titleText != null) {
			titleSine += elapsed * 3;
			titleSine %= Math.PI * 2;

			var lerpValue = Math.sin(titleSine);
			titleText.alpha = (lerpValue + 1) * 0.25 + 0.75;
			titleText.color = FlxColor.interpolate(0xFF3333CC, 0xFF33FFFF, (lerpValue + 1) * 0.5);
			checkCode();
		}

		if (getKey('ACCEPT-P')) {
			if (!transitioning && (skippedIntro || openedGame) ) {
			transitioning = true;
			titleText.playAnim('press');
			titleText.color = FlxColor.WHITE;
			titleText.alpha = 1;
			openedGame = true;

			CoolUtil.playSound('confirmMenu', 0.7);
			FlxG.camera.flash(getPref('flashing-light') ? FlxColor.WHITE : FlxColor.fromRGB(255,255,255,125), 3);

			new FlxTimer().start(2, function(tmr:FlxTimer) {
				switchState(new MainMenuState());
			});
			}
			else if (!skippedIntro) {
				skipIntro();
			}
		}

		if (getKey('UI_LEFT')) timeElp -= elapsed;
		if (getKey('UI_RIGHT'))timeElp += elapsed;
		Shader.setFloat('colorSwap', 'iTime', timeElp);

		super.update(elapsed);
	}

	override function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);

		if (initialized && gfDance.exists) {
			logoBump.playAnim('idle', true);
			gfDance.dance();
		}

		if (curBeat <= introJson.beats.length && !skippedIntro && !openedGame) {
			makeIntroShit(curBeat-1);
		}
	}

	function skipIntro():Void {
		if (!skippedIntro && initialized) {
			skippedIntro = true;
			clearText();
			blackScreen.visible = false;
			FlxG.camera.flash(getPref('flashing-light') ? FlxColor.WHITE : FlxColor.fromRGB(255,255,255,125), 3);
		}
	}

	var codeIndex:Int = 0;
	var curCode:String = 'konami';

	var codes:Map<String, Array<FlxKey>> = [
		'konami' => [ // debug code
			FlxKey.UP, FlxKey.UP, FlxKey.DOWN, FlxKey.DOWN,
			FlxKey.LEFT, FlxKey.RIGHT, FlxKey.LEFT, FlxKey.RIGHT,
			FlxKey.B, FlxKey.A
		],
		'unlock' => [ // unlock code
			FlxKey.U,FlxKey.N,FlxKey.L,FlxKey.O,FlxKey.C,FlxKey.K, FlxKey.M,FlxKey.E,
		],
		'lock' => [ // lock code
			FlxKey.L,FlxKey.O,FlxKey.C,FlxKey.K, FlxKey.M,FlxKey.E,
		],
		'keoiki' => [ // keoiki code
			FlxKey.K,FlxKey.E,FlxKey.O,FlxKey.I, FlxKey.K,FlxKey.I,
		]
	];

	private function checkCode():Void {
		if (FlxG.keys.anyJustPressed([codes.get(curCode)[codeIndex]])) {
			codeIndex++;
			if (codeIndex >= codes.get(curCode).length) {
				codeIndex = 0;
				CoolUtil.playSound('confirmMenu', 0.7);
				switch(curCode) {
					case 'konami':
						CoolUtil.debugMode = true;
					case 'unlock':
						WeekSetup.getWeekList();
						for (i in WeekSetup.vanillaWeekList) {
							Highscore.setWeekUnlock(i.name, true);
						}
					case 'lock':
						WeekSetup.getWeekList();
						for (i in WeekSetup.vanillaWeekList) {
							if (!i.data.startUnlocked) {
								Highscore.setWeekUnlock(i.name, false);
							}
						}
					case 'keoiki':
						CustomTransition.set(null, 0.6, 0.4, Paths.image('keoiki'));
				}
			}
		} else if (FlxG.keys.justPressed.ANY) {
			for (i in codes.keys()) {
				if (FlxG.keys.anyJustPressed([codes.get(i)[0]])) {
					codeIndex = 1;
					curCode = i;
					return;
				}
			}
			codeIndex = 0;
		}
    }
}