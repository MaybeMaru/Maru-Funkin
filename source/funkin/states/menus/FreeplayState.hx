package funkin.states.menus;

class FreeplayState extends MusicBeatState {
	var bg:FunkinSprite;

	var songs:Array<SongMetadata> = [];
	var coolColors:Map<String, FlxColor>;
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

		#if debug
		addSong('test','bf','test',-1);
		#end

		coolColors = new Map<String, FlxColor>();
		for (i in 0...WeekSetup.getWeekList().length) {
			var week:WeekJson = WeekSetup.weekList[i];
			var weekName:String = WeekSetup.weekNameList[i];
			if (Highscore.getWeekUnlock(weekName) && !week.hideFreeplay) {
				addWeek(week.songList.songs, week.songList.songIcons, weekName);

				var songColors = week.songList.songColors;
				for (i in 0...week.songList.songs.length) {
					var songColor = FlxColor.fromString(songColors[cast FlxMath.bound(i, 0, songColors.length-1)]);
					coolColors.set(formatColor(weekName, i), songColor);
				}
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
		lerpColor = FlxColorFix.fromFlxColor(getBgColor());
		
		for (song in grpSongs)  song.setTargetPos();
		for (icon in iconArray) icon.setSprTrackerPos();

		super.create();
	}

	public function addSong(songName:String, songCharacter:String, weekName:String, id:Int):Void {
		songs.push(new SongMetadata(songName, songCharacter, weekName, id));
	}

	public function addWeek(songs:Array<String>, ?songCharacters:Array<String>, week:String):Void {
		if (songCharacters == null) {
			songCharacters = ['bf'];
		}

		for (i in 0...songs.length) {
			var songIcon:String = songCharacters[cast FlxMath.bound(i, 0, songCharacters.length-1)];
			addSong(songs[i], songIcon, week, i);
		}
	}

	inline function formatColor(weekName:String, id:Int) {
		return '${weekName}_songID_$id';
	}

	function getBgColor():FlxColor {
		var curSongMeta = songs[curSelected];
		return coolColors.get(formatColor(curSongMeta.weekName, curSongMeta.ID));
	}

	var lerpColor:FlxColorFix;

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.sound.music.volume < 0.7) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(CoolUtil.coolLerp(lerpScore, intendedScore, 0.4));
		lerpColor.lerp(getBgColor(), 0.045, true);
		bg.color = lerpColor.get();

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
			switchState(new MainMenuState());
		}

		#if PRELOAD_ALL
		if(FlxG.keys.justPressed.ONE) {
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		}
		#end

		if(FlxG.keys.justPressed.SEVEN) {
			setupSong();
			switchState(new ChartingState());
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
		var lastWeekDiffs = WeekSetup.getWeekDiffs(songs[curSelected].weekName);
		curSelected = FlxMath.wrap(curSelected += change, 0, songs.length - 1);
		if (change != 0) CoolUtil.playSound('scrollMenu', 0.4);

		curWeekDiffs = WeekSetup.getWeekDiffs(songs[curSelected].weekName);
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

		for (i in iconArray) i.alpha = 0.6;
		iconArray[curSelected].alpha = 1;
	}
}

class SongMetadata {
	public var songName:String = "";
	public var weekName:String = "";
	public var songCharacter:String = "";
	public var ID:Int = 0;

	public function new(song:String, songCharacter:String, weekName:String, ID:Int):Void {
		this.songName = song;
		this.songCharacter = songCharacter;
		this.weekName = weekName;
		this.ID = ID;
	}
}