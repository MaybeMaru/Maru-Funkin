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

	var grpSongs:TypedGroup<MenuAlphabet>;
	var iconArray:Array<HealthIcon> = [];

	//var inputText:SongSearch;

	override function create():Void
	{
		if (FlxG.sound.music == null)
			CoolUtil.playMusic('freakyMenu');
		
		FlxG.mouse.visible = #if mobile false; #else true; #end
		#if mobile MobileTouch.setMode(MENU); #end

		#if DISCORD_ALLOWED // Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if debug
		addSong('test','bf','test',-1);
		#end

		coolColors = new Map<String, FlxColor>();

		WeekSetup.getWeekList().fastForEach((data, i) -> {
			final name = data.name;
			final week = data.data;
			
			if (!week.hideFreeplay) if (Highscore.getWeekUnlock(name))
			{
				final list = week.songList;
				addWeek(list.songs, list.songIcons, name, data.modFolder);

				final colors = list.songColors;
				for (s in 0...list.songs.length) {
					final color = FlxColorFix.fromString(colors[cast FlxMath.bound(s, 0, colors.length - 1)]);
					coolColors.set(formatColor(name, s), color);
				}
			}
		});

		bg = new FunkinSprite('menuDesat');
		bg.screenCenter();
		add(bg);

		grpSongs = new TypedGroup<MenuAlphabet>();
		add(grpSongs);

		songs.fastForEach((song, i) -> {
			var icon:HealthIcon = null;
			ModdingUtil.runFunctionMod(song.mod, () -> icon = new HealthIcon(song.char));

			final _width = Alphabet.spaceWidth * song.song.length;
			final _icoWidth = icon.width * 1.1 + 10;		
			final _scale:Float = _icoWidth + _width > FlxG.width ? (FlxG.width - _icoWidth) / _width : 1;

			var songText:MenuAlphabet = new MenuAlphabet(0, (70 * i) + 30, song.song, true, 0, _scale);
			songText.letterArray.fastForEach((char, i) -> char.scale.y = 1.0);
			songText.targetY = i;
			songText.setTargetPos();
			grpSongs.add(songText);

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
		
		grpSongs.members.fastForEach((song, i) -> song.setTargetPos());
		iconArray.fastForEach((icon, i) -> icon.setSprTrackerPos());

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
			var songIcon:String = songCharacters[Std.int(FlxMath.bound(i, 0, songCharacters.length-1))];
			addSong(songs[i], songIcon, week, i, mod);
		}
	}

	inline function formatColor(weekName:String, id:Int):String
		return weekName + '_songID_$id';

	var lerpColor:FlxColorFix;
	var targetColor:FlxColor;

	function getBgColor():FlxColor {
		final curSongMeta = songs[curSelected];
		return coolColors.get(formatColor(curSongMeta.week, curSongMeta.ID));
	}

	var loadedSong:String = "";
	var lerpPosition:Float = 0.0;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(CoolUtil.coolLerp(lerpScore, intendedScore, 0.4));
		lerpColor.lerp(targetColor ?? FlxColor.WHITE, 0.045, true);
		bg.color = lerpColor.get();

		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
		scoreText.text = "PERSONAL BEST: " + lerpScore;

		scoreBG.x = Math.max(CoolUtil.coolLerp(scoreBG.x, lerpPosition, 0.2), 0);
		scoreText.x = Math.max(CoolUtil.coolLerp(scoreText.x, lerpPosition, 0.2), 0);
		diffText.x = CoolUtil.coolLerp(diffText.x, lerpPosition, 0.2);

		if (getKey('UI_LEFT', JUST_PRESSED))	changeDiff(-1);
		if (getKey('UI_RIGHT', JUST_PRESSED))	changeDiff(1);
		detectChangeSelection();

		if (getKey('BACK', JUST_PRESSED)) {
			switchState(new MainMenuState());
		}

		#if desktop
		if(FlxG.keys.justPressed.ONE) {
			
			final curSong = cast songs[curSelected];
			if (curSong.song != loadedSong)
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				// Make a new thread to load the music
				FunkThread.run(() -> ModdingUtil.runFunctionMod(songs[curSelected].mod, () -> FlxG.sound.playMusic(Paths.inst(curSong.song), 0)));
				loadedSong = curSong.song;
			}
			else if (FlxG.sound.music != null)
				FlxG.sound.music.time = FlxG.sound.music.volume = 0;
		}
		#end

		#if DEV_TOOLS
		if(FlxG.keys.justPressed.SEVEN)
			selectSong(true);
		#end

		if (getKey('ACCEPT', JUST_PRESSED))
			selectSong(false);
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

	// For hscript
	#if MODS_ALLOWED dynamic #end function selectSong(toChart:Bool):Void {
		loadSong(toChart);
	}

	function loadSong(toChart:Bool):Void {
		var songData = songs[curSelected];
		var diff = curWeekDiffs[curDifficulty];
		#if mobile MobileTouch.setMode(NONE); #end
		WeekSetup.loadSong(songData.week, songData.song, diff, false, false, #if DEV_TOOLS toChart ? ChartingState : #end null);
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

		grpSongs.members.fastForEach((item, i) -> {
			item.targetY = i - curSelected;
			item.alpha = (item.targetY == 0) ? 1 : 0.6;
		});

		iconArray.fastForEach((icon, i) -> icon.alpha = 0.6);
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