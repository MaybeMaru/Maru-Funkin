package funkin.states;

import funkin.objects.NotesGroup;
import flixel.ui.FlxBar;

class PlayState extends MusicBeatState {
	public static var game:PlayState;
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
	public var strumLine(get,never):FlxSprite; function get_strumLine()return notesGroup.strumLine;
	public var holdingArray(get,never):Array<Bool>; function get_holdingArray()return notesGroup.holdingArray;
	public var controlArray(get,never):Array<Bool>; function get_controlArray()return notesGroup.controlArray;
	public var strumLineNotes(get,never):FlxTypedGroup<NoteStrum>; function get_strumLineNotes()return notesGroup.strumLineNotes;
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

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var noteCount:Int = 0;
	private var noteTotal:Float = 0;

	private var healthBarBG:FunkinSprite;
	public var healthBar:FlxBar;

	private var iconGroup:FlxSpriteGroup;
	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	public var camGame:SwagCamera;
	public var camHUD:SwagCamera;
	public var camOther:SwagCamera;

	public var songLength:Float = 0;
	var songScore:Int = 0;
	var songMisses:Int = 0;
	var scoreTxt:FunkinText;
	var watermark:FunkinSprite;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;
	var defaultCamSpeed:Float = 1;
	var camFollowLerp:Float = 0.04;

	public var inCutscene:Bool = false;
	public var inDialogue:Bool = true;
	public var dialogueBox:DialogueBoxBase = null;

	#if cpp	// Discord RPC variables
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var ghostTapEnabled:Bool = false;
	public var inPractice:Bool = false;
	private var validScore:Bool = true;
	
	public var pauseSubstate:PauseSubState;

