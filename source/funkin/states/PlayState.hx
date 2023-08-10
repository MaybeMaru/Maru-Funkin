package funkin.states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.ui.FlxBar;

class PlayState extends MusicBeatState {
	public static var game:PlayState;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:String = 'tutorial';
	public static var storyPlaylist:Array<String> = [];
	public static var curDifficulty:String = 'normal';
	public static var inChartEditor:Bool = false;

	public var inst:FlxSound;
	public var vocals:FlxSound;

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
	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var strumLine:FlxSprite;

	private var holdingArray:Array<Bool> = [false,false,false,false];
	private var controlArray:Array<Bool> = [false,false,false,false];
	private var releaseArray:Array<Bool> = [false,false,false,false];
	
	public var skipStrumIntro:Bool = false;
	public var skipCountdown:Bool = false;
	private var strumLineNotes:FlxTypedGroup<NoteStrum>;
	private var playerStrums:FlxTypedGroup<NoteStrum>;
	private var opponentStrums:FlxTypedGroup<NoteStrum>;

	private var strumLineInitPos:Array<FlxPoint> = [];
	private var playerStrumsInitPos:Array<FlxPoint> = [];
	private var opponentStrumsInitPos:Array<FlxPoint> = [];

	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	private var ratingGroup:RatingGroup;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var noteCount:Int = 0;
	private var noteTotal:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var healthBarBG:FunkinSprite;
	public var healthBar:FlxBar;

	private var iconGroup:FlxSpriteGroup;
	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	public var camGame:SwagCamera;
	public var camHUD:SwagCamera;
	public var camOther:SwagCamera;

	var songLength:Float = 0;
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
	public var inBotplay:Bool = false;
	public var inPractice:Bool = false;
	private var validScore:Bool = true;

	// Options stuff
	public var songSpeed:Float = 1.0;

