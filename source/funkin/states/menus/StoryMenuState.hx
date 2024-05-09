package funkin.states.menus;

import funkin.states.menus.items.MenuCharacter;
import funkin.states.menus.items.MenuItem;

class StoryMenuState extends MusicBeatState {
	var scoreText:FlxFunkText;
	var txtWeekTitle:FlxFunkText;
	var txtTracklist:FlxFunkText;

	var curWeek:Int = 0;
	var curDifficulty:Int = 1;
	var curWeekDiffs:Array<String> = [
		'easy',
		'normal',
		'hard'
	];

	var grpWeekText:TypedGroup<MenuItem>;
	var grpWeekCharacters:TypedGroup<MenuCharacter>;

	var difficultySelectors:FlxGroup;
	var storyBG:FlxSprite;
	var sprDiff:FunkinSprite;
	var diffText:FlxFunkText;
	var leftArrow:FunkinSprite;
	var rightArrow:FunkinSprite;

	var storyWeeks:Array<WeekData> = [];
	inline function getCurData() 	return storyWeeks[curWeek].data;
	inline function getWeekChars() 	return getCurData().storyCharacters;

	override function create():Void
	{
		if (FlxG.sound.music == null)
			CoolUtil.playMusic('freakyMenu');

		scoreText = new FlxFunkText(10, 10, "SCORE: 49324858", FlxPoint.weak(FlxG.width, 36), 36);
		
		txtWeekTitle = new FlxFunkText(0, 10, "Swag The Swagger", FlxPoint.weak(FlxG.width, 36), 36);
		txtWeekTitle.alignment = "right";
		txtWeekTitle.color = 0xffB2B2B2;

		grpWeekText = new TypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new TypedGroup<MenuCharacter>();
		
		// Updating Discord Rich Presence
		#if discord_rpc DiscordClient.changePresence("In the Menus", null); #end
		#if mobile MobileTouch.setLayout(STORY_MODE); #end

		WeekSetup.getWeekList().fastForEach((week, i) -> {
			if (!week.data.hideStory) {
				storyWeeks.push(week);

				ModdingUtil.runFunctionMod(week.modFolder, () -> {
					var item = new MenuItem(i, week.data.weekImage, !Highscore.getWeekUnlock(week.name));
					grpWeekText.add(item);
				});
			}
		});

		MenuCharacter.cachedChars.clear();
		for (i in 0...3) {
			var weekChar:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + i) - 150, 70, getWeekChars()[i]);
			grpWeekCharacters.add(weekChar);
		}
		grpWeekCharacters.members[1].screenCenter(X);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		sprDiff = new FunkinSprite('storymenu/difficulties/normal', [0, FlxG.height*0.685]);
		sprDiff.screenCenter(X);
		sprDiff.x += FlxG.width*0.335;
		difficultySelectors.add(sprDiff);

		diffText = new FlxFunkText(0,sprDiff.y,"homo",FlxPoint.weak(FlxG.width, 80), 75);
		diffText.font = "phantommuff";
		diffText.alignment = "center";
		diffText.visible = false;
		difficultySelectors.add(diffText);

		leftArrow = new FunkinSprite('storymenu/menuArrows', [sprDiff.x, sprDiff.y]);
		leftArrow.addAnim('idle', 'arrow left');
		leftArrow.addAnim('press', 'arrow push left');
		leftArrow.addOffset('press', 0, -4);
		leftArrow.playAnim('idle');
		leftArrow.y -= leftArrow.height/8;
		leftArrow.x -= leftArrow.width*1.1;
		difficultySelectors.add(leftArrow);

		rightArrow = new FunkinSprite('storymenu/menuArrows', [sprDiff.x + sprDiff.width, sprDiff.y]);
		rightArrow.addAnim('idle', 'arrow right');
		rightArrow.addAnim('press', 'arrow push right');
		rightArrow.addOffset('press', 0, -4);
		rightArrow.playAnim('idle');
		rightArrow.y -= rightArrow.height/8;
		rightArrow.x += leftArrow.width*0.1;
		difficultySelectors.add(rightArrow);

		storyBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFFFFFFF);//0xFFF9CF51
		storyBG.color = FlxColorFix.fromString(storyWeeks[0].data.weekColor);
		add(storyBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxFunkText(FlxG.width * 0.05, storyBG.x + storyBG.height + 100, "Tracks", FlxPoint.weak(FlxG.width, FlxG.height*0.5), 32);
		txtTracklist.alignment = "center";
		
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);

		add(scoreText);
		add(txtWeekTitle);

		cacheChars();
		changeWeek();

		lerpColor = FlxColorFix.fromFlxColor(getBgColor());
		super.create();

		if (unlockWeek != null)
			unlockWeekAnim();
	}
	
	public static var unlockWeek:WeekData = null;

	function unlockWeekAnim() {
		var moveIndex = -1;
		storyWeeks.fastForEach((week, i) -> {
			if (week.name == unlockWeek.name) if (week.modFolder == unlockWeek.modFolder)
				moveIndex = i;
		});

		unlockWeek = null;
		if (moveIndex == -1) // Couldnt find unlock week
			return;

		movedBack = true;
		var item = grpWeekText.members.unsafeGet(moveIndex);
		item.locked = true;
		item.lockSpr.visible = true;

		// Move to the week
		for (i in 0...moveIndex) {
			new FlxTimer().start((i + 1) * (0.3 / moveIndex), (tmr) -> changeWeek(1));
		}
		
		// Play unlock sound n start animation
		FlxTween.tween(FlxG.sound.music, {volume: 0.1}, 0.5, {onComplete: (twn) -> {
			CoolUtil.playSound("unlockWeek");
			
			FlxTween.tween(item, {lockShake: 10}, 1.37, {onComplete: (twn) -> {
				FlxG.camera.flash();
				item.locked = false;
				item.color = FlxColor.WHITE;

				FlxTween.tween(item.lockSpr, {alpha: 0}, 1.0);
				item.lockShake = 0;
				item.lockSpr.offset.set();

				item.lockSpr.acceleration.y = FlxG.random.float(200, 300);
				item.lockSpr.velocity.y = FlxG.random.float(-20, -40);
				item.lockSpr.velocity.x = FlxG.random.float(-20, -10);

				new FlxTimer().start(0.3, (tmr) -> {
					movedBack = false;
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.5);
				});
			}});
		}});
	}

	var cachedChars:Array<String> = [];

	function cacheChars() {
		final startMod = ModdingUtil.curModFolder;
		for (week in storyWeeks) {
			if (WeekSetup.vanillaWeekList.contains(week)) continue;
			ModdingUtil.curModFolder = week.modFolder;
			for (i in week.data.storyCharacters) {
				if (cachedChars.contains(i)) continue; // Avoid duplicates
				cachedChars.push(i);
				var char = new MenuCharacter(0,0,i);
				char = null;
			}
		}
		ModdingUtil.curModFolder = startMod;
	}

	var lerpColor:FlxColorFix;
	var targetColor:FlxColor;

	inline function getBgColor():FlxColor {
		return getPref("vanilla-ui") ? 0xfff9cf51 : FlxColorFix.fromString(getCurData().weekColor);
	}

	override function update(elapsed:Float):Void {
		lerpScore = Math.floor(CoolUtil.coolLerp(lerpScore, intendedScore, 0.5));
		scoreText.text = 'WEEK SCORE:$lerpScore';

		txtWeekTitle.text = getCurData().weekName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		if (!movedBack) {
			if (!selectedWeek) {
				if (getKey('UI_UP', JUST_PRESSED))		changeWeek(-1);
				if (getKey('UI_DOWN', JUST_PRESSED))	changeWeek(1);

				rightArrow.playAnim(getKey('UI_RIGHT', PRESSED) ? 'press' : 'idle');
				leftArrow.playAnim(getKey('UI_LEFT', PRESSED) ? 'press' : 'idle');

				if (difficultySelectors.visible) {
					if (getKey('UI_RIGHT', JUST_PRESSED))	changeDifficulty(1);
					if (getKey('UI_LEFT', JUST_PRESSED))	changeDifficulty(-1);
				}
			}

			if (getKey('ACCEPT', JUST_PRESSED)) {
				selectWeek();
			}
		}

		difficultySelectors.visible = Highscore.getWeekUnlock(storyWeeks[curWeek].name);
		leftArrow.visible = rightArrow.visible = curWeekDiffs.length > 1;

		if (!movedBack) if (!selectedWeek) if (getKey('BACK', JUST_PRESSED)) {
			movedBack = true;
			CoolUtil.playSound('cancelMenu');
			switchState(new MainMenuState());
		}

		lerpColor.lerp(targetColor ?? FlxColor.WHITE, 0.045, true);
		storyBG.color = lerpColor.get();
		
		grpWeekCharacters.members.fastForEach((member, i) -> {
			if (member.lerpColor)
				member.color = storyBG.color;
		});

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopCancelSpam:Bool = false;

	function selectWeek():Void
	{
		var week = storyWeeks[curWeek].name;
		if (Highscore.getWeekUnlock(week))
		{
			selectedWeek = true;

			CoolUtil.playSound('confirmMenu');
			grpWeekText.members[curWeek].startFlashing();
			grpWeekCharacters.members[1].playAnim('confirm', true);
			#if mobile MobileTouch.setLayout(NONE); #end

			var playlist = getCurData().songList.songs;
			var diff = curWeekDiffs[curDifficulty];

			PlayState.storyPlaylist = playlist;
			var firstSong = playlist[0];
			
			WeekSetup.setupSong(week, firstSong, diff, true);

			new FlxTimer().start(1, function(tmr:FlxTimer) {
				WeekSetup.loadTarget(PlayState, false);
			});
		}
		else {
			if (!stopCancelSpam) {
				stopCancelSpam = true;
				CoolUtil.playSound('rejectMenu');
				grpWeekText.members[curWeek].startFlashing();
				new FlxTimer().start(0.3, function(tmr:FlxTimer) {
					stopCancelSpam = false;
				});
			}
		}
	}

	function changeDifficulty(change:Int = 0):Void {
		final lastDiff:String = curWeekDiffs[curDifficulty];
		curDifficulty = FlxMath.wrap(curDifficulty += change, 0, curWeekDiffs.length - 1);
		intendedScore = Highscore.getWeekScore(storyWeeks[curWeek].name, curWeekDiffs[curDifficulty]);

		var _spr:FlxSprite;
		final diffPath = 'storymenu/difficulties/' + curWeekDiffs[curDifficulty].toLowerCase();
		final tryPath = Paths.png(diffPath, null, true);
		
		if (Paths.exists(tryPath, IMAGE)) {
			sprDiff.loadImage(diffPath, true);
			diffText.visible = false;
			sprDiff.visible = true;
			sprDiff.screenCenter(X);
			sprDiff.x += FlxG.width*0.335;
			_spr = sprDiff;
		}
		else {
			diffText.text = curWeekDiffs[curDifficulty];
			diffText.visible = true;
			diffText.color = 0xc508ff;
			sprDiff.visible = false;
			diffText.offset.y = 10;
			diffText.x = FlxG.width*0.335;
			_spr = diffText;
		}
		
		if (curWeekDiffs[curDifficulty] != lastDiff) {
			_spr.alpha = 0;
			_spr.y = FlxG.height*0.685 - 15;
			FlxTween.tween(_spr, {y: _spr.y + 15, alpha: 1}, 0.07);
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void {
		var lastWeekDiffs = getCurData().weekDiffs;
		curWeek = FlxMath.wrap(curWeek += change, 0, storyWeeks.length - 1);
		if (change != 0) CoolUtil.playSound('scrollMenu');
		curWeekDiffs = getCurData().weekDiffs;

		if (lastWeekDiffs != curWeekDiffs) {	//	FIND MATCHES
			if (curWeekDiffs.contains(lastWeekDiffs[curDifficulty])) {
				curDifficulty = curWeekDiffs.indexOf(lastWeekDiffs[curDifficulty]);
			}
		}

		grpWeekText.members.fastForEach((item, i) -> {
			item.targetY = i - curWeek;
		});

		changeDifficulty();
		updateText();
		targetColor = getBgColor();
	}

	function updateText():Void {
		ModdingUtil.runFunctionMod(storyWeeks[curWeek].modFolder, function () {
			var weekChars = getWeekChars();
			grpWeekCharacters.members.fastForEach((member, i) -> {
				member.setupChar(weekChars[i]);
			});
		});

		txtTracklist.text = 'Tracks\n';
		for (song in getCurData().songList.songs) txtTracklist.text += '\n' + song;
		txtTracklist.text = txtTracklist.text.toUpperCase();
		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;
	}
}