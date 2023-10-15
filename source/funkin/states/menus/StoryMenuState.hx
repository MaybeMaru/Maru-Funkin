package funkin.states.menus;

import funkin.states.menus.MenuCharacter;
import funkin.states.menus.MenuItem;

class StoryMenuState extends MusicBeatState {
	var scoreText:FlxText;
	var txtWeekTitle:FlxText;
	var txtTracklist:FunkinText;

	var curWeek:Int = 0;
	var curDifficulty:Int = 1;
	var curWeekDiffs:Array<String> = [
		'easy',
		'normal',
		'hard'
	];

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var difficultySelectors:FlxGroup;
	var storyBG:FlxSprite;
	var sprDiff:FunkinSprite;
	var diffText:FlxText;
	var leftArrow:FunkinSprite;
	var rightArrow:FunkinSprite;

	var storyWeeks:Array<WeekData> = [];
	inline function getCurData() 	return storyWeeks[curWeek].data;
	inline function getWeekChars() 	return getCurData().storyCharacters;

	override function create():Void {
		if (FlxG.sound.music == null) {
			CoolUtil.playMusic('freakyMenu');
		}

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
		
		#if cpp // Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var weekID:Int = 0;
		for (i in WeekSetup.getWeekList()) {
			if (!i.data.hideStory) {
				var weekThing:MenuItem = new MenuItem(weekID, i.data.weekImage);
				weekThing.locked = !Highscore.getWeekUnlock(i.name);
				grpWeekText.add(weekThing);
				weekID++;
				storyWeeks.push(i);
			}
		}

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

		diffText = new FlxText(0,sprDiff.y,0,"test").setFormat(Paths.font("phantommuff"), 80);
		diffText.screenCenter(X);
		diffText.x += FlxG.width*0.335;
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
		storyBG.color = CoolUtil.hexToColor(storyWeeks[0].data.weekColor);
		add(storyBG);
		add(grpWeekCharacters);

		txtTracklist = new FunkinText(FlxG.width * 0.05, storyBG.x + storyBG.height + 100, 'Tracks', 32, 0, 'center');
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);

		add(scoreText);
		add(txtWeekTitle);

		cacheChars();
		changeWeek();

		lerpColor = FlxColorFix.fromFlxColor(getBgColor());
		super.create();
	}

	function cacheChars() {
		final startMod = ModdingUtil.curModFolder;
		for (week in storyWeeks) {
			if (WeekSetup.vanillaWeekList.contains(week)) continue;
			ModdingUtil.curModFolder = week.modFolder;
			for (i in week.data.storyCharacters) {
				var char = new MenuCharacter(0,0,i);
				char.destroy();
			}
		}
		ModdingUtil.curModFolder = startMod;
	}

	var lerpColor:FlxColorFix;

	inline function getBgColor():FlxColor {
		return FlxColor.fromString(getCurData().weekColor);
	}

	override function update(elapsed:Float):Void {
		lerpScore = Math.floor(CoolUtil.coolLerp(lerpScore, intendedScore, 0.5));
		scoreText.text = 'WEEK SCORE:$lerpScore';

		txtWeekTitle.text = getCurData().weekName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		if (!movedBack) {
			if (!selectedWeek) {
				if (getKey('UI_UP-P'))		changeWeek(-1);
				if (getKey('UI_DOWN-P'))	changeWeek(1);

				rightArrow.playAnim(getKey('UI_RIGHT') ? 'press' : 'idle');
				leftArrow.playAnim(getKey('UI_LEFT') ? 'press' : 'idle');

				if (getKey('UI_RIGHT-P'))	changeDifficulty(1);
				if (getKey('UI_LEFT-P'))	changeDifficulty(-1);
			}

			if (getKey('ACCEPT-P')) {
				selectWeek();
			}
		}

		difficultySelectors.visible = Highscore.getWeekUnlock(storyWeeks[curWeek].name);
		leftArrow.visible = rightArrow.visible = curWeekDiffs.length > 1;

		if ((getKey('BACK-P')) && !movedBack && !selectedWeek) {
			movedBack = true;
			CoolUtil.playSound('cancelMenu');
			switchState(new MainMenuState());
		}

		lerpColor.lerp(getBgColor(), 0.045, true);
		storyBG.color = lerpColor.get();
		
		for (member in grpWeekCharacters) {
			if (member.lerpColor)
				member.color = storyBG.color;
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopCancelSpam:Bool = false;

	function selectWeek():Void {
		final _weekName = storyWeeks[curWeek].name;
		if (Highscore.getWeekUnlock(_weekName)) {
			PlayState.storyPlaylist = getCurData().songList.songs;
			WeekSetup.setupSong(_weekName, PlayState.storyPlaylist[0], curWeekDiffs[curDifficulty]);

			if (!selectedWeek) {
				CoolUtil.playSound('confirmMenu');
				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].playAnim('confirm', true);
			}

			PlayState.isStoryMode = true;
			selectedWeek = true;
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				LoadingState.loadAndSwitchState(new PlayState(), true);
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
		var lastDiff:String = curWeekDiffs[curDifficulty];
		curDifficulty = FlxMath.wrap(curDifficulty += change, 0, curWeekDiffs.length - 1);
		intendedScore = Highscore.getWeekScore(storyWeeks[curWeek].name, curWeekDiffs[curDifficulty]);

		var _spr:FlxSprite;
		var diffPath = 'storymenu/difficulties/${curWeekDiffs[curDifficulty]}';
		if (Paths.exists(Paths.image(diffPath, null, true, true), IMAGE)) {
			sprDiff.loadImage(diffPath, true);
			diffText.visible = false;
			sprDiff.visible = true;
			_spr = sprDiff;
		} else {
			diffText.text = curWeekDiffs[curDifficulty];
			diffText.visible = true;
			diffText.color = 0xc508ff;
			sprDiff.visible = false;
			diffText.offset.y = 10;
			_spr = diffText;
		}

		_spr.screenCenter(X);
		_spr.x += FlxG.width*0.335;
		
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

		for (i in 0...grpWeekText.members.length) {
			var item = grpWeekText.members[i];
			item.targetY = i - curWeek;
		}

		changeDifficulty();
		updateText();
	}

	function updateText():Void {
		final lastMod = ModdingUtil.curModFolder; // Im lazy ok, deal with it
		ModdingUtil.curModFolder = storyWeeks[curWeek].modFolder;
		for (i in 0...grpWeekCharacters.members.length) {
			grpWeekCharacters.members[i].setupChar(getWeekChars()[i]);
		}
		ModdingUtil.curModFolder = lastMod;

		txtTracklist.text = 'Tracks\n';
		for (song in getCurData().songList.songs) txtTracklist.text += '\n$song';
		txtTracklist.text = txtTracklist.text.toUpperCase();
		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;
	}
}