	override public function create():Void {
		clearCache ? CoolUtil.clearCache(clearCacheData) : FlxG.bitmap.clearUnused();
		clearCache = true;
		clearCacheData = null;

		game = this;
		inPractice = getPref('practice');
		validScore = !(getPref('botplay') || inPractice);
		ghostTapEnabled = getPref('ghost-tap');
		SkinUtil.initSkinData();

		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		FlxG.camera.active = false;
		FlxG.camera.visible = false;
		FlxG.mouse.visible = false;
		
		camGame = new SwagCamera();
		camHUD = new SwagCamera();	 camHUD.bgColor.alpha = 0;
		camOther = new SwagCamera(); camOther.bgColor.alpha = 0;

		FlxG.cameras.add(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		SONG = Song.checkSong(SONG);

		#if cpp
		detailsText = isStoryMode ? 'Story Mode: ${storyWeek.toUpperCase()}' : 'Freeplay';
		detailsPausedText = 'Paused - $detailsText';
		if (Character.getCharData(SONG.players[1]) != null) {
			iconRPC = Character.getCharData(SONG.players[1]).icon;
		}
		DiscordClient.changePresence(detailsText, '${SONG.song} ($curDifficulty)', iconRPC);
		#end

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
		//add(deadChar);

		// GET THE STAGE JSON SHIT
		curStage = SONG.stage;
		stageJsonData = Stage.getJsonData(curStage);
		Paths.setCurrentLevel(stageJsonData.library);
		SkinUtil.setCurSkin(stageJsonData.skin);
		NoteUtil.initTypes();

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
		ModdingUtil.addScript(Paths.script('stages/$curStage'));

		//Character Scripts
		var characterScripts:Array<String> = ModdingUtil.getScriptList('data/characters');
		if (characterScripts.length > 0) {
			for (char in [PlayState.game.boyfriend,PlayState.game.dad,PlayState.game.gf]) {
				for (i in 0...characterScripts.length) {
					var charParts = characterScripts[i].toLowerCase().split('/');
					var charName:String = charParts[charParts.length-1].split('.')[0];

					if (char.curCharacter == charName) {
						ModdingUtil.addScript(characterScripts[i]).set('ScriptChar', char);
						break;
					}
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

		// Setup functions
		notesGroup.goodNoteHit = function (note:Note) {
			if (note.wasGoodHit) return;

			health += note.hitHealth[0];
			boyfriend.sing(note.noteData, note.altAnim);
			notesGroup.inBotplay ? notesGroup.playStrumAnim(note.noteData+Conductor.NOTE_DATA_LENGTH, 'confirm') :
						notesGroup.playerStrums.members[note.noteData].playStrumAnim('confirm', true);

			note.wasGoodHit = true;
			Conductor.vocals.volume = 1;
			combo++;
			popUpScore(note.strumTime, note);
			ModdingUtil.addCall('goodNoteHit', [note]);
			ModdingUtil.addCall('noteHit', [note, true]);
			notesGroup.removeNote(note);
		}

		notesGroup.goodSustainPress = function (note:Note) {
			health += note.hitHealth[1] * (FlxG.elapsed * 5);
			boyfriend.sing(note.noteData, note.altAnim, false);
			Conductor.vocals.volume = 1;
	
			if (notesGroup.inBotplay) 	{
				notesGroup.playStrumAnim(note.noteData+Conductor.NOTE_DATA_LENGTH, 'confirm');
				note.setSusPressed();
			}
			else notesGroup.playerStrums.members[note.noteData].playStrumAnim('confirm', true);
	
			ModdingUtil.addCall('goodSustainPress', [note]);
			ModdingUtil.addCall('sustainPress', [note, true]);
		}

		notesGroup.noteMiss = function(direction:Int = 1, ?noteMissed:Note):Void {
			if (noteMissed == null) {
				health -= 0.04;
				songScore -= 10;
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
				ModdingUtil.addCall('badNoteHit', [direction]);
			}
			else {
				if (combo >= 5) gf.playAnim('sad');

				combo = 0;
				Conductor.vocals.volume = 0;
				var healthLoss = noteMissed.missHealth[noteMissed.isSustainNote ? 1 : 0];
				var healthMult:Float = noteMissed.isSustainNote ? noteMissed.percentCut * (noteMissed.initSusLength / Conductor.stepCrochet) : 1;
				health -= healthLoss * healthMult;
				songScore -= Std.int(10 * healthMult);

				noteCount++;
				songMisses++;
					
				ModdingUtil.addCall('noteMiss', [noteMissed]);
			}

			boyfriend.stunned = true;
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer) {
				boyfriend.stunned = false;
			});
	
			boyfriend.sing(direction, 'miss');
			updateScore();
		}

		notesGroup.badNoteHit = function () {
			for (i in 0...notesGroup.controlArray.length) {
				if (notesGroup.controlArray[i] && !ghostTapEnabled)
					notesGroup.checkCallback(notesGroup.noteMiss, [i]);
			}
		}

		notesGroup.opponentNoteHit = function (note:Note) {
			dad.sing(note.noteData, note.altAnim);
			Conductor.vocals.volume = 1;
	
			if (!getPref('vanilla-ui')) notesGroup.playStrumAnim(note.noteData%Conductor.NOTE_DATA_LENGTH);
	
			ModdingUtil.addCall('opponentNoteHit', [note]);
			ModdingUtil.addCall('noteHit', [note, false]);
			notesGroup.removeNote(note);
		}

		notesGroup.opponentSustainPress = function (note:Note) {
			dad.sing(note.noteData, note.altAnim, false);
			Conductor.vocals.volume = 1;
	
			if (!getPref('vanilla-ui')) notesGroup.playStrumAnim(note.noteData%Conductor.NOTE_DATA_LENGTH);
			note.setSusPressed();
	
			ModdingUtil.addCall('opponentSustainPress', [note]);
			ModdingUtil.addCall('sustainPress', [note, false]);
		}

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

		healthBarBG = new FunkinSprite('skins/${SkinUtil.curSkin}/healthBar', [0,0], [0,0]);
		healthBarBG.y = !getPref('downscroll') ? FlxG.height * 0.9 : FlxG.height * 0.1;
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 6, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 12),
		Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		iconGroup = new FlxSpriteGroup();
		add(iconGroup);

		iconP1 = new HealthIcon(boyfriend.icon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.playIcon = true;
		iconGroup.add(iconP1);

		iconP2 = new HealthIcon(dad.icon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.playIcon = true;
		iconGroup.add(iconP2);

		dad.iconSpr = iconP2;
		boyfriend.iconSpr = iconP1;

		scoreTxt = new FunkinText(healthBarBG.x, healthBarBG.y + 30);
		add(scoreTxt);

		if (getPref('vanilla-ui')) {
			scoreTxt.borderColor = FlxColor.TRANSPARENT;
			scoreTxt.setFormat(Paths.font('vcr'), 16, FlxColor.WHITE);
		}

		ratingGroup = new RatingGroup(boyfriend);
		add(ratingGroup);
		updateScore();

		watermark = new FunkinSprite('skins/${SkinUtil.curSkin}/watermark', [FlxG.width, getPref('downscroll') ? 0 : FlxG.height], [0,0]);
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

	function createDialogue():Void {
		showUI(false);
		ModdingUtil.addCall('createDialogue');
		
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		
		if(dialogueBox != null && dialogueBox.skipIntro) black.alpha = 0;
		switch (SkinUtil.curSkin) {
			case 'pixel':
				new FlxTimer().start(0.3, function(tmr:FlxTimer) {
					black.alpha -= 0.15;
					if (black.alpha > 0)	tmr.reset(0.3);
					else {
						quickDialogueBox();
						remove(black);
					}
				});
			default:
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
	}

	function quickDialogueBox():Void {
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

	private var startTimer:FlxTimer;

	function startCountdown():Void {
		showUI(true);
		inCutscene = false;
		inDialogue = false;
		startedCountdown = true;

		if (!notesGroup.skipStrumIntro) {
			for (strum in notesGroup.strumLineNotes)
				FlxTween.tween(strum, {y: notesGroup.strumLine.y, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * strum.noteData)});
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
		var introSkin:String = SkinUtil.curSkin;
		for (i in ['3','2','1','Go']) 	Paths.sound('skins/$introSkin/intro$i'); // Cache stuff
		for (i in ['ready','set','go']) Paths.image('skins/$introSkin/$i');

		startTimer = new FlxTimer().start(Conductor.crochetMills, function(tmr:FlxTimer) {
			ModdingUtil.addCall('startTimer', [swagCounter]);
			dad.dance();
			gf.dance();
			boyfriend.dance();
			iconP1.bumpIcon();
			iconP2.bumpIcon();

			if (swagCounter > 0) {
				var countdownSpr:FunkinSprite = new FunkinSprite('skins/$introSkin/${['ready','set','go'][swagCounter-1]}');
				countdownSpr.scale.set(SkinUtil.curSkinData.scale,SkinUtil.curSkinData.scale);
				countdownSpr.screenCenter();
				countdownSpr.cameras = [camHUD];
				add(countdownSpr);

				countdownSpr.acceleration.y = SONG.bpm*60;
				countdownSpr.velocity.y -= SONG.bpm*10;
				FlxTween.tween(countdownSpr, {alpha: 0}, Conductor.crochetMills, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){countdownSpr.destroy();}});
			}

			CoolUtil.playSound('skins/$introSkin/intro${['3','2','1','Go'][swagCounter]}', 0.6);
			swagCounter++;
		}, Conductor.BEATS_LENGTH);
	}

	public function startSong():Void {
		camZooming = true;
		startingSong = false;

		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		ModdingUtil.addCall('startSong');

		if (!paused) {
			Conductor.play();
			Conductor.sync();
		}

		Conductor.setPitch(Conductor.songPitch);
		Conductor.setVolume(1);

		// Song duration in a float, useful for the time left feature
		songLength = Conductor.inst.length;
		#if cpp // Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, '${SONG.song} (${curDifficulty})', iconRPC, true, songLength);
		#end
	}

	private function openPauseSubState(easterEgg:Bool = false):Void {
		if (!paused) {
			paused = true;
			persistentUpdate = false;
			persistentDraw = true;
			camGame.followLerp = 0;
			if (!startingSong) {
				Conductor.inst.pause();
				Conductor.vocals.pause();
			}
			
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished) twn.active = false);
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
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {	if (!tmr.finished)	tmr.active = true; });
			FlxTween.globalManager.forEach(function(twn:FlxTween) {	if (!twn.finished)	twn.active = true; });

			if (!startingSong) {
				Conductor.setPitch(Conductor.songPitch);
				Conductor.sync();
				Conductor.play();
			}

			#if cpp
			var presenceDetails = '${SONG.song} ($curDifficulty)';
			var presenceTime = songLength - Conductor.songPosition;
			DiscordClient.changePresence(detailsText, presenceDetails, iconRPC, Conductor.songPosition >= 0, presenceTime);
			#end
		}
		super.closeSubState();
	}

	public var paused:Bool = false;
	public var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function updateScore():Void {
		var songAccuracy:Null<Float> = (noteCount > 0) ? 0 : null;
		var songRating:String = '?';

		if (noteCount > 0) {
			songAccuracy = (noteTotal/noteCount)*100;
			songAccuracy = FlxMath.roundDecimal(songAccuracy, 2);
			songRating = Highscore.getAccuracyRating(songAccuracy).toUpperCase();
		}

		scoreTxt.text =
		'Score: $songScore / Accuracy: ${(noteCount > 0) ? '$songAccuracy%' : ''} [$songRating] / Misses: $songMisses';
		scoreTxt.x = healthBarBG.x + healthBarBG.width/2 - scoreTxt.width/2;

		if (getPref('vanilla-ui')) {
			scoreTxt.text = 'Score:$songScore';
			scoreTxt.setPosition(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30);
		}

		ModdingUtil.addCall('updateScore', [songScore]);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		ModdingUtil.addCall('update', [elapsed]);

		if (FlxG.keys.justPressed.NINE) {
			switch (iconP1.iconName) {
				case 'bf-old': 	 iconP1.makeIcon('bf-older'); 		iconP2.makeIcon('dad-older');
				case 'bf-older': iconP1.makeIcon(boyfriend.icon); 	iconP2.makeIcon(dad.icon);
				default: 		 iconP1.makeIcon('bf-old'); 		iconP2.makeIcon('dad');
			}
		} else if (FlxG.keys.justPressed.SEVEN) {
			clearCacheData = {sounds: false};
			switchState(new ChartingState());
			#if cpp DiscordClient.changePresence("Chart Editor", null, null, true); #end
		} else if (FlxG.keys.justPressed.EIGHT) {
			SkinUtil.setCurSkin('default');
			switchState(new AnimationDebug(SONG.players[1]));
			#if cpp DiscordClient.changePresence("Character Editor", null, null, true); #end
		} else if (getKey('PAUSE-P') && startedCountdown && canPause) {
			openPauseSubState(true);
			#if cpp DiscordClient.changePresence(detailsPausedText, '${SONG.song} (${curDifficulty})', iconRPC); #end
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

		if (health > 2) health = 2;
		else if (health <= 0) {
			health = 0;
			if (validScore) {
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
	
				Conductor.stop();
	
				deathCounter++;
				openSubState(new GameOverSubstate(boyfriend.OG_X, boyfriend.OG_Y));
				
				#if cpp // Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence('Game Over - $detailsText', '${SONG.song} (${curDifficulty})', iconRPC);
				#end
			}
		}

		if (FlxG.keys.justPressed.ONE && CoolUtil.debugMode)
			endSong();

		ModdingUtil.addCall('updatePost', [elapsed]);
	}

	public function snapCamera() {
		camGame.focusOn(camFollow.getPosition());
	}
	
	public function cameraMovement():Void {
		if (!notesGroup.generatedMusic || curSectionData == null) return;
		
		var mustHit:Bool = curSectionData.mustHitSection;
		var dadMidpointX:Float = dad.getMidpoint().x;
		var bfMidpointX:Float = boyfriend.getMidpoint().x;
		var intendedPos:Float = mustHit ? bfMidpointX - boyfriend.camOffsets.x - stageJsonData.bfCamOffsets[0] : dadMidpointX - dad.camOffsets.x - stageJsonData.dadCamOffsets[0];
		var camOffsets:Array<Float> = mustHit ? stageJsonData.bfCamOffsets : stageJsonData.dadCamOffsets;
		
		if (camFollow.x != intendedPos) {
			ModdingUtil.addCall('cameraMovement', [mustHit ? 1 : 0]);
			camFollow.setPosition(mustHit ? bfMidpointX : dadMidpointX, mustHit ? boyfriend.getMidpoint().y : dad.getMidpoint().y);
			camFollow.x -= mustHit ? boyfriend.camOffsets.x : dad.camOffsets.x;
			camFollow.y -= mustHit ? boyfriend.camOffsets.y : dad.camOffsets.y;
	
			camFollow.x -= camOffsets[0];
			camFollow.y -= camOffsets[1];
		}
	}

	function endSong():Void {
		canPause = false;
		deathCounter = 0;
		Conductor.setVolume(0);
		ModdingUtil.addCall('endSong');
		if (validScore) Highscore.saveSongScore(SONG.song, curDifficulty, songScore);
		CustomTransition.skipTrans = isStoryMode;

		if (inChartEditor) {
			switchState(new ChartingState());
			#if cpp DiscordClient.changePresence("Chart Editor", null, null, true); #end
		}
		else {
			if (isStoryMode) {
				campaignScore += songScore;
				storyPlaylist.remove(storyPlaylist[0]);
				inCutscene ? ModdingUtil.addCall('startCutscene', [true]) : (storyPlaylist.length <= 0 ? endWeek() : switchSong());
			}
			else {
				trace('WENT BACK TO FREEPLAY??');
				clearCache = true;
				SkinUtil.setCurSkin('default');
				switchState(new FreeplayState());
			}
		}
	}

	function endWeek() {
		if (validScore) {
			Highscore.saveWeekScore(storyWeek, curDifficulty, campaignScore);
			var weekData = WeekSetup.weekDataMap.get(storyWeek);
			if (WeekSetup.weekDataMap.exists(weekData.unlockWeek))
				Highscore.setWeekUnlock(weekData.unlockWeek, true);
		}

		ModdingUtil.addCall('endWeek');

		clearCache = true;
		SkinUtil.setCurSkin('default');
		CustomTransition.skipTrans = false;
		switchState(new StoryMenuState());
	}

	function switchSong():Void {
		trace('LOADING NEXT SONG [${PlayState.storyPlaylist[0]}-$curDifficulty]');

		prevCamFollow = camFollow;

		PlayState.SONG = Song.loadFromFile(curDifficulty, PlayState.storyPlaylist[0]);
		Conductor.stop();

		clearCache = false;
		NoteUtil.clearSustainCache(); // Clear last song note cache
		ModdingUtil.addCall('switchSong', [PlayState.storyPlaylist[0], curDifficulty]); // Could be used to activate cache clear
		LoadingState.loadAndSwitchState(new PlayState());
	}

	private function popUpScore(strumtime:Float, daNote:Note):Void {
		noteCount++;
		ModdingUtil.addCall('popUpScore', [daNote]);

		var score:Int = 0;
		var setupSplash:Bool = false;
		var noteRating:String = CoolUtil.getNoteJudgement(CoolUtil.getNoteDiff(daNote));

		switch (noteRating) {
			case 'sick':
				setupSplash = true;
				score = 350;
				noteTotal++;
			case 'good':
				score = 200;
				noteTotal+=0.8;
			case 'bad':
				score = 100;
				noteTotal+=0.5;
				health -= ghostTapEnabled ? 0.06 : 0;
			case 'shit':
				score = 50;
				noteTotal+=0.25;
				health -= ghostTapEnabled ? 0.1 : 0;
		}

		songScore += score;

		if (setupSplash) {
			var splash:NoteSplash = notesGroup.grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData, daNote);
			notesGroup.grpNoteSplashes.add(splash);
		}

		if (!getPref('stack-rating')) {
			for (rating in ratingGroup)
				rating.kill();
		}
		
		ratingGroup.drawComplete(noteRating, combo);
		updateScore();
	}

	override function stepHit():Void {
		super.stepHit();
		Conductor.autoSync();
		ModdingUtil.addCall('stepHit', [curStep]);
	}

	override public function beatHit():Void {
		super.beatHit();
		if (curSectionData != null) {
			if (curSectionData.changeBPM) {
				Conductor.bpm = curSectionData.bpm;
				FlxG.log.add('CHANGED BPM!');
			}
		}

		iconP1.bumpIcon();
		iconP2.bumpIcon();

		if (boyfriend.animation.curAnim != null) {
			if (!boyfriend.animation.curAnim.name.startsWith("sing")) 						boyfriend.dance();
		} if (dad.animation.curAnim != null) {
			if (!dad.animation.curAnim.name.startsWith("sing"))								dad.dance();
		} if (gf.animation.curAnim != null) {
			if (curBeat % gfSpeed == 0 && !gf.animation.curAnim.name.startsWith("sing"))	gf.dance();
		}

		ModdingUtil.addCall('beatHit', [curBeat]);
	}

	override public function sectionHit():Void {
		super.sectionHit();
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
		if (FlxG.sound.music != null)	FlxG.sound.music.stop();
		FlxG.sound.music = null;
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

		var lastAnim:Null<String> = (targetChar.animation.curAnim != null) ? targetChar.animation.curAnim.name : null;
		var lastFrame:Int = (lastAnim != null) ? targetChar.animation.curAnim.curFrame : 0;
		var targetIcon = targetChar.iconSpr;

		targetChar.visible = false;
		var newChar:Character = new Character(targetChar.OG_X, targetChar.OG_Y, newCharName, true);
		newChar.group = targetChar.group;
		newChar.iconSpr = targetChar.iconSpr;
		newChar.holdTimer = targetChar.holdTimer;
		newChar.specialAnim = targetChar.specialAnim;
		targetChar.stageOffsets.copyTo(newChar.stageOffsets);
		newChar.updatePosition();
		if (lastAnim != null) newChar.playAnim(lastAnim, true, false, lastFrame);
		if (targetIcon != null) targetIcon.makeIcon(newChar.icon);
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