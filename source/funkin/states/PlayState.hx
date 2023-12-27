package funkin.states;

import funkin.util.modding.ScriptUtil;
import funkin.objects.note.BasicNote;
import funkin.states.editors.StageDebug;
import funkin.objects.funkui.FunkBar;
import funkin.objects.note.StrumLineGroup;
import funkin.objects.NotesGroup;

class PlayState extends MusicBeatState {
	public static var instance:PlayState;
	public static var clearCache:Bool = true;
	public static var clearCacheData:Null<CacheClearing> = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:String = 'tutorial';
	public static var storyPlaylist:Array<String> = [];
	public static var curDifficulty:String = 'normal';
	public static var inChartEditor:Bool = false;
	public static var deathCounter:Int = 0;

	private var stageJsonData:StageJson;
	public var bgSpr:FlxTypedGroup<Dynamic>;
	public var fgSpr:FlxTypedGroup<Dynamic>;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var dadGroup:FlxTypedSpriteGroup<Dynamic>;
	public var gfGroup:FlxTypedSpriteGroup<Dynamic>;
	public var boyfriendGroup:FlxTypedSpriteGroup<Dynamic>;

	private var camFollow:FlxObject;
	private var targetCamPos:FlxPoint;
	private static var prevCamFollow:FlxObject;

	private var curSectionData:SwagSection = null;

	public var notesGroup:NotesGroup;
	private var ratingGroup:RatingGroup;

	public var skipCountdown:Bool = false;
	public var camZooming:Bool = false;
	public var startingSong:Bool = false;

	public var gfSpeed:Int = 1;
	public var combo:Int = 0;
	public var health(default, set):Float = 1;
	function set_health(value:Float) {
		healthBar.updateBar(value = FlxMath.bound(value, 0, 2));
		if (value == 0 && validScore)
			openGameOverSubstate();
		return health = value;
	}

	public var noteCount:Int = 0;
	public var noteTotal:Float = 0;

	private var iconGroup:FlxSpriteGroup;
	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	public var healthBar:FunkBar;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var songLength:Float = 0;
	public var songScore:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxFunkText;
	var watermark:FunkinSprite;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;
	public var defaultCamSpeed:Float = 1;
	public var camFollowLerp:Float = 0.04;

	public static var seenCutscene:Bool = false;
	public var inCutscene:Bool = false;
	public var inDialogue:Bool = true;
	public var dialogueBox:DialogueBoxBase = null;

	// Discord RPC variables
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	inline function formatDiff() return CoolUtil.formatStringUpper(curDifficulty); // For discord rpc

	public var ghostTapEnabled:Bool = false;
	public var inPractice:Bool = false;
	private var validScore:Bool = true;
	
	public var pauseSubstate:PauseSubState;

