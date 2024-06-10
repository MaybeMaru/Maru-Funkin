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

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;
	static var openedGame:Bool = false;
	var skippedIntro:Bool = false;

	var blackScreen:FlxSprite;
	var titleGroup:Group;
	var text:Alphabet;
	var spriteGroup:SpriteGroup;

	var curWacky:Array<String> = [];
	var introJson:IntroJson = null;

	var flashy:Bool = true;

	override public function create():Void {
		Transition.setSkip(!initialized);
		
		FlxG.mouse.visible = false;
		flashy = getPref('flashing-light');

		curWacky = FlxG.random.getObject(getIntroTextShit());
		introJson = Json.parse(CoolUtil.getFileContent(Paths.json('introJson')));
		Conductor.bpm = introJson.bpm;
		
		persistentUpdate = true;

		titleGroup = new Group();
		add(titleGroup);
		titleGroup.add(new FlxSpriteExt().makeRect(FlxG.width, FlxG.height, FlxColor.BLACK));

		logoBump = new FunkinSprite('title/logoBumpin', [-115,-100]);
		logoBump.addAnim('idle', 'logo bumpin');
		logoBump.dance();
		FlxTween.tween(logoBump, {y: logoBump.y + 50}, 1.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		titleGroup.add(logoBump);

		gfDance = new FunkinSprite('title/gfDanceTitle', [FlxG.width*0.42,FlxG.height*0.0675]);
		gfDance.addAnim('danceLeft', 'gfDance', 24, false, [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]);
		gfDance.addAnim('danceRight', 'gfDance', 24, false, [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29]);
		titleGroup.add(gfDance);

		final colorSwap = Shader.initShader('colorSwap');
		if (colorSwap != null) {
			colorSwap.updateTime = false;
			Shader.setSpriteShader(logoBump, 'colorSwap');
			Shader.setSpriteShader(gfDance, 'colorSwap');
		}

		updateColor(0.0);
		updatePitch(0.0);

		titleText = new FunkinSprite(#if mobile 'mobile/' + #end 'title/titleEnter', [100,FlxG.height*0.8]);
		titleText.addAnim('idle', 'Press Enter to Begin');
		titleText.addAnim('press', 'ENTER PRESSED', 24, true);
		titleText.playAnim('idle');
		titleText.color = 0xFF3333CC;
		titleText.screenCenter(X);
		titleGroup.add(titleText);

		blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width,FlxG.height);
		blackScreen.updateHitbox();
		blackScreen.antialiasing = false;
		blackScreen.active = false;
		blackScreen.visible = !initialized;
		add(blackScreen);

		text = new Alphabet(0, FlxG.height * 0.25);
		text.alignment = CENTER;
		add(text);

		spriteGroup = new SpriteGroup();
		add(spriteGroup);

		initialized = true;
		super.create();
	}

	var danceLeft:Bool = false;
	var gfDance:FunkinSprite;
	var titleText:FunkinSprite;
	var logoBump:FunkinSprite;

	function checkBeat(index:Int):Void
	{
		index = Std.int(FlxMath.bound(index, 0, introJson.beats.length));
		var beat = introJson.beats[index];
		if (beat == null) return;

		if (beat.create != null) 		makeText(beat.create);
		if (beat.add != null) 			addText(beat.add);
		if (beat.makeRandom != null) 	makeText([curWacky[beat.makeRandom]]);
		if (beat.addRandom != null) 	addText(curWacky[beat.addRandom]);
		if (beat.clear)					clearText();
		if (beat.skip)					skipIntro();

		text.screenCenter(X);

		if (beat.sprite != null) {
			var sprite = new FlxSpriteExt(0, text.y + text.height + 10);
			sprite.loadImage(beat.sprite);
			sprite.setScale(0.7);
			sprite.screenCenter(X);
			spriteGroup.add(sprite);
		}
	}

	function makeText(text:Array<String>):Void {
		this.text.text = text.join('\n');
	}

	function addText(text:String):Void {
		this.text.text += '\n$text';
	}

	function clearText():Void {
		text.text = '';
		spriteGroup.members.fastForEach((basic, i) -> basic.kill());
	}

	function getIntroTextShit():Array<Array<String>> {
		var lines:Array<Array<String>> = [];

		CoolUtil.coolTextFile(Paths.txt('introText')).fastForEach((line, i) -> {
			lines.push(line.trim().split('--'));
		});

		return lines;
	}

	var transitioning:Bool = false;
	var titleSine:Float = 0;

	override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music != null) {
			musicBeat.targetSound = FlxG.sound.music;
			if (FlxG.sound.music.volume < 0.6)
				FlxG.sound.music.volume += elapsed * 0.1;
		}

		if (#if mobile MobileTouch.justPressed() #else getKey('ACCEPT', JUST_PRESSED) #end)
		{
			if (!transitioning && (skippedIntro || openedGame) )
			{
				transitioning = true;
				titleText.playAnim('press');
				titleText.color = FlxColor.WHITE;
				openedGame = true;

				FlxG.sound.music.pitch = 1.0;
				FlxG.timeScale = 1.0;

				CoolUtil.playSound('confirmMenu', 0.7);
				FlxG.camera.flash(flashy ? FlxColor.WHITE : 0x79ffffff, 3);

				new FlxTimer().start(2, (tmr:FlxTimer) -> switchState(new MainMenuState()));
			}
			else if (!skippedIntro)
			{
				skipIntro();
			}
		}

		if (gay) {
			updateColor(elapsed * (flashy ? 4 : 1));
		}

		// Color and pitch easter egg
		if (!transitioning) if (skippedIntro || openedGame)
		{
			if (!lockColor) {
				if (getKey('UI_LEFT', PRESSED)) updateColor(-elapsed);
				else if (getKey('UI_RIGHT', PRESSED)) updateColor(elapsed);
			}
	
			if (!lockPitch) {
				if (getKey('UI_UP', PRESSED)) updatePitch(-elapsed);
				else if (getKey('UI_DOWN', PRESSED)) updatePitch(elapsed);
			}

			if (titleText != null) {
				titleSine += elapsed * 3;
				var lerp:Float = FlxMath.remapToRange(FlxMath.fastSin(titleSine %= FunkMath.DOUBLE_PI), -1, 1, 0, 1);
				titleText.color = FlxColor.interpolate(0xFF3333CC, 0xFF33FFFF, lerp);
			}
			
			#if !mobile checkCode(); #end
		}

		super.update(elapsed);
	}

	var shaderColor:Float = 0;
	var lockColor:Bool = false;

	function updateColor(elapsed:Float) {
		shaderColor += elapsed / FlxG.timeScale;
		Shader.setFloat('colorSwap', 'iTime', shaderColor);
	}

	var musicPitch:Float = FunkMath.PI + 0.148; // Shhhh
	var lockPitch:Bool = false;

	function updatePitch(elapsed:Float) {
		musicPitch += elapsed / FlxG.timeScale;
		
		if (FlxG.sound.music != null) {
			var pitch = FlxMath.remapToRange(FunkMath.sin(musicPitch), -1, 1, 0.25, 2);
			FlxG.sound.music.pitch = pitch;
			FlxG.timeScale = pitch;
		}
	}

	override function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);

		if (initialized) if (gfDance.exists) {
			logoBump.playAnim('idle', true);
			gfDance.dance();
		}

		if (!openedGame) if (!skippedIntro) if (curBeat <= introJson.beats.length) {
			checkBeat(curBeat - 1);
		}
	}

	function skipIntro():Void {
		if (!skippedIntro && initialized) {
			skippedIntro = true;
			clearText();
			FlxG.camera.flash(flashy ? FlxColor.WHITE : 0x79ffffff, 3);
			spriteGroup.alpha = text.alpha = blackScreen.alpha = 0;
		}
	}

	var codeIndex:Int = 0;
	var curCode:String = 'konami';
	static var keoiki:Bool = false;
	var gay:Bool = false;

	override function destroy() {
		super.destroy();
		if (gay) {
			FlxG.sound.music.stop();
		}
	}

	var codes:Map<String, Array<FlxKey>> = [
		'konami' => [ // debug code
			UP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT, B, A
		],
		'unlock' => [ // unlock code
			U, N, L, O, C, K, M, E,
		],
		'lock' => [ // lock code
			L, O, C, K, M, E,
		],
		'keoiki' => [ // keoiki code
			K, E, O, I, K, I,
		],
		'gay' => [ // gay code
			M, R, G, A, Y
		]
	];

	private function checkCode():Void {
		var resetCode = () -> {
			curCode = "konami";
			codeIndex = 0;
		}
		
		if (FlxG.keys.anyJustPressed([codes.get(curCode)[codeIndex]])) {
			codeIndex++;
			if (codeIndex >= codes.get(curCode).length) {
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
						keoiki = !keoiki;
						Main.transition.set(null, 0.6, 0.4, keoiki ? Paths.image('keoiki') : null);
					case 'gay':
						if (!gay) {
							FlxG.camera.flash(flashy ? FlxColor.WHITE : 0x79ffffff, 3);
							CoolUtil.playMusic("gay", 0, true, true); // Stream this if possible :p
							FlxG.sound.music.fadeIn();
							codes.remove("gay");
							gay = true;
							lockColor = true;
						}
				}

				resetCode();
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