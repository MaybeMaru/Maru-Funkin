package funkin.states.menus;

class FreeplayState extends MusicBeatState {
	var bg:FunkinSprite;

	var songs:Array<SongMetadata> = [];
	var coolColors:Map<String, String>;
	var curWeekDiffs:Array<String> = [
		'easy',
		'normal',
		'hard'
	];

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FunkinText;
	var diffText:FunkinText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var grpSongs:FlxTypedGroup<MenuAlphabet>;
	var iconArray:Array<HealthIcon> = [];

	override function create():Void {
		if (FlxG.sound.music == null) {
			CoolUtil.playMusic('freakyMenu');
		}

		#if cpp		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		coolColors = new Map<String, String>();
		for (i in 0...WeekSetup.getWeekList().length) {
			var week:WeekJson = WeekSetup.weekList[i];
			var weekName:String = WeekSetup.weekNameList[i];
			if (Highscore.getWeekUnlock(weekName)) {
				addWeek(week.songList.songs, week.songList.songIcon, weekName);
				coolColors.set(weekName, week.weekColor);
			}
		}

		bg = new FunkinSprite('menuDesat');
		add(bg);

		grpSongs = new FlxTypedGroup<MenuAlphabet>();
		add(grpSongs);

		for (i in 0...songs.length) {
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			var leScale:Float = 1;
			while (icon.width*1.1+Alphabet.spaceWidth*songs[i].songName.length*leScale > FlxG.width) {
				leScale-=0.01;
			}

			var songText:MenuAlphabet = new MenuAlphabet(0, (70 * i) + 30, songs[i].songName, true, 0, leScale);
			songText.targetY = i;
			songText.setTargetPos();
			grpSongs.add(songText);
			for (char in songText.letterArray)
				char.scale.y = 1;

			// using a FlxGroup is too much fuss!
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		}

		scoreBG = new FlxSprite(FlxG.width * 0.69/*nice*/, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		scoreText = new FunkinText(scoreBG.x + 6, 5, "", 32);
		scoreText.borderColor = FlxColor.TRANSPARENT;
		add(scoreText);

		diffText = new FunkinText(scoreText.x, scoreText.y + 36, "", 24);
		diffText.borderColor = FlxColor.TRANSPARENT;
		add(diffText);

		changeSelection();
		bg.color = CoolUtil.hexToColor(coolColors.get(songs[curSelected].weekName));
		for (song in grpSongs) {
			song.setTargetPos();
		}
		for (icon in iconArray) {
			icon.setSprTrackerPos();
		}

		super.create();
	}

	public function addSong(songName:String, songCharacter:String, weekName:String):Void {
		songs.push(new SongMetadata(songName, songCharacter, weekName));
	}

	public function addWeek(songs:Array<String>, ?songCharacters:Array<String>, week:String):Void {
		if (songCharacters == null) {
			songCharacters = ['bf'];
		}

		for (i in 0...songs.length) {
			var songIcon:String = (i > songCharacters.length-1) ? songCharacters[songCharacters.length-1] : songCharacters[i];
			addSong(songs[i], songIcon, week);
		}
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.sound.music.volume < 0.7) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(CoolUtil.coolLerp(lerpScore, intendedScore, 0.4));
		bg.color = FlxColor.interpolate(bg.color,  CoolUtil.hexToColor(coolColors.get(songs[curSelected].weekName)), CoolUtil.getLerp(0.045));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = 'PERSONAL BEST: $lerpScore';

		var sexPos:Float =  FlxG.width * 0.69;
		while (sexPos + scoreText.width > FlxG.width) {
			sexPos -= 0.1;
		}

		sexPos-=6;
		scoreText.x = sexPos;
		diffText.x = sexPos;
		scoreBG.x = sexPos - 6;

		if (getKey('UI_LEFT-P'))	changeDiff(-1);
		if (getKey('UI_RIGHT-P'))	changeDiff(1);
		detectChangeSelection();

		if (getKey('BACK-P')) {
			FlxG.switchState(new MainMenuState());
		}

		#if PRELOAD_ALL
		if(FlxG.keys.justPressed.ONE) {
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		}
		#end

		if(FlxG.keys.justPressed.SEVEN) {
			setupSong();
			FlxG.switchState(new ChartingState());
		}

		if (getKey('ACCEPT-P')) {
			setupSong();
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	var startTmr:Float = 0;
	var tmr:Float = 0;
	function detectChangeSelection():Void { //Unecessary but cool
		if (getKey('UI_UP-P') || getKey('UI_DOWN-P')) {
			startTmr = tmr = 0;
			changeSelection(getKey('UI_UP-P') ? -1 : 1);
		}

		if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		if (getKey('UI_UP') || getKey('UI_DOWN')) {
			startTmr +=  FlxG.elapsed;
			if (startTmr >= 0.333) {
				tmr += FlxG.elapsed;
				if (tmr >= 0.1333) {
					tmr = 0;
					changeSelection(getKey('UI_UP') ? -1 : 1);
				}
			}
		} else {
			startTmr = 0;
			tmr = 0;
		}
	}

	function setupSong():Void {
		PlayState.isStoryMode = false;
		WeekSetup.setupSong(songs[curSelected].weekName, songs[curSelected].songName, curWeekDiffs[curDifficulty]);
	}

	function changeDiff(change:Int = 0):Void {
		curDifficulty = FlxMath.wrap(curDifficulty += change, 0, curWeekDiffs.length - 1);
		intendedScore = Highscore.getSongScore(songs[curSelected].songName, curWeekDiffs[curDifficulty]);
		diffText.text = curWeekDiffs[curDifficulty].toUpperCase();
	}

	function changeSelection(change:Int = 0):Void {
		var lastWeekDiffs = WeekSetup.weekDataMap.get(songs[curSelected].weekName).weekDiffs;
		curSelected = FlxMath.wrap(curSelected += change, 0, songs.length - 1);
		if (change != 0) CoolUtil.playSound('scrollMenu', 0.4);

		curWeekDiffs = WeekSetup.weekDataMap.get(songs[curSelected].weekName).weekDiffs;
		if (lastWeekDiffs != curWeekDiffs) {	//	FIND MATCHES
			if (curWeekDiffs.contains(lastWeekDiffs[curDifficulty])) {
				curDifficulty = curWeekDiffs.indexOf(lastWeekDiffs[curDifficulty]);
			}
		}
		changeDiff();

		for (i in 0...grpSongs.members.length) {
			var item = grpSongs.members[i];
			item.targetY = i - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		}

		for (i in 0...iconArray.length) {
			iconArray[i].alpha = 0.6;
		}
		iconArray[curSelected].alpha = 1;
	}
}

class SongMetadata {
	public var songName:String = "";
	public var weekName:String = "";
	public var songCharacter:String = "";

	public function new(song:String, songCharacter:String, weekName:String):Void {
		this.songName = song;
		this.songCharacter = songCharacter;
		this.weekName = weekName;
	}
}