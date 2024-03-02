package funkin.states.menus;

//import flixel.addons.ui.FlxInputText;

typedef SongMetaData = {
	var song:String;
	var week:String;
	var char:String;
	var ID:Int;
	var mod:String;
}

class FreeplayState extends MusicBeatState {
	var bg:FunkinSprite;

	var songs:Array<SongMetaData> = [];
	var coolColors:Map<String, FlxColor>;
	var curWeekDiffs:Array<String> = ['easy', 'normal', 'hard'];

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxFunkText;
	var diffText:FlxFunkText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var grpSongs:FlxTypedGroup<MenuAlphabet>;
	var iconArray:Array<HealthIcon> = [];

	//var inputText:SongSearch;

	override function create():Void {
		if (FlxG.sound.music == null) CoolUtil.playMusic('freakyMenu');
		FlxG.mouse.visible = true;

		#if cpp		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if debug
		addSong('test','bf','test',-1);
		#end

		coolColors = new Map<String, FlxColor>();
		for (i in 0...WeekSetup.getWeekList().length) {
			final data = WeekSetup.weekList[i];
			final weekName = data.name;
			final week = data.data;
			
			if (Highscore.getWeekUnlock(weekName) && !week.hideFreeplay)
			{
				addWeek(week.songList.songs, week.songList.songIcons, weekName, data.modFolder);

				final songColors = week.songList.songColors;
				for (i in 0...week.songList.songs.length) {
					final songColor = FlxColorFix.fromString(songColors[cast FlxMath.bound(i, 0, songColors.length-1)]);
					coolColors.set(formatColor(weekName, i), songColor);
				}
			}
		}

		bg = new FunkinSprite('menuDesat');
		add(bg);

		grpSongs = new FlxTypedGroup<MenuAlphabet>();
		add(grpSongs);

		songs.fastForEach((song, i) -> {
			var icon:HealthIcon = null;
			ModdingUtil.runFunctionMod(song.mod, function () {
				icon = new HealthIcon(song.char);
			});

			final _width = Alphabet.spaceWidth * song.song.length;
			final _icoWidth = icon.width * 1.1 + 10;		
			final _scale:Float = _icoWidth + _width > FlxG.width ? (FlxG.width - _icoWidth) / _width : 1;

			var songText:MenuAlphabet = new MenuAlphabet(0, (70 * i) + 30, song.song, true, 0, _scale);
			songText.targetY = i;
			songText.setTargetPos();
			grpSongs.add(songText);
			for (char in songText.letterArray)
				char.scale.y = 1;

			// using a FlxGroup is too much fuss!
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		});

		lerpPosition = FlxG.width * 0.69; // nice

		scoreBG = new FlxSprite(lerpPosition, 0).makeGraphic(FlxG.width, 70, FlxColor.BLACK);
		scoreBG.offset.x = 6;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		scoreText = new FlxFunkText(lerpPosition, 5, "", FlxPoint.weak(FlxG.width, 32) , 32);
		add(scoreText);

		diffText = new FlxFunkText(lerpPosition, scoreText.y + 36, "", FlxPoint.weak(FlxG.width, 24) , 24);
		add(diffText);

		changeSelection();
		lerpColor = FlxColorFix.fromFlxColor(getBgColor());
		//inputText = new SongSearch();
		//add(inputText);
		
		for (song in grpSongs)  song.setTargetPos();
		for (icon in iconArray) icon.setSprTrackerPos();

		super.create();
	}

	public function addSong(song:String, char:String, week:String, id:Int, mod:String = ""):Void {
		songs.push({
			song: song,
			week: week,
			char: char,
			ID: id,
			mod: mod
		});
	}

	public function addWeek(songs:Array<String>, ?songCharacters:Array<String>, week:String, mod:String):Void {
		songCharacters = songCharacters ?? ['bf'];
		for (i in 0...songs.length) {
			var songIcon:String = songCharacters[cast FlxMath.bound(i, 0, songCharacters.length-1)];
			addSong(songs[i], songIcon, week, i, mod);
		}
	}

	inline function formatColor(weekName:String, id:Int) {
		return '${weekName}_songID_$id';
	}

	var lerpColor:FlxColorFix;
	var targetColor:FlxColor;

	function getBgColor():FlxColor {
		final curSongMeta = songs[curSelected];
		return coolColors.get(formatColor(curSongMeta.week, curSongMeta.ID));
	}