	override public function create():Void {
		CoolUtil.clearCache();

		game = this;
		inBotplay = getPref('botplay');
		inPractice = getPref('practice');
		validScore = !(inBotplay || inPractice);
		ghostTapEnabled = getPref('ghost-tap');
		SkinUtil.initSkinData();

		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		camGame = new SwagCamera();
		camHUD = new SwagCamera();	 camHUD.bgColor.alpha = 0;
		camOther = new SwagCamera(); camOther.bgColor.alpha = 0;

		FlxG.cameras.add(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		SONG = Song.checkSong(SONG); //Double check null values
		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;
		Conductor.songOffset = SONG.offsets;
		songSpeed = getPref('use-const-speed') ? getPref('const-speed') : SONG.speed;

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

		//MAKE CHARACTERS
		gf = new Character(400, 360, SONG.players[2]);
		dad = new Character(100, 450,SONG.players[1]);
		boyfriend = new Character(770, 450, SONG.players[0], true);

		//Cache Gameover Character
		var deadChar:Character = new Character(0,0,boyfriend.gameOverChar);
		//add(deadChar);

		// GET THE STAGE JSON SHIT
		curStage = SONG.stage;
		stageJsonData = Stage.getJsonData(curStage);
		Paths.setCurrentLevel(stageJsonData.library);
		SkinUtil.setCurSkin(stageJsonData.skin);
		NoteUtil.initTypes();

		//ADD CHARACTER OFFSETS
		loadCharPos('bf');
		loadCharPos('dad');
		loadCharPos('gf');

		//STAGE START CAM OFFSET
		var camPos:FlxPoint = new FlxPoint();
		camPos.x -= stageJsonData.startCamOffsets[0];
		camPos.y -= stageJsonData.startCamOffsets[1];
		
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

		ModdingUtil.addCall('create');

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

		//Strums
		strumLine = new FlxSprite(0, !getPref('downscroll') ? 50 : FlxG.height - 150).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		strumLineNotes = new FlxTypedGroup<NoteStrum>();
		add(strumLineNotes);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		add(grpNoteSplashes);
		playerStrums = new FlxTypedGroup<NoteStrum>();
		opponentStrums = new FlxTypedGroup<NoteStrum>();

		generateStaticArrows(0);
		generateStaticArrows(1);
		//NoteUtil.setSwag(strumLineNotes.members);

		//Make Song
		Conductor.songPosition = -5000;
		generateSong();

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
		camGame.focusOn(camFollow.getPosition());

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

		watermark = new FunkinSprite('skins/${SkinUtil.curSkin}/watermark', [FlxG.width, FlxG.height], [0,0]);
		for (i in ['botplay', 'practice']) watermark.addAnim(i, i.toUpperCase(), 24, true);
		if (watermark.visible = !validScore) watermark.playAnim(inBotplay ? 'botplay' : 'practice');
		watermark.setScale(SkinUtil.curSkinData.scale * 0.7);
		watermark.x -= watermark.width * 1.2; watermark.y -= watermark.height * 1.2;
		watermark.alpha = 0.8;
		add(watermark);

		for (i in [grpNoteSplashes, strumLineNotes, notes, healthBar, healthBarBG, iconGroup, scoreTxt, watermark])
			i.cameras = [camHUD];

		startingSong = true;
		ModdingUtil.addCall('createPost');
		inCutscene ? ModdingUtil.addCall('startCutscene', [false]) : startCountdown();

		super.create();
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

		//Intro Strum anim
		if (!skipStrumIntro) {
			for (strum in strumLineNotes)
				FlxTween.tween(strum, {y: strumLine.y, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * strum.noteData)});
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

		startTimer = new FlxTimer().start(Conductor.crochet * 0.001, function(tmr:FlxTimer) {
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
				FlxTween.tween(countdownSpr, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){countdownSpr.destroy();}});
			}

			CoolUtil.playSound('skins/$introSkin/intro${['3','2','1','Go'][swagCounter]}', 0.6);
			swagCounter++;
		}, Conductor.BEATS_LENGTH);
	}

	function startSong():Void {
		camZooming = true;
		startingSong = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		ModdingUtil.addCall('startSong');

		if (!paused) {
			inst.play(false, Conductor.songOffset[0]);
			vocals.play(false, Conductor.songOffset[1]);
		}

		Conductor.setPitch(Conductor.songPitch);

		// Song duration in a float, useful for the time left feature
		songLength = inst.length;
		#if cpp // Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, '${SONG.song} (${curDifficulty})', iconRPC, true, songLength);
		#end
	}

	var songNotetypes:Array<String> = [];

	private function generateSong():Void {
		var songData:SwagSong = SONG;
		ModdingUtil.addCall('generateSong', [songData]);

		inst = new FlxSound().loadEmbedded(Paths.inst(songData.song));
		FlxG.sound.list.add(inst);
	
		var vocalsPath:String = Paths.voices(songData.song, true);
		vocals = (Paths.exists(vocalsPath, MUSIC)) ? new FlxSound().loadEmbedded(Paths.voices(songData.song)) : new FlxSound();
		FlxG.sound.list.add(vocals);
	
		unspawnNotes = [];
		notes = new FlxTypedGroup<Note>();
		add(notes);
	
		var noteData:Array<SwagSection> = songData.notes;
		curSong = songData.song;
		Conductor.bpm = songData.bpm;
	
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var strumTime:Int = songNotes[0];
				var noteData:Int = Std.int(songNotes[1] % Conductor.NOTE_DATA_LENGTH);
				var sustainLength = songNotes[2];
				var noteType:String = NoteUtil.getTypeName(songNotes[3]);
				var mustPress:Bool = section.mustHitSection ? songNotes[1] < Conductor.NOTE_DATA_LENGTH : songNotes[1] >= Conductor.NOTE_DATA_LENGTH;
				var targetStrum = mustPress ? playerStrums.members[noteData] : opponentStrums.members[noteData];
				
				var skin = NoteUtil.getTypeJson(noteType).skin;
				skin = skin == null ? SkinUtil.curSkin : skin;

				// Add note
				var newNote:Note = new Note(noteData, strumTime, 0, skin);
				newNote.noteSpeed = songSpeed;
				newNote.targetSpr = targetStrum;
				newNote.mustPress = mustPress;
				newNote.noteType = noteType;
				unspawnNotes.push(newNote);

				// Add note sustain
				if (sustainLength > 0) {
					var newSustain:Note = new Note(noteData, strumTime, sustainLength, skin);
					newSustain.noteSpeed = songSpeed;
					newSustain.targetSpr = targetStrum;
					newSustain.mustPress = mustPress;
					newSustain.noteType = noteType;
					newSustain.parentNote = newNote;
					unspawnNotes.push(newSustain);
				}

				//	Add notetype for scripts
				if (!songNotetypes.contains(noteType)) {	
					songNotetypes.push(noteType);
				}
			}
		}

		unspawnNotes.sort(function(Obj1:Note, Obj2:Note):Int {
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
		});
		
		//Notetype Scripts
		var notetypeScripts:Array<String> = ModdingUtil.getScriptList('data/notetypes');
		for (script in notetypeScripts) {
			if (songNotetypes.contains(script.split('.hx')[0].split('notetypes/')[1])) {
				ModdingUtil.addScript(script);
			}
		}

		FlxG.bitmap.clearUnused();
		generatedMusic = true;
	}

	private function generateStaticArrows(player:Int):Void {
		var startX:Float = NoteUtil.swagWidth * 0.666 + (FlxG.width / 2) * player;
		var startY:Float = strumLine.y;
		var offsetY:Float = getPref('downscroll') ? 10 : -10;
		var isPlayer = player == 1;
		
		for (i in 0...Conductor.NOTE_DATA_LENGTH) {
			var strumX:Float = startX + (NoteUtil.swagWidth + 5) * i;
			var babyArrow:NoteStrum = new NoteStrum(strumX, startY, i);
			babyArrow.ID = i;
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			strumLineNotes.add(babyArrow);
			strumLineInitPos.push(babyArrow.getPosition());
			(isPlayer ? playerStrums : opponentStrums).add(babyArrow);
			(isPlayer ? playerStrumsInitPos : opponentStrumsInitPos).push(babyArrow.getPosition());
			
			if (!skipStrumIntro) {
				babyArrow.alpha = 0;
				babyArrow.y += offsetY;
			}

			ModdingUtil.addCall('generateStaticArrow', [babyArrow]);
		}
	}

	private function openPauseSubState(easterEgg:Bool = false):Void {
		if (!paused) {
			paused = true;
			persistentUpdate = false;
			persistentDraw = true;
			camGame.followLerp = 0;
			if (!startingSong) {
				inst.pause();
				vocals.pause();
			}
			
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) { if (!tmr.finished) tmr.active = false; });
			FlxTween.globalManager.forEach(function(twn:FlxTween) { if (!twn.finished) twn.active = false; });
			CoolUtil.pauseSounds();
	
			openSubState((easterEgg && FlxG.random.bool(0.1)) ? new funkin.substates.GitarooPauseSubState() : new PauseSubState());
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
				Conductor.sync(inst,vocals);
				inst.play();
				vocals.play();
			}

			#if cpp
			var presenceDetails = '${SONG.song} ($curDifficulty)';
			var presenceTime = songLength - Conductor.songPosition;
			DiscordClient.changePresence(detailsText, presenceDetails, iconRPC, Conductor.songPosition >= 0, presenceTime);
			#end
		}
		super.closeSubState();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
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
			FlxG.switchState(new ChartingState());
			#if cpp DiscordClient.changePresence("Chart Editor", null, null, true); #end
		} else if (FlxG.keys.justPressed.EIGHT) {
			SkinUtil.setCurSkin('default');
			FlxG.switchState(new AnimationDebug(SONG.players[1]));
			#if cpp DiscordClient.changePresence("Character Editor", null, null, true); #end
		} else if (getKey('PAUSE-P') && startedCountdown && canPause) {
			openPauseSubState(true);
			#if cpp DiscordClient.changePresence(detailsPausedText, '${SONG.song} (${curDifficulty})', iconRPC); #end
		}

		//Makes the conductor song go vroom vroom
		if ((startingSong || inst.playing || Conductor.songPosition < songLength) && !inCutscene) {
			Conductor.songPosition += FlxG.elapsed * 1000;
			if (startedCountdown && startingSong) {
				if (Conductor.songPosition >= 0) {
					startSong();
				}
			}
			else if (!paused) {
				if (!inst.playing) inst.play();
				if (!vocals.playing) vocals.play();
			}
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
	
				inst.stop();
				vocals.stop();
	
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if cpp // Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence('Game Over - $detailsText', '${SONG.song} (${curDifficulty})', iconRPC);
				#end
			}
		}

		if (unspawnNotes[0] != null) {
			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < 1500 / songSpeed) {
				var dunceNote:Note = unspawnNotes[0];
				ModdingUtil.addCall('noteSpawn', [dunceNote]);
				notes.add(dunceNote);
				dunceNote.update(elapsed);
				notes.sort(function (order:Int, note1:Note, note2:Note):Int {
					if (note1.strumTime == note2.strumTime) {
						if (note1.isSustainNote && !note2.isSustainNote) return -1;
						if (!note1.isSustainNote && note2.isSustainNote) return 1;
					}
					return FlxSort.byValues(order, note1.strumTime, note2.strumTime);
				}, FlxSort.DESCENDING);
				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}
		}

		if (generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				// Manage botplay notes
				if (inBotplay) {
					if (daNote.mustPress) {
						if (Conductor.songPosition >= daNote.strumTime && daNote.mustHit) {
							if (daNote.isSustainNote) {
								daNote.pressed = daNote.inSustain;
								if (daNote.pressed) goodSustainPress(daNote);
							} else {
								daNote.strumTime = Conductor.songPosition; // force sick rating (because lag)
								goodNoteHit(daNote);
							}
						}
					}
				}

				// Manage opponent notes
				if (!daNote.mustPress) {
					if (Conductor.songPosition >= daNote.strumTime && daNote.mustHit) {
						if (daNote.isSustainNote) {
							daNote.pressed = daNote.inSustain ;
							if (daNote.pressed) opponentSustainPress(daNote);
						} else  opponentNoteHit(daNote);
					}
				}

				//Remove missed Notes
				if (!daNote.active) {
					if (daNote.mustPress && daNote.mustHit) {
						noteMiss(daNote.noteData%Conductor.NOTE_DATA_LENGTH, daNote);
					}
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});

			if (inst.playing) {
				if (Conductor.songPosition - SONG.offsets[1] >= vocals.length) { // Prevent repeating vocals
					vocals.volume = 0;
				}
			}
		}

		if (!inCutscene)
			keyShit();

		if (FlxG.keys.justPressed.ONE && CoolUtil.debugMode)
			endSong();

		ModdingUtil.addCall('updatePost', [elapsed]);
	}
	
	public function cameraMovement():Void {
		if (!generatedMusic || curSectionData == null) return;
		
		var mustHit:Bool = curSectionData.mustHitSection;
		var dadMidpointX:Float = dad.getMidpoint().x;
		var bfMidpointX:Float = boyfriend.getMidpoint().x;
		var intendedPos:Float = mustHit ? bfMidpointX - boyfriend.camOffsets.x - stageJsonData.bfCamOffsets[0] : dadMidpointX - dad.camOffsets.x - stageJsonData.dadCamOffsets[0];
		var camOffsets:Array<Int> = mustHit ? stageJsonData.bfCamOffsets : stageJsonData.dadCamOffsets;
		
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
		inst.volume = 0;
		vocals.volume = 0;
		ModdingUtil.addCall('endSong');
		if (validScore) Highscore.saveSongScore(SONG.song, curDifficulty, songScore);

		if (inChartEditor) {
			FlxG.switchState(new ChartingState());
			#if cpp DiscordClient.changePresence("Chart Editor", null, null, true); #end
		}
		else {
			if (isStoryMode) {
				campaignScore += songScore;
				storyPlaylist.remove(storyPlaylist[0]);
		
				if (storyPlaylist.length <= 0)	endWeek();
				else							inCutscene ? ModdingUtil.addCall('startCutscene', [true]) : switchSong();
			}
			else {
				trace('WENT BACK TO FREEPLAY??');
				SkinUtil.setCurSkin('default');
				FlxG.switchState(new FreeplayState());
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

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		SkinUtil.setCurSkin('default');
		FlxG.switchState(new StoryMenuState());
	}

	function switchSong():Void {
		trace('LOADING NEXT SONG [${PlayState.storyPlaylist[0]}-$curDifficulty]');

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		prevCamFollow = camFollow;

		PlayState.SONG = Song.loadFromFile(curDifficulty, PlayState.storyPlaylist[0]);
		inst.stop();
		vocals.stop();

		LoadingState.loadAndSwitchState(new PlayState());
	}

	private function popUpScore(strumtime:Float, daNote:Note):Void {
		vocals.volume = 1;
		noteCount++;

		ModdingUtil.addCall('popUpScore', [daNote]);

		var score:Int = 0;
		var setupSplash:Bool = false;
		var daRating:String = CoolUtil.getNoteJudgement(CoolUtil.getNoteDiff(daNote));

		switch (daRating) {
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
				noteTotal+=0.3;
				health -= ghostTapEnabled ? 0.1 : 0;
		}

		songScore += score;

		if (setupSplash) {
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData, daNote);
			grpNoteSplashes.add(splash);
		}

		if (!getPref('stack-rating')) {
			for (rating in ratingGroup)
				rating.kill();
		}
		
		ratingGroup.drawComplete(daRating, combo);
		updateScore();
	}

	private function keyShit():Void {
		holdingArray = [false,false,false,false]; controlArray = [false,false,false,false]; releaseArray = [true,true,true,true];
		if (!inBotplay) {
			holdingArray = [getKey('NOTE_LEFT'), 	getKey('NOTE_DOWN'),	getKey('NOTE_UP'),   getKey('NOTE_RIGHT')];
			controlArray = [getKey('NOTE_LEFT-P'), 	getKey('NOTE_DOWN-P'),	getKey('NOTE_UP-P'), getKey('NOTE_RIGHT-P')];
			releaseArray = [getKey('NOTE_LEFT-R'), 	getKey('NOTE_DOWN-R'),	getKey('NOTE_UP-R'), getKey('NOTE_RIGHT-R')];
		}

		if (generatedMusic) {
			var possibleNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];
			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote) { // Handle sustain notes
					daNote.pressed = holdingArray[daNote.noteData] && daNote.inSustain && daNote.mustPress;
					if (daNote.pressed)
						goodSustainPress(daNote);
				}
				else { // Handle normal notes
					if (controlArray.contains(true)) {
						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
							if (ignoreList.contains(daNote.noteData)) {
								for (possibleNote in possibleNotes) {
									if (possibleNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - possibleNote.strumTime) < 10) {
										removeList.push(daNote);
									}
									else if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime) {
										possibleNotes.remove(possibleNote);
										possibleNotes.push(daNote);
									}
								}
							}
							else {
								possibleNotes.push(daNote);
								ignoreList.push(daNote.noteData);
							}
						}
					}
				}
			});

			if (controlArray.contains(true)) {
				for (badNote in removeList) {
					badNote.kill();
					notes.remove(badNote, true);
					badNote.destroy();
				}
		
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (possibleNotes.length > 0) {
					for (i in 0...controlArray.length) {
						if (controlArray[i] && !ignoreList.contains(i)) badNoteHit();
					}
					for (possibleNote in possibleNotes) {
						if (controlArray[possibleNote.noteData]) goodNoteHit(possibleNote);
					}
				}
				else {
					badNoteHit();
				}
			}
		}

		checkPlayerStrumAnims();
	}

	function checkPlayerStrumAnims():Void {
		if (!inBotplay) {
			for (strum in playerStrums) {
				var strumAnim = strum.animation.curAnim;
				if (strumAnim != null) {
					if (controlArray[strum.noteData] && !strumAnim.name.startsWith('confirm'))
						strum.playStrumAnim('pressed');
					if (!holdingArray[strum.noteData])
						strum.playStrumAnim('static');
				}
			}

			var overSinging:Bool = (boyfriend.holdTimer > (Conductor.stepCrochet*Conductor.STEPS_LENGTH*0.001)
			&& boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'));

			if (overSinging) {
				var isHolding:Bool = false;
				for (strum in playerStrums) {
					if (strum.animation.curAnim.name.startsWith('confirm')) {
						isHolding = true;
						break;
					}
				}
				if (!isHolding)
					boyfriend.dance();
			};
		}
	}
	
	function noteMiss(direction:Int = 1, ?noteMissed:Note):Void {
		if (!boyfriend.stunned) {
			if (noteMissed == null) {
				health -= 0.04;
				songScore -= 10;
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
				ModdingUtil.addCall('badNoteHit', [direction]);
			}
			else {
				if (combo >= 5) gf.playAnim('sad');

				combo = 0;
				vocals.volume = 0;
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
		}
		updateScore();
	}
	
	function badNoteHit():Void {
		for (i in 0...controlArray.length) {
			if (controlArray[i] && !ghostTapEnabled)
				noteMiss(i);
		}
	}

	function goodSustainPress(note:Note) {
		health += note.hitHealth[1] * (FlxG.elapsed * 5);
		boyfriend.holdTimer = 0;
		boyfriend.sing(note.noteData, note.altAnim, false);
		vocals.volume = 1;

		if (inBotplay) 	{
			playStrumAnim(note.noteData+Conductor.NOTE_DATA_LENGTH, 'confirm');
			note.setSusPressed();
		}
		else playerStrums.members[note.noteData].playStrumAnim('confirm', true);

		ModdingUtil.addCall('goodSustainPress', [note]);
	}
	
	function goodNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			health += note.hitHealth[0];
			boyfriend.holdTimer = 0;
			boyfriend.sing(note.noteData, note.altAnim);

			if (inBotplay) 	playStrumAnim(note.noteData+Conductor.NOTE_DATA_LENGTH, 'confirm');
			else 			playerStrums.members[note.noteData].playStrumAnim('confirm', true);

			note.wasGoodHit = true;
			vocals.volume = 1;
			combo++;
			popUpScore(note.strumTime, note);
			ModdingUtil.addCall('goodNoteHit', [note]);

			notes.remove(note, true);
			note.destroy();
		}
	}

	function opponentSustainPress(note:Note):Void {
		dad.sing(note.noteData, note.altAnim, false);
		dad.holdTimer = 0;
		vocals.volume = 1;

		if (!getPref('vanilla-ui')) playStrumAnim(note.noteData%Conductor.NOTE_DATA_LENGTH);
		note.setSusPressed();

		ModdingUtil.addCall('opponentSustainPress', [note]);
	}

	function opponentNoteHit(note:Note):Void {
		dad.sing(note.noteData, note.altAnim);
		dad.holdTimer = 0;
		vocals.volume = 1;

		if (!getPref('vanilla-ui')) playStrumAnim(note.noteData%Conductor.NOTE_DATA_LENGTH);

		ModdingUtil.addCall('opponentNoteHit', [note]);

		notes.remove(note, true);
		note.destroy();
	}

	override function stepHit():Void {
		super.stepHit();
		Conductor.autoSync(inst,vocals);
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
		if (FlxG.sound.music != null)	FlxG.sound.music.stop();
		FlxG.sound.music = null;
		ModdingUtil.addCall('destroy');
		CoolUtil.clearCache();
		super.destroy();
	}

	private function playStrumAnim(data:Int = 0, anim:String = 'confirm', forced:Bool = true):Void {
		var leStrum:NoteStrum = strumLineNotes.members[data];
		if (leStrum != null) {
			leStrum.playStrumAnim(anim, forced);
			leStrum.staticTime = Conductor.stepCrochet/1000;
		}
	}

	private function loadCharPos(char:String):Void {
		var targetChar:Character = boyfriend;
		var targetOffsets:Array<Int> = stageJsonData.bfOffsets;
		switch (char.toLowerCase().trim()) {
			case 'dad': 				targetOffsets = stageJsonData.dadOffsets; targetChar = dad;
			case 'girlfriend' | 'gf': 	targetOffsets = stageJsonData.gfOffsets; targetChar = gf;
		}
		targetChar.x -= targetOffsets[0];
		targetChar.y -= targetOffsets[1];
	}
	
	private function switchChar(type:String, newCharName:String):Void {
		var targetChar:Character = boyfriend;
		var targetOffsets:Array<Int> = stageJsonData.bfOffsets;
		var targetGroup:FlxTypedSpriteGroup<Dynamic> = boyfriendGroup;
		switch (type.toLowerCase().trim()) {
			case 'dad':					targetOffsets = stageJsonData.dadOffsets; targetChar = dad; targetGroup = dadGroup;
			case 'girlfriend' | 'gf': 	targetOffsets = stageJsonData.gfOffsets; targetChar = gf; targetGroup = gfGroup;
		}

		var lastAnim:Null<String> = (targetChar.animation.curAnim != null) ? targetChar.animation.curAnim.name : null;
		var lastFrame:Int = (lastAnim != null) ? targetChar.animation.curAnim.curFrame : 0;
		var lastPos:Array<Float> = [targetChar.OG_X + targetOffsets[0], targetChar.OG_Y + targetOffsets[1]];

		targetChar.visible = false;
		var newChar:Character = new Character(lastPos[0], lastPos[1], newCharName, true);
		if (lastAnim != null) newChar.playAnim(lastAnim, true, false, lastFrame);
		targetGroup.add(newChar);

		switch (type.toLowerCase().trim()) {
			case 'dad': 				iconP2.makeIcon(newChar.icon); dad = newChar;
			case 'girlfriend' | 'gf': 	gf = newChar;
			default: 					iconP1.makeIcon(newChar.icon); boyfriend = newChar;
		}
		loadCharPos(type);
		cameraMovement();
	}

	public function showUI(bool:Bool):Void {
		var displayObjects:Array<Dynamic> = [iconGroup, scoreTxt, healthBar, healthBarBG, strumLineNotes, grpNoteSplashes, notes];
		for (displayObject in displayObjects) displayObject.visible = bool;
	}
}