	override public function create():Void {
		instance = this;

		clearCache ? CoolUtil.clearCache(clearCacheData) : FlxG.bitmap.clearUnused();
		clearCache = true;
		clearCacheData = null;

		inPractice = getPref('practice');
		validScore = !(getPref('botplay') || inPractice);
		ghostTapEnabled = getPref('ghost-tap-style') == "on";
		if (getPref('ghost-tap-style') == "dad turn" && SONG.notes[0] != null)
			ghostTapEnabled = !SONG.notes[0].mustHitSection;

		SkinUtil.initSkinData();
		NoteUtil.initTypes();
		EventUtil.initEvents();
		CoolUtil.stopMusic();
		
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = camOther.bgColor.alpha = 0;
		FlxG.camera.active = FlxG.camera.visible = FlxG.mouse.visible = false;

		FlxG.cameras.add(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		persistentUpdate = persistentDraw = true;

		SONG = Song.checkSong(SONG, null, false);

		detailsText = isStoryMode ? 'Story Mode: ${storyWeek.toUpperCase()}' : 'Freeplay';
		detailsPausedText = 'Paused - $detailsText';
		if (Character.getCharData(SONG.players[1]) != null) {
			iconRPC = Character.getCharData(SONG.players[1]).icon;
		}
		DiscordClient.changePresence(detailsText, '${SONG.song} (${formatDiff()})', iconRPC);

		//FG & BG SPRITES
		bgSpr = new FlxTypedGroup<Dynamic>();
		fgSpr = new FlxTypedGroup<Dynamic>();

		gfGroup = new FlxTypedSpriteGroup<Dynamic>();
		dadGroup = new FlxTypedSpriteGroup<Dynamic>();
		boyfriendGroup = new FlxTypedSpriteGroup<Dynamic>();

		final GF_POS:FlxPoint = FlxPoint.get(400,360);
		final DAD_POS:FlxPoint = FlxPoint.get(100, 450);
		final BOYFRIEND_POS:FlxPoint = FlxPoint.get(770, 450);

		//MAKE CHARACTERS
		gf = new Character(GF_POS.x, GF_POS.y, SONG.players[2]);
		dad = new Character(DAD_POS.x, DAD_POS.y, SONG.players[1]);
		boyfriend = new Character(BOYFRIEND_POS.x, BOYFRIEND_POS.y, SONG.players[0], true);

		//Cache Gameover Character
		final deadChar:Character = new Character(0,0,boyfriend.gameOverChar); // cache gameover char
		GameOverSubstate.cacheSounds();

		// GET THE STAGE JSON SHIT
		curStage = SONG.stage;
		stageJsonData = Stage.getJsonData(curStage);
		defaultCamZoom = stageJsonData.zoom;
		Paths.currentLevel = stageJsonData.library;
		SkinUtil.setCurSkin(stageJsonData.skin);

		//ADD CHARACTER OFFSETS
		Stage.applyData(stageJsonData, boyfriend, dad, gf);
		boyfriend.setXY(BOYFRIEND_POS.x, BOYFRIEND_POS.y);
		dad.setXY(DAD_POS.x, DAD_POS.y);
		gf.setXY(GF_POS.x, GF_POS.y,);

		//STAGE START CAM OFFSET
		final camPos:FlxPoint = FlxPoint.weak(-stageJsonData.startCamOffsets[0], -stageJsonData.startCamOffsets[1]);
		
		/*
						LOAD SCRIPTS
			Still a work in progress!!! Can be improved
		*/
		ModdingUtil.clearScripts(); //Clear any scripts left over

		//Stage Script
		final stageScript = ModdingUtil.addScript(Paths.script('stages/$curStage'));
		Stage.createStageObjects(stageJsonData.layers, stageScript); // Json created stages

		// Set up stuff for scripts
		gf.group = gfGroup;
		dad.group = dadGroup;
		boyfriend.group = boyfriendGroup;

		iconGroup = new FlxSpriteGroup();
		iconP1 = new HealthIcon(boyfriend.icon, true, true);
		iconP2 = new HealthIcon(dad.icon, false, true);
		dad.iconSpr = iconP2;
		boyfriend.iconSpr = iconP1;

		//Character Scripts
		boyfriend.type = "bf"; dad.type = "dad"; gf.type = "gf";
		for (char in [boyfriend, dad, gf]) addCharScript(char);

		//Song Scripts
		final songScripts:Array<String> = ModdingUtil.getScriptList('songs/${Song.formatSongFolder(SONG.song)}');
		ModdingUtil.addScriptList(songScripts);

		//Skin Script
		ModdingUtil.addScript(Paths.script('skins/${SkinUtil.curSkin}'));

		//Global Scripts
		final globalScripts:Array<String> = ModdingUtil.getScriptList('data/scripts/global');
		ModdingUtil.addScriptList(globalScripts);

		add(bgSpr);

		notesGroup = new NotesGroup(SONG); // Should be after fg is created but makin sure

		ModdingUtil.addCall('create');

		add(notesGroup);
		notesGroup.init();

		// Make Dad GF
		if (SONG.players[1] == SONG.players[2] && dad.isGF) {
			dadGroup.setPosition(GF_POS.x - DAD_POS.x, GF_POS.y - DAD_POS.y);
			gfGroup.alpha = 0;
		}
		BOYFRIEND_POS.put(); DAD_POS.put(); GF_POS.put();

		//Sprites order

		add(gfGroup);
		gfGroup.add(gf);
		gfGroup.scrollFactor.set(0.95, 0.95);
		
		add(dadGroup);
		dadGroup.add(dad);

		add(boyfriendGroup);
		boyfriendGroup.add(boyfriend);

		add(fgSpr);

		//Cam Follow
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		targetCamPos = FlxPoint.get();
		camFollowLerp = 0.04 * defaultCamSpeed;
		camGame.follow(camFollow, LOCKON, camFollowLerp);
		camGame.zoom = defaultCamZoom;
		snapCamera();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		healthBar = new FunkBar(0, !getPref('downscroll') ? FlxG.height * 0.9 : FlxG.height * 0.1, SkinUtil.getAssetKey("healthBar"));
		healthBar.screenCenter(X);
		add(healthBar);

		add(iconGroup);
		for (i in [iconP1,iconP2]) iconGroup.add(i);

		scoreTxt = new FlxFunkText(0, healthBar.y + 30, "", FlxPoint.get(FlxG.width, 20));
		add(scoreTxt);

		if (getPref('vanilla-ui')) {
			scoreTxt.setPosition(healthBar.x + healthBar.width - 190, healthBar.y + 30);
			scoreTxt.style = TextStyle.OUTLINE(1, 6, FlxColor.BLACK);
		} else {
			scoreTxt.size = 20;
			scoreTxt.style = TextStyle.OUTLINE(2, 6, FlxColor.BLACK);
			scoreTxt.alignment = "center";
		}

		ratingGroup = new RatingGroup(boyfriend);
		add(ratingGroup);
		updateScore();

		watermark = new FunkinSprite(SkinUtil.getAssetKey("watermark"), [FlxG.width, getPref('downscroll') ? 0 : FlxG.height], [0,0]);
		for (i in ['botplay', 'practice']) watermark.addAnim(i, i.toUpperCase(), 24, true);
		watermark.playAnim(notesGroup.inBotplay ? 'botplay' : 'practice');
		watermark.setScale(SkinUtil.curSkinData.scale * 0.7);
		watermark.x -= watermark.width * 1.2; watermark.y -= watermark.height * (getPref('downscroll') ? -0.2 : 1.2);
		watermark.alpha = validScore ? 0 : 0.8;
		add(watermark);

		// Set objects to HUD cam
		for (i in [notesGroup,  healthBar, iconGroup, scoreTxt, watermark])
			i.camera = camHUD;

		startingSong = true;
		ModdingUtil.addCall('createPost');
		inCutscene ? ModdingUtil.addCall('startCutscene', [false]) : startCountdown();

		super.create();
		destroySubStates = false;
		pauseSubstate = new PauseSubState();
	}

	public function startVideo(path:String, ?completeFunc:Dynamic):Void {
		completeFunc = completeFunc ?? startCountdown;
		#if VIDEOS_ALLOWED
		final video:FlxVideo = new FlxVideo();
		final vidFunc = function () {
			video.dispose();
			completeFunc();
		}
		video.onEndReached.add(vidFunc);
		video.play(Paths.video(path));
		#else
			completeFunc();
		#end
	}

	public var openDialogueFunc:Dynamic = null;

	function createDialogue():Void {
		showUI(false);
		ModdingUtil.addCall('createDialogue'); // Setup dialogue box
		ModdingUtil.addCall('postCreateDialogue'); // Setup transitions

		openDialogueFunc = openDialogueFunc ?? function () { // Default transition
			final black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			black.scrollFactor.set();
			add(black);

			if (black.alpha > 0) {
				FlxTween.tween(black, {alpha: 0}, 1.5, { ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween) {
					quickDialogueBox();
					remove(black);
				}});
			} else {
				quickDialogueBox();
				remove(black);
			}
		}
		openDialogueFunc();
	}

