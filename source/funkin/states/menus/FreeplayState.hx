package funkin.states.menus;

//import flixel.addons.ui.FlxInputText;

typedef SongMetaData = {
	var song:String;
	var week:String;
	var char:String;
	var diffs:Array<String>;
	var color:FlxColor;
	var mod:String;
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetaData> = [];
	var curSongDiffs:Array<String> = ['easy', 'normal', 'hard'];

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var bg:FunkinSprite;
	var scoreBG:FlxSprite;
	var scoreText:FlxFunkText;
	var diffText:FlxFunkText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var grpSongs:TypedGroup<MenuAlphabet>;
	var iconArray:Array<HealthIcon> = [];

	override function create():Void
	{
		if (FlxG.sound.music == null)
			CoolUtil.playMusic('freakyMenu');
		
		FlxG.mouse.visible = #if mobile false; #else true; #end
		#if mobile MobileTouch.setLayout(FREEPLAY); #end

		#if discord_rpc // Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if debug
		addSong('test', 'bf', ['normal'], FlxColor.GRAY, 'test');
		#end

		WeekSetup.getWeekList().fastForEach((data, i) -> {
			final name = data.name;
			final week = data.data;
			
			if (!week.hideFreeplay) if (Highscore.getWeekUnlock(name))
			{
				final list = week.songList;

				// Parse colors
				var colors:Array<FlxColor> = [];
				list.songColors.fastForEach((color, i) -> colors.push(FlxColorFix.fromString(color)));
				
				// Add da week
				addWeek(list.songs, list.songIcons, list.songDiffs, colors, name, data.modFolder);
			}
		});

		bg = new FunkinSprite('menuDesat');
		bg.screenCenter();
		add(bg);

		grpSongs = new TypedGroup<MenuAlphabet>();
		add(grpSongs);

		songs.fastForEach((song, i) -> {
			var icon:HealthIcon;
			ModdingUtil.runFunctionMod(song.mod, () -> icon = new HealthIcon(song.char));

			var text:MenuAlphabet = new MenuAlphabet(0, (70 * i) + 30, song.song, true, i);
			grpSongs.add(text);

			var w = text.width + icon.width + 50;
			if (w > FlxG.width) {
				text.scale.x = (FlxG.width / w);
			}

			// using a FlxGroup is too much fuss!
			icon.sprTracker = text;
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
		grpSongs.members.fastForEach((item, i) -> item.snapPosition());
		lerpColor = FlxColorFix.fromFlxColor(getBgColor());

		super.create();
	}

	public function addSong(song:String, icon:String, diffs:Array<String>, color:FlxColor, week:String, mod:String = ""):Void {
		songs.push({
			song: song,
			week: week,
			char: icon,
			diffs: diffs,
			color: color,
			mod: mod
		});
	}

	public function addWeek(list:Array<String>, ?icons:Array<String>, ?diffs:Array<Array<String>>, ?colors:Array<FlxColor>, week:String, mod:String):Void {
		icons ??= ["bf"];
		diffs ??= [CoolUtil.defaultDiffArray.copy()];
		colors ??= [FlxColor.WHITE];

		list.fastForEach((song, i) -> {
			var icon = icons[Std.int(FlxMath.bound(i, 0, icons.length - 1))];
			var diffs = diffs[Std.int(FlxMath.bound(i, 0, diffs.length - 1))];
			var color = colors[Std.int(FlxMath.bound(i, 0, colors.length - 1))];
			addSong(song, icon, diffs, color, week, mod);
		});
	}

	var lerpColor:FlxColorFix;
	var targetColor:FlxColor;

	function getBgColor():FlxColor {
		return songs[curSelected].color;
	}

	var loadedSong:String = "";
	var loadedDiff:String = "";
	var lerpPosition:Float = 0.0;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.sound.music != null) {
			if (FlxG.sound.music.volume < 0.7)
				FlxG.sound.music.volume += 0.5 * elapsed;
		}

		lerpScore = Math.floor(CoolUtil.coolLerp(lerpScore, intendedScore, 0.4));
		lerpColor.lerp(targetColor ?? FlxColor.WHITE, 0.045, true);
		lerpColor.colorSprite(bg);

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
			final curSong = songs[curSelected].song;
			final curDiff = curSongDiffs[curDifficulty];
			if ((curSong != loadedSong) || (curDiff != loadedDiff))
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				// Make a new thread to load the music
				FunkThread.run(() -> ModdingUtil.runFunctionMod(songs[curSelected].mod, () -> {
					PlayState.curDifficulty = curDiff;
					FlxG.sound.playMusic(Paths.inst(curSong), 0);
				}));

				loadedSong = curSong;
				loadedDiff = curDiff;
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
				while (tmr >= 0.1333) {
					tmr -= 0.1333;
					changeSelection(getKey('UI_UP', PRESSED) ? -1 : 1);
				}
			}
		} else {
			startTmr = 0;
			tmr = 0;
		}
	}

	// For hscript
	#if MODS_ALLOWED dynamic #else inline #end function selectSong(toChart:Bool):Void {
		loadSong(toChart);
	}

	function loadSong(toChart:Bool):Void {
		var songData = songs[curSelected];
		var diff = curSongDiffs[curDifficulty];
		#if mobile MobileTouch.setLayout(NONE); #end
		WeekSetup.loadSong(songData.week, songData.song, diff, false, false, #if DEV_TOOLS toChart ? ChartingState : #end null);
	}

	function changeDiff(change:Int = 0):Void {
		curDifficulty = FlxMath.wrap(curDifficulty += change, 0, curSongDiffs.length - 1);
		intendedScore = Highscore.getSongScore(songs[curSelected].song, curSongDiffs[curDifficulty]);
		
		var diffString:String = curSongDiffs[curDifficulty].toUpperCase();
		diffText.text = curSongDiffs.length > 1 ? "< " + diffString + " >" : diffString;
		updateLerpPosition();
	}

	function updateLerpPosition() {
		final lastTxt = scoreText.text;
		scoreText.text = "PERSONAL BEST: " + intendedScore;
		lerpPosition = Math.min((FlxG.width * 0.69) - 6, FlxG.width - Math.max(scoreText.textWidth, diffText.textWidth) - 6);
		scoreText.text = lastTxt;
	}

	function changeSelection(change:Int = 0):Void
	{
		var lastDiff = curSongDiffs[curDifficulty] ?? "";	
		curSelected = FlxMath.wrap(curSelected += change, 0, songs.length - 1);
		if (change != 0) CoolUtil.playSound('scrollMenu', 0.4);

		// Try to find the index of the last song's diff
		curSongDiffs = songs[curSelected].diffs;		
		curDifficulty = curSongDiffs.indexOf(lastDiff);
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