	var _lastMusic:String = "";
	var lerpPosition:Float = 0.0;

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.sound.music.volume < 0.7) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(CoolUtil.coolLerp(lerpScore, intendedScore, 0.4));
		lerpColor.lerp(targetColor ?? FlxColor.WHITE, 0.045, true);
		bg.color = lerpColor.get();

		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
		scoreText.text = "PERSONAL BEST: " + lerpScore;

		//for (i in [scoreText,diffText,scoreBG]) i.x = CoolUtil.coolLerp(i.x, lerpPosition, 0.2);
		scoreBG.x = Math.max(CoolUtil.coolLerp(scoreBG.x, lerpPosition, 0.2), 0);
		scoreText.x = Math.max(CoolUtil.coolLerp(scoreText.x, lerpPosition, 0.2), 0);
		diffText.x = CoolUtil.coolLerp(diffText.x, lerpPosition, 0.2);

		if (getKey('UI_LEFT', JUST_PRESSED))	changeDiff(-1);
		if (getKey('UI_RIGHT', JUST_PRESSED))	changeDiff(1);
		detectChangeSelection();

		if (getKey('BACK', JUST_PRESSED)) {
			switchState(new MainMenuState());
		}

		#if PRELOAD_ALL
		if(FlxG.keys.justPressed.ONE) {
			final targetMusic = songs[curSelected].song;
			if (targetMusic != _lastMusic) {
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
				FunkThread.run(function () { // Make a new thread to load the music
					FlxG.sound.playMusic(Paths.inst(targetMusic, true), 0);
				});
				_lastMusic = targetMusic;

			} else if (FlxG.sound.music != null) {
				FlxG.sound.music.time = FlxG.sound.music.volume = 0;
			}
		}
		#end

		if(FlxG.keys.justPressed.SEVEN)
			loadSong(true);

		if (getKey('ACCEPT', JUST_PRESSED))
			loadSong(false);
	}

	var startTmr:Float = 0;
	var tmr:Float = 0;
	function detectChangeSelection():Void { //Unecessary but cool
		if (getKey('UI_UP', JUST_PRESSED) || getKey('UI_DOWN', JUST_PRESSED)) {
			startTmr = tmr = 0;
			changeSelection(getKey('UI_UP', JUST_PRESSED) ? -1 : 1);
		}

		if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		if (getKey('UI_UP', PRESSED) || getKey('UI_DOWN', PRESSED)) {
			startTmr +=  FlxG.elapsed;
			if (startTmr >= 0.333) {
				tmr += FlxG.elapsed;
				if (tmr >= 0.1333) {
					tmr = 0;
					changeSelection(getKey('UI_UP', PRESSED) ? -1 : 1);
				}
			}
		} else {
			startTmr = 0;
			tmr = 0;
		}
	}

	function loadSong(toChart:Bool):Void {
		var songData = songs[curSelected];
		var diff = curWeekDiffs[curDifficulty];
		WeekSetup.loadSong(songData.week, songData.song, diff, false, false, toChart ? ChartingState : null);
	}

	function changeDiff(change:Int = 0):Void {
		curDifficulty = FlxMath.wrap(curDifficulty += change, 0, curWeekDiffs.length - 1);
		intendedScore = Highscore.getSongScore(songs[curSelected].song, curWeekDiffs[curDifficulty]);
		
		var diffString:String = curWeekDiffs[curDifficulty].toUpperCase();
		diffText.text = curWeekDiffs.length > 1 ? "< " + diffString + " >" : diffString;
		updateLerpPosition();
	}

	function updateLerpPosition() {
		final lastTxt = scoreText.text;
		scoreText.text = "PERSONAL BEST: " + intendedScore;
		lerpPosition = Math.min((FlxG.width * 0.69) - 6, FlxG.width - Math.max(scoreText.textWidth, diffText.textWidth) - 6);
		scoreText.text = lastTxt;
	}

	function changeSelection(change:Int = 0):Void {
		var lastWeekDiffs = WeekSetup.getWeekDiffs(songs[curSelected].week);
		curSelected = FlxMath.wrap(curSelected += change, 0, songs.length - 1);
		if (change != 0) CoolUtil.playSound('scrollMenu', 0.4);

		curWeekDiffs = WeekSetup.getWeekDiffs(songs[curSelected].week);
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
		targetColor = getBgColor();
	}
}
/*
class SongSearch extends FlxInputText {
	public function new() {
		var _width = Math.round(FlxG.width * 0.4);
		var _size = 16;

		super(FlxG.width - _width - 8, FlxG.height - _size - 16, _width, "", _size);
	}
}*/