	public function quickDialogueBox():Void {
		if (dialogueBox == null) {
			dialogueBox = switch (SkinUtil.curSkin) {
				case 'pixel':	new PixelDialogueBox();
				default:		new NormalDialogueBox();
			}
		}

		dialogueBox.closeCallback = startCountdown;
		dialogueBox.camera = camHUD;
		add(dialogueBox);
	}

	public var startTimer:FlxTimer = null;

	function startCountdown():Void {
		showUI(true);
		inCutscene = false;
		inDialogue = false;
		startedCountdown = true;
		seenCutscene = true;

		if (!notesGroup.skipStrumIntro) {
			for (strum in notesGroup.strumLineNotes)
				FlxTween.tween(strum, {y: StrumLineGroup.strumLineY, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * strum.noteData)});
		}

		Conductor.songPosition = -Conductor.crochet * 5;
		Conductor.setPitch(Conductor.songPitch);
		curSectionData = Song.checkSection(SONG.notes[0]);
		cameraMovement();

		if (skipCountdown) {
			Conductor.songPosition = 0;
			return;
		}

		ModdingUtil.addCall('startCountdown');

		var swagCounter:Int = 0;
		final countdownSoundKeys:Array<String> = []; // Cache countdown assets
		final countdownSpriteKeys:Array<String> = [];

