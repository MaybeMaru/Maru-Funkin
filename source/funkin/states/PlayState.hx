package funkin.states;

import funkin.objects.note.StrumLineGroup;
import funkin.objects.NotesGroup;
import flixel.ui.FlxBar;

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
	public var objMap:Map<String, Dynamic> = [];

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var dadGroup:FlxTypedSpriteGroup<Dynamic>;
	public var gfGroup:FlxTypedSpriteGroup<Dynamic>;
	public var boyfriendGroup:FlxTypedSpriteGroup<Dynamic>;

	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	private var curSectionData:SwagSection = null;

	public var notesGroup:NotesGroup;
	private var ratingGroup:RatingGroup;

	// For backwards compatibility and my own sanity, its ugly i know!!
	public var notes(get,never):FlxTypedGroup<Note>; function get_notes()return notesGroup.notes;
	public var unspawnNotes(get,never):Array<Note>; function get_unspawnNotes()return notesGroup.unspawnNotes;
	public var holdingArray(get,never):Array<Bool>; function get_holdingArray()return notesGroup.holdingArray;
	public var controlArray(get,never):Array<Bool>; function get_controlArray()return notesGroup.controlArray;
	public var strumLineNotes(get,never):Array<NoteStrum>; function get_strumLineNotes()return notesGroup.strumLineNotes;
	public var playerStrums(get,never):FlxTypedGroup<NoteStrum>; function get_playerStrums()return notesGroup.playerStrums;
	public var opponentStrums(get,never):FlxTypedGroup<NoteStrum>; function get_opponentStrums()return notesGroup.opponentStrums;
	public var strumLineInitPos(get,never):Array<FlxPoint>; function get_strumLineInitPos()return notesGroup.strumLineInitPos;
	public var playerStrumsInitPos(get,never):Array<FlxPoint>; function get_playerStrumsInitPos()return notesGroup.playerStrumsInitPos;
	public var songSpeed(get,never):Float; function get_songSpeed()return NotesGroup.songSpeed;
	public var opponentStrumsInitPos(get,never):Array<FlxPoint>;	function get_opponentStrumsInitPos()return notesGroup.opponentStrumsInitPos;
	public var grpNoteSplashes(get,never):FlxTypedGroup<NoteSplash>;	function get_grpNoteSplashes()return notesGroup.grpNoteSplashes;
	public var curSong(get,never):String;	function get_curSong()return notesGroup.curSong;
	public var generatedMusic(get,never):Bool;	function get_generatedMusic()return notesGroup.generatedMusic;
	public var inst(get, never):FlxSound; function get_inst()return Conductor.inst;
	public var vocals(get, never):FlxSound; function get_vocals()return Conductor.vocals;
	public var skipStrumIntro(get,set):Bool; function get_skipStrumIntro()return notesGroup.skipStrumIntro;
	function set_skipStrumIntro(value)return notesGroup.skipStrumIntro = value;
	public var inBotplay(get,set):Bool; function get_inBotplay()return notesGroup.inBotplay;
	function set_inBotplay(value)return notesGroup.inBotplay = value;

	public var skipCountdown:Bool = false;
	public var camZooming:Bool = false;
	public var startingSong:Bool = false;

	public var gfSpeed:Int = 1;
	public var combo:Int = 0;
	public var health(default, set):Float = 1;
	function set_health(value:Float) {
		value = FlxMath.bound(value, 0, 2);
		if (value <= 0 && validScore) {
			openGameOverSubstate();
		}
		return health = value;
	}

	public var noteCount:Int = 0;
	public var noteTotal:Float = 0;

	private var healthBarBG:FunkinSprite;
	public var healthBar:FlxBar;

	private var iconGroup:FlxSpriteGroup;
	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var songLength:Float = 0;
	public var songScore:Int = 0;
	public var songMisses:Int = 0;
	var scoreTxt:FunkinText;
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
		ghostTapEnabled = getPref('ghost-tap');

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

		SONG = Song.checkSong(SONG);

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

		var GF_POS:FlxPoint = new FlxPoint(400,360);
		var DAD_POS:FlxPoint = new FlxPoint(100, 450);
		var BOYFRIEND_POS:FlxPoint = new FlxPoint(770, 450);

		//MAKE CHARACTERS
		gf = new Character(GF_POS.x, GF_POS.y, SONG.players[2]);
		dad = new Character(DAD_POS.x, DAD_POS.y, SONG.players[1]);
		boyfriend = new Character(BOYFRIEND_POS.x, BOYFRIEND_POS.y, SONG.players[0], true);

		//Cache Gameover Character
		var deadChar:Character = new Character(0,0,boyfriend.gameOverChar);
		GameOverSubstate.cacheSounds();
		//add(deadChar);

		// GET THE STAGE JSON SHIT
		curStage = SONG.stage;
		stageJsonData = Stage.getJsonData(curStage);
		defaultCamZoom = stageJsonData.zoom;
		Paths.currentLevel = stageJsonData.library;
		SkinUtil.setCurSkin(stageJsonData.skin);

		boyfriend.stageOffsets.set(stageJsonData.bfOffsets[0], stageJsonData.bfOffsets[1]);
		dad.stageOffsets.set(stageJsonData.dadOffsets[0], stageJsonData.dadOffsets[1]);
		gf.stageOffsets.set(stageJsonData.gfOffsets[0], stageJsonData.gfOffsets[1]);

		//ADD CHARACTER OFFSETS
		boyfriend.setXY(BOYFRIEND_POS.x, BOYFRIEND_POS.y);
		dad.setXY(DAD_POS.x, DAD_POS.y);
		gf.setXY(GF_POS.x, GF_POS.y,);

		//STAGE START CAM OFFSET
		var camPos:FlxPoint = new FlxPoint().set(-stageJsonData.startCamOffsets[0], -stageJsonData.startCamOffsets[1]);
		
		/*
						LOAD SCRIPTS
			Still a work in progress!!! Can be improved
		*/
		ModdingUtil.clearScripts(); //Clear any scripts left over

		//Stage Script
		var stageScript = ModdingUtil.addScript(Paths.script('stages/$curStage'));
		Stage.createStageObjects(stageJsonData.layers, stageScript); // Json created stages

		//Character Scripts
		var characterScripts = ModdingUtil.getScriptList('data/characters');
		for (char => _char in [boyfriend => 'bf', dad => 'dad', gf => 'gf']) {
   			for (script in characterScripts) {
        		final charName = script.split('/').pop().split('.')[0];
        		if (char.curCharacter == charName) {
            		ModdingUtil.addScript(script, '_charScript_$_char').set('ScriptChar', char);
            		break;
        		}
    		}
		}

		//Song Scripts
		var songScripts:Array<String> = ModdingUtil.getScriptList('songs/${Song.formatSongFolder(SONG.song)}');
		for (script in songScripts)
			ModdingUtil.addScript(script);

		//Skin Script
		ModdingUtil.addScript(Paths.script('skins/${SkinUtil.curSkin}'));

		//Global Scripts
		var globalScripts:Array<String> = ModdingUtil.getScriptList('data/scripts/global');
		for (script in globalScripts)
			ModdingUtil.addScript(script);

		add(bgSpr);

		notesGroup = new NotesGroup(SONG); // Should be after fg is created but makin sure

		ModdingUtil.addCall('create');

		add(notesGroup);
		notesGroup.init();

		// Make Dad GF
		if (SONG.players[1] == SONG.players[2] && dad.isGF) {
			dad.setPosition(gf.x, gf.y);
			gfGroup.visible = false;
		}

		//Sprites order

		add(gfGroup);
		gf.group = gfGroup;
		gfGroup.add(gf);
		gfGroup.scrollFactor.set(0.95, 0.95);
		
		add(dadGroup);
		dad.group = dadGroup;
		dadGroup.add(dad);

		add(boyfriendGroup);
		boyfriend.group = boyfriendGroup;
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

		camFollowLerp = 0.04 * defaultCamSpeed;
		camGame.follow(camFollow, LOCKON, camFollowLerp);
		camGame.zoom = defaultCamZoom;
		snapCamera();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		healthBarBG = new FunkinSprite(SkinUtil.getAssetKey("healthBar"), [0,0], [0,0]);
		healthBarBG.y = !getPref('downscroll') ? FlxG.height * 0.9 : FlxG.height * 0.1;
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 6, healthBarBG.y + 4, RIGHT_TO_LEFT, cast healthBarBG.width - 12, cast healthBarBG.height - 8, this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		iconGroup = new FlxSpriteGroup();
		add(iconGroup);

		iconP1 = new HealthIcon(boyfriend.icon, true);
		iconP2 = new HealthIcon(dad.icon);

		for (i in [iconP1,iconP2]) {
			i.y = healthBar.y - (i.height*0.5);
			i.playIcon = true;
			iconGroup.add(i);
		}

		dad.iconSpr = iconP2;
		boyfriend.iconSpr = iconP1;

		scoreTxt = new FunkinText(healthBarBG.x, healthBarBG.y + 30);
		add(scoreTxt);

		if (getPref('vanilla-ui')) {
			scoreTxt.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.borderSize = 1;
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

		for (i in [notesGroup,  healthBar, healthBarBG, iconGroup, scoreTxt, watermark])
			i.cameras = [camHUD];

		startingSong = true;
		ModdingUtil.addCall('createPost');
		inCutscene ? ModdingUtil.addCall('startCutscene', [false]) : startCountdown();

		super.create();
		destroySubStates = false;
		pauseSubstate = new PauseSubState();
	}

	public function startVideo(path:String, ?completeFunc:Dynamic):Void {
		completeFunc = completeFunc == null ? startCountdown : completeFunc;
		#if cpp
		var video:FlxVideo = new FlxVideo();
		var vidFunc = function () {
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
			var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
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
			switch (SkinUtil.curSkin) {
				case 'pixel':	dialogueBox = new PixelDialogueBox();
				default:		dialogueBox = new NormalDialogueBox();
			}
		}

		dialogueBox.closeCallback = startCountdown;
		dialogueBox.cameras = [camHUD];
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
		var countdownSoundKeys:Array<String> = []; // Cache countdown assets
		var countdownSpriteKeys:Array<String> = [];

		for (i in ['intro3','intro2','intro1','introGo']) {
			var soundKey = SkinUtil.getAssetKey(i,SOUND);
			Paths.sound(soundKey);
			countdownSoundKeys.push(soundKey);
		}

		for (i in ['ready','set','go']) {
			var spriteKey = SkinUtil.getAssetKey(i,IMAGE);
			Paths.image(spriteKey);
			countdownSpriteKeys.push(spriteKey);
		}

		startTimer = new FlxTimer().start(Conductor.crochetMills, function(tmr:FlxTimer) {
			ModdingUtil.addCall('startTimer', [swagCounter]);
			beatCharacters();

			if (swagCounter > 0) {
				var countdownSpr:FunkinSprite = new FunkinSprite(countdownSpriteKeys[swagCounter-1]);
				countdownSpr.setScale(SkinUtil.curSkinData.scale);
				countdownSpr.screenCenter();
				countdownSpr.cameras = [camHUD];
				add(countdownSpr);

				countdownSpr.acceleration.y = SONG.bpm*60;
				countdownSpr.velocity.y -= SONG.bpm*10;
				FlxTween.tween(countdownSpr, {alpha: 0}, Conductor.crochetMills, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){countdownSpr.destroy();}});
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
			scoreTxt.setPosition(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30);
		} else {
			scoreTxt.text =
			'Score: $songScore / Accuracy: ${(noteCount > 0) ? '$songAccuracy%' : ''} [$songRating] / Misses: $songMisses';
			scoreTxt.x = healthBarBG.x + healthBarBG.width/2 - scoreTxt.width/2;
		}

		ModdingUtil.addCall('updateScore', [songScore]);
	}

	var oldIconID:Int = 0; // Old icon easter egg
	public var allowIconEasterEgg:Bool = true;
	function changeOldIcon() {
		oldIconID = FlxMath.wrap(oldIconID + 1, 0, 2);
		switch (oldIconID) {
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
		else if (FlxG.keys.justPressed.SEVEN) {
			clearCacheData = {sounds: false};
			CustomTransition.skipTrans = false;
			switchState(new ChartingState());
			DiscordClient.changePresence("Chart Editor", null, null, true);
		}
		else if (FlxG.keys.justPressed.EIGHT) {
			SkinUtil.setCurSkin('default');
			CustomTransition.skipTrans = false;
			switchState(new AnimationDebug(SONG.players[1]));
			DiscordClient.changePresence("Character Editor", null, null, true);
		}
		else if (getKey('PAUSE-P') && startedCountdown && canPause) {
			openPauseSubState(true);
			DiscordClient.changePresence(detailsPausedText, '${SONG.song} (${formatDiff()})', iconRPC);
		}

		//End the song if the conductor time is the same as the length
		if (Conductor.songPosition >= songLength && canPause)
			endSong();

		if (camZooming) {
			camGame.zoom = CoolUtil.coolLerp(camGame.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = CoolUtil.coolLerp(camHUD.zoom, 1, 0.05);
		}

		FlxG.watch.addQuick("curSection", 	curSection);
		FlxG.watch.addQuick("curBeat", 		curBeat);
		FlxG.watch.addQuick("curStep", 		curStep);

		// RESET -> Quick Game Over Screen
		if (getKey('RESET-P') && !inCutscene) health = 0;

		if (FlxG.keys.justPressed.ONE && CoolUtil.debugMode)
			endSong();

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
		DiscordClient.changePresence('Game Over - $detailsText', '${SONG.song} (${formatDiff()})', iconRPC);
	}

	inline public function snapCamera() {
		camGame.focusOn(camFollow.getPosition());
	}
	
	public function cameraMovement():Void {
		if (!notesGroup.generatedMusic || curSectionData == null) return;
		final mustHit:Bool = curSectionData.mustHitSection;

		var camOffsets:FlxPoint = null;
		var midPoint:FlxPoint = null;
		var stageCamOffsets:Array<Float> = null;
		if (mustHit) {
			camOffsets = boyfriend.camOffsets;
			midPoint = boyfriend.getMidpoint();
			stageCamOffsets = stageJsonData.bfCamOffsets;
		} else {
			camOffsets = dad.camOffsets;
			midPoint = dad.getMidpoint();
			stageCamOffsets = stageJsonData.dadCamOffsets;
		}

		final intendedPos = midPoint.x - camOffsets.x - stageCamOffsets[0];
		if (camFollow.x != intendedPos) {
			final camX = midPoint.x - camOffsets.x - stageCamOffsets[0];
			final camY = midPoint.y - camOffsets.y - stageCamOffsets[1];
			camFollow.setPosition(camX, camY);
			ModdingUtil.addCall('cameraMovement', [mustHit ? 1 : 0, camFollow.getPosition()]);
		}
	}

	function endSong():Void {
		canPause = false;
		deathCounter = 0;
		Conductor.volume = 0;
		ModdingUtil.addCall('endSong');
		if (validScore) Highscore.saveSongScore(SONG.song, curDifficulty, songScore);
		CustomTransition.skipTrans = isStoryMode;

		if (inChartEditor) {
			CustomTransition.skipTrans = false;
			switchState(new ChartingState());
			DiscordClient.changePresence("Chart Editor", null, null, true);
		}
		else {
			inCutscene ? ModdingUtil.addCall('startCutscene', [true]) : exitSong();
		}
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
			SkinUtil.setCurSkin('default');
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
		SkinUtil.setCurSkin('default');
		CustomTransition.skipTrans = false;
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
		clearCacheData = { // Clear last song audio and note cache
			bitmap: false
		}
		ModdingUtil.addCall('switchSong', [nextSong, curDifficulty]); // Could be used to change cache clear
		LoadingState.loadAndSwitchState(new PlayState());
	}

	static final ratingMap:Map<String, Dynamic> = [
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
		for (i in [iconP1, iconP2]) i.bumpIcon();
		for (i in [dad, boyfriend]) i.danceInBeat();
		if (curBeat % gfSpeed == 0) gf.danceInBeat();
	}

	override public function beatHit(curBeat:Int):Void {
		super.beatHit(curBeat);
		if (curSectionData != null) {
			if (curSectionData.changeBPM) {
				Conductor.bpm = curSectionData.bpm;
				FlxG.log.add('CHANGED BPM!');
			}
		}

		beatCharacters();
		ModdingUtil.addCall('beatHit', [curBeat]);
	}

	override public function sectionHit(curSection:Int):Void {
		super.sectionHit(curSection);
		if (Conductor.songPosition <= 0) curSection = 0;
		curSectionData = SONG.notes[curSection];
		cameraMovement();

		if (camZooming && getPref('camera-zoom')) {
			camGame.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (getPref('deghost-tap') && curSectionData != null){
			ghostTapEnabled = !curSectionData.mustHitSection;
		}

		ModdingUtil.addCall('sectionHit', [curSection]);
	}

	override function destroy():Void {
		Conductor.setPitch(1, false);
		Conductor.stop();
		CoolUtil.destroyMusic();
		ModdingUtil.addCall('destroy');
		if (clearCache) CoolUtil.clearCache(clearCacheData);
		super.destroy();
	}

	public function switchChar(type:String, newCharName:String) {
		var targetChar:Character = boyfriend;
		switch (type.toLowerCase().trim()) {
			case 'dad': targetChar = dad;
			case 'girlfriend' | 'gf': targetChar = gf;
		}

		targetChar.visible = false;
		var newChar:Character = new Character(0,0,newCharName,targetChar.isPlayer).copyStatusFrom(targetChar);
		if (targetChar.iconSpr != null) targetChar.iconSpr.makeIcon(newChar.icon);
		targetChar.group.add(newChar);

		switch (type.toLowerCase().trim()) {
			case 'dad': dad = newChar;
			case 'girlfriend' | 'gf': gf = newChar;
			default: boyfriend = newChar;
		}
		cameraMovement();
	}

	public function showUI(bool:Bool):Void {
		var displayObjects:Array<Dynamic> = [iconGroup, scoreTxt, healthBar, healthBarBG, notesGroup, watermark];
		for (displayObject in displayObjects) displayObject.visible = bool;
	}
}