		for (i in ['intro3','intro2','intro1','introGo']) {
			final soundKey = SkinUtil.getAssetKey(i,SOUND);
			Paths.sound(soundKey);
			countdownSoundKeys.push(soundKey);
		}

		for (i in ['ready','set','go']) {
			final spriteKey = SkinUtil.getAssetKey(i,IMAGE);
			Paths.image(spriteKey);
			countdownSpriteKeys.push(spriteKey);
		}

		startTimer = new FlxTimer().start(Conductor.crochetMills, function(tmr:FlxTimer) {
			ModdingUtil.addCall('startTimer', [swagCounter]);
			beatCharacters();

			if (swagCounter > 0) {
				final countdownSpr:FunkinSprite = new FunkinSprite(countdownSpriteKeys[swagCounter-1]);
				countdownSpr.setScale(SkinUtil.curSkinData.scale);
				countdownSpr.screenCenter();
				countdownSpr.camera = camHUD;
				add(countdownSpr);

				countdownSpr.acceleration.y = SONG.bpm*60;
				countdownSpr.velocity.y -= SONG.bpm*10;
				FlxTween.tween(countdownSpr, {alpha: 0}, Conductor.crochetMills, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) countdownSpr.destroy()});
			}

			CoolUtil.playSound(countdownSoundKeys[swagCounter],0.6);
			swagCounter++;
		}, 4);
	}

	public function startSong():Void {
		camZooming = true;
		startingSong = false;
		CoolUtil.stopMusic();

		ModdingUtil.addCall('startSong');

		if (!paused) {
			Conductor.play();
			Conductor.sync();
		}

		Conductor.setPitch(Conductor.songPitch);
		Conductor.volume = 1;

		// Song duration in a float, useful for the time left feature
		songLength = Conductor.inst.length;
		DiscordClient.changePresence(detailsText, '${SONG.song} (${formatDiff()})', iconRPC, true, songLength);
	}

	private function openPauseSubState(easterEgg:Bool = false):Void {
		if (!paused) {
			if (ModdingUtil.addCall("openPauseSubState", [])) return;
			paused = true;
			persistentUpdate = false;
			persistentDraw = true;
			camGame.followLerp = 0;
			if (!startingSong)
				Conductor.pause();
			
			CoolUtil.setGlobalManager(false);
			CoolUtil.pauseSounds();
	
			pauseSubstate.init();
			openSubState((easterEgg && FlxG.random.bool(0.1)) ? new funkin.substates.GitarooPauseSubState() : pauseSubstate);
		}
	}

	override function openSubState(SubState:FlxSubState):Void {
		Conductor.setPitch(1, false);
		super.openSubState(SubState);
	}

	override function closeSubState():Void {
		if (paused) {
			paused = false;
			camGame.followLerp = camFollowLerp;
			CoolUtil.setGlobalManager(true);

			if (!startingSong) {
				Conductor.setPitch(Conductor.songPitch);
				Conductor.sync();
				Conductor.play();
			}

			var presenceDetails = '${SONG.song} (${formatDiff()})';
			var presenceTime = songLength - Conductor.songPosition;
			DiscordClient.changePresence(detailsText, presenceDetails, iconRPC, Conductor.songPosition >= 0, presenceTime);
		}
		super.closeSubState();
	}

	public var paused:Bool = false;
	public var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var canDebug:Bool = true;

	public function updateScore():Void {
		var songAccuracy:Null<Float> = (noteCount > 0) ? 0 : null;
		var songRating:String = '?';

		if (noteCount > 0) {
			songAccuracy = (noteTotal/noteCount)*100;
			songAccuracy = FlxMath.roundDecimal(songAccuracy, 2);
			songRating = Highscore.getAccuracyRating(songAccuracy).toUpperCase();
		}

		if (getPref('vanilla-ui')) {
			scoreTxt.text = 'Score:$songScore';
		} else {
			scoreTxt.text =
			'Score: $songScore / Accuracy: ${(noteCount > 0) ? '$songAccuracy%' : ''} [$songRating] / Misses: $songMisses';
		}

		ModdingUtil.addCall('updateScore', [songScore]);
	}

	var oldIconID:Int = 0; // Old icon easter egg
	public var allowIconEasterEgg:Bool = true;
	inline function changeOldIcon() {
		switch (oldIconID = FlxMath.wrap(oldIconID + 1, 0, 2)) {
			default: 	iconP1.makeIcon(boyfriend.icon); 	iconP2.makeIcon(dad.icon);
			case 1: 	iconP1.makeIcon('bf-old'); 			iconP2.makeIcon('dad');
			case 2: 	iconP1.makeIcon('bf-older'); 		iconP2.makeIcon('dad-older');
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		ModdingUtil.addCall('update', [elapsed]);

		if (FlxG.keys.justPressed.NINE && allowIconEasterEgg) {
			changeOldIcon();
		}
		else if (canDebug) {
			if (FlxG.keys.justPressed.SIX) {
				DiscordClient.changePresence("Stage Editor", null, null, true);
				switchState(new StageDebug(stageJsonData));
			}
			else if (FlxG.keys.justPressed.SEVEN) {
				clearCacheData = {sounds: false};
				switchState(new ChartingState());
				DiscordClient.changePresence("Chart Editor", null, null, true);
			}
			else if (FlxG.keys.justPressed.EIGHT) {
				DiscordClient.changePresence("Character Editor", null, null, true);
	
				/* 	8 for opponent char
				 *  SHIFT + 8 for player char
				 *	CTRL + SHIFT + 8 for gf */
				if (FlxG.keys.pressed.SHIFT) {
					if (FlxG.keys.pressed.CONTROL) switchState(new AnimationDebug(SONG.players[2]));
					else switchState(new AnimationDebug(SONG.players[0]));
				}
				else switchState(new AnimationDebug(SONG.players[1]));
			}
			else if (getKey('PAUSE-P') && startedCountdown && canPause) {
				openPauseSubState(true);
				DiscordClient.changePresence(detailsPausedText, '${SONG.song} (${formatDiff()})', iconRPC);
			}
			else if (FlxG.keys.justPressed.ONE && CoolUtil.debugMode)
				endSong();
		}

		//End the song if the conductor time is the same as the length
		if (Conductor.songPosition >= songLength && canPause)
			endSong();

		if (camZooming) {
			camGame.zoom = CoolUtil.coolLerp(camGame.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = CoolUtil.coolLerp(camHUD.zoom, 1, 0.05);
		}

		// RESET -> Quick Game Over Screen
		if (getKey('RESET-P') && !inCutscene && canDebug) health = 0;

		ModdingUtil.addCall('updatePost', [elapsed]);
	}

	public function openGameOverSubstate() {
		if (ModdingUtil.addCall("openGameOverSubstate", [])) return;
		persistentUpdate = persistentDraw = false;
		boyfriend.stunned = paused = true;

		deathCounter++;
		Conductor.stop();
		openSubState(new GameOverSubstate(boyfriend.OG_X, boyfriend.OG_Y));
			
		// Game Over doesn't get his own variable because it's only used here
		DiscordClient.changePresence('Game Over - $detailsText', SONG.song + ' (${formatDiff()})', iconRPC);
	}

	inline public function snapCamera() {
		camGame.focusOn(camFollow.getPosition());
	}

	public var camMove:Bool = true;
	
	public function cameraMovement():Void {
		if (!camMove || !notesGroup.generatedMusic || curSectionData == null) return;
		final mustHit:Bool = curSectionData.mustHitSection;
		mustHit ? boyfriend.prepareCamPoint(targetCamPos) : dad.prepareCamPoint(targetCamPos);

		if (camFollow.x != targetCamPos.x) {
			camFollow.setPosition(targetCamPos.x, targetCamPos.y);
			ModdingUtil.addCall('cameraMovement', [mustHit ? 1 : 0, targetCamPos]);
		}
	}

	function endSong():Void {
		canPause = false;
		deathCounter = 0;
		Conductor.volume = 0;
		ModdingUtil.addCall('endSong');
		if (validScore) Highscore.saveSongScore(SONG.song, curDifficulty, songScore);

		if (inChartEditor) {
			switchState(new ChartingState());
			DiscordClient.changePresence("Chart Editor", null, null, true);
		}
		else inCutscene ? ModdingUtil.addCall('startCutscene', [true]) : exitSong();
	}

	public function exitSong() {
		if (isStoryMode) {
			campaignScore += songScore;
			storyPlaylist.remove(storyPlaylist[0]);
			storyPlaylist.length <= 0 ? endWeek() : switchSong();
		}
		else {
			trace('WENT BACK TO FREEPLAY??');
			clearCache = true;
			switchState(new FreeplayState());
		}
	}

	public function endWeek() {
		if (validScore) {
			Highscore.saveWeekScore(storyWeek, curDifficulty, campaignScore);
			final weekData = WeekSetup.weekMap.get(storyWeek)?.data ?? null;
			if (weekData != null && WeekSetup.weekMap.exists(weekData.unlockWeek))
				Highscore.setWeekUnlock(weekData.unlockWeek, true);
		}

		ModdingUtil.addCall('endWeek');

		clearCache = true;
		switchState(new StoryMenuState());
	}

	function switchSong():Void {
		final nextSong:String = PlayState.storyPlaylist[0];
		trace('LOADING NEXT SONG [$nextSong-$curDifficulty]');

		prevCamFollow = camFollow;
		seenCutscene = false;

		PlayState.SONG = Song.loadFromFile(curDifficulty, nextSong);
		Conductor.stop();

		clearCache = true;
		clearCacheData = { // Clear last song audio and shaders
			bitmap: false,
			skins: false
		}
		ModdingUtil.addCall('switchSong', [nextSong, curDifficulty]); // Could be used to change cache clear
		switchState(new PlayState(), true);
	}

	override function startTransition() {
		canDebug = canPause = false;
		super.startTransition();
	}

	static final ratingMap:Map<String, {final score:Int; final note:Float; final ghostLoss:Float;}> = [
		"sick" => {score: 350, note: 1, ghostLoss: 0},
		"good" => {score: 200, note: 0.8, ghostLoss: 0},
		"bad" => {score: 100, note: 0.5, ghostLoss: 0.06},
		"shit" => {score: 50, note: 0.25, ghostLoss: 0.1}
	];

	public function popUpScore(strumtime:Float, daNote:Note) {
		combo++;
		noteCount++;
		ModdingUtil.addCall('popUpScore', [daNote]);

		final noteRating:String = CoolUtil.getNoteJudgement(CoolUtil.getNoteDiff(daNote));
		final ratingData = ratingMap[noteRating];
		songScore += ratingData.score;
		noteTotal += ratingData.note;
		health -= ghostTapEnabled ? ratingData.ghostLoss : 0;

		if (!getPref('stack-rating')) {
			for (rating in ratingGroup)
				rating.kill();
		}
		
		ratingGroup.drawComplete(noteRating, combo);
		updateScore();

		return noteRating;
	}

	override function stepHit(curStep:Int):Void {
		super.stepHit(curStep);
		Conductor.autoSync();
		ModdingUtil.addCall('stepHit', [curStep]);
	}

	inline function beatCharacters() {
		iconP1.bumpIcon(); 			iconP2.bumpIcon();
		boyfriend.danceInBeat(); 	dad.danceInBeat();
		if (curBeat % gfSpeed == 0) gf.danceInBeat();
	}

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		beatCharacters();
		ModdingUtil.addCall('beatHit', [curBeat]);
	}

	override public function sectionHit(curSection:Int):Void {
		super.sectionHit(curSection);
		if (Conductor.songPosition <= 0) curSection = 0;
		curSectionData = SONG.notes[curSection];
		cameraMovement();

		if (curSectionData != null && curSectionData.changeBPM && curSectionData.bpm != Conductor.bpm)
			Conductor.bpm = curSectionData.bpm;

		if (camZooming && getPref('camera-zoom')) {
			camGame.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (getPref('ghost-tap-style') == "dad turn" && curSectionData != null)
			ghostTapEnabled = !curSectionData.mustHitSection;

		ModdingUtil.addCall('sectionHit', [curSection]);
	}

	override function destroy():Void {
		Conductor.setPitch(1, false);
		Conductor.stop();
		CoolUtil.destroyMusic();
		SkinUtil.setCurSkin('default');
		ModdingUtil.addCall('destroy');

		targetCamPos = FlxDestroyUtil.put(targetCamPos);
		if (clearCache) CoolUtil.clearCache(clearCacheData);
		instance = null;
		super.destroy();
	}

	inline function addCharScript(char:Character) {
		final script = ModdingUtil.addScript(Paths.script('characters/' + char.curCharacter), '_charScript_' + char.type);
		if (script != null) {
			char.script = script;
			script.set('ScriptChar', char);
			script.call('createChar', [char]);
		}
	}

	public function switchChar(type:String, newCharName:String) {
		final targetChar:Character = switch(type = type.toLowerCase().trim()) {
			case 'dad': dad;
			case 'gf' | 'girlfriend': gf;
			default: boyfriend;
		}

		if (targetChar.curCharacter == newCharName) return; // Is already that character

		final newChar:Character = new Character(0, 0, newCharName,targetChar.isPlayer).copyStatusFrom(targetChar);
		if (targetChar.iconSpr != null) targetChar.iconSpr.makeIcon(newChar.icon);
		
		// Clear character group
		targetChar.callScript("destroyChar", [targetChar, newChar, newCharName]);
		final _grp = targetChar.group;
		for (i in _grp) i.destroy();
		_grp.clear();

		// Character script
		_grp.add(newChar);
		addCharScript(newChar);

		switch (type) {
			case 'dad': dad = newChar;
			case 'girlfriend' | 'gf': gf = newChar;
			default: boyfriend = newChar;
		}
		cameraMovement();
	}

	public function showUI(bool:Bool):Void {
		final displayObjects:Array<Dynamic> = [iconGroup, scoreTxt, healthBar, notesGroup, watermark];
		for (i in 0...displayObjects.length) displayObjects[i].visible = bool;
	}

	// For backwards compatibility and my own sanity, its ugly i know!!
	public var notes(get,never):FlxTypedGroup<BasicNote>; inline function get_notes()return notesGroup.notes;
	public var unspawnNotes(get,never):Array<BasicNote>; inline function get_unspawnNotes()return notesGroup.unspawnNotes;
	public var holdingArray(get,never):Array<Bool>; inline function get_holdingArray()return notesGroup.holdingArray;
	public var controlArray(get,never):Array<Bool>; inline function get_controlArray()return notesGroup.controlArray;
	public var strumLineNotes(get,never):Array<NoteStrum>; inline function get_strumLineNotes()return notesGroup.strumLineNotes;
	public var playerStrums(get,never):StrumLineGroup; inline function get_playerStrums()return notesGroup.playerStrums;
	public var opponentStrums(get,never):StrumLineGroup; inline function get_opponentStrums()return notesGroup.opponentStrums;
	public var playerStrumNotes(get,never):Array<NoteStrum>; inline function get_playerStrumNotes()return notesGroup.playerStrums.members;
	public var opponentStrumNotes(get,never):Array<NoteStrum>; inline function get_opponentStrumNotes()return notesGroup.opponentStrums.members;
	public var strumLineInitPos(get,never):Array<FlxPoint>; inline function get_strumLineInitPos()return notesGroup.strumLineInitPos;
	public var playerStrumsInitPos(get,never):Array<FlxPoint>; inline function get_playerStrumsInitPos()return notesGroup.playerStrumsInitPos;
	public var songSpeed(get,never):Float; inline function get_songSpeed()return NotesGroup.songSpeed;
	public var opponentStrumsInitPos(get,never):Array<FlxPoint>; inline function get_opponentStrumsInitPos()return notesGroup.opponentStrumsInitPos;
	public var grpNoteSplashes(get,never):FlxTypedGroup<NoteSplash>; inline function get_grpNoteSplashes()return notesGroup.grpNoteSplashes;
	public var curSong(get,never):String; inline function get_curSong()return notesGroup.curSong;
	public var generatedMusic(get,never):Bool;	inline function get_generatedMusic()return notesGroup.generatedMusic;
	public var inst(get, never):FlxSound; inline function get_inst()return Conductor.inst;
	public var vocals(get, never):FlxSound; inline function get_vocals()return Conductor.vocals;
	public var objMap(get, never):Map<String, Dynamic>; inline function get_objMap()return ScriptUtil.objMap;
	
	public var skipStrumIntro(get,set):Bool; inline function get_skipStrumIntro()return notesGroup.skipStrumIntro;
	inline function set_skipStrumIntro(value)return notesGroup.skipStrumIntro = value;
	public var inBotplay(get,set):Bool; inline function get_inBotplay()return notesGroup.inBotplay;
	inline function set_inBotplay(value)return notesGroup.inBotplay = value;
}