package funkin.objects;

import haxe.ds.Vector;
import flixel.util.FlxSignal;
import funkin.objects.note.Sustain;
import funkin.objects.note.BasicNote;
import funkin.objects.note.StrumLineGroup;

class NotesGroup extends Group
{	
	public static var instance:NotesGroup;
    public var SONG:SwagSong;
	public var game:PlayState;
	public var boyfriend:Character;
	public var dad:Character;

    public static var songSpeed:Float = 1.0;
    public var curSong:String = 'test';
    public var songNotetypes:Array<String> = [];
	public var songEvents:Array<String> = [];

	public var generatedMusic:Bool = false;

    public var notes:TypedGroup<BasicNote>;
	public var unspawnNotes:Array<BasicNote> = [];
	public var events:Array<Event> = [];

    public var skipStrumIntro:Bool = false;

	public var strumLineNotes(get, never):Array<NoteStrum>;
	inline function get_strumLineNotes() return opponentStrums.members.concat(playerStrums.members);
	
	public var playerStrums:StrumLineGroup;
	public var opponentStrums:StrumLineGroup;
	public var grpNoteSplashes:SplashGroup;

	public var strumLineInitPos(get, never):Array<FlxPoint>;
	public function get_strumLineInitPos() return opponentStrums.initPos.concat(playerStrums.initPos);
	public var playerStrumsInitPos(get, never):Array<FlxPoint>;
	public function get_playerStrumsInitPos() return playerStrums.initPos;
	public var opponentStrumsInitPos(get, never):Array<FlxPoint>;
	public function get_opponentStrumsInitPos() return playerStrums.initPos;

    public var inBotplay(default,set):Bool = false;
	public var dadBotplay(default,set):Bool = true;
	public var isPlayState:Bool = true;

	public function set_inBotplay(value:Bool) {
		if (boyfriend != null) boyfriend.botMode = value;
		return inBotplay = value;
	}

	public function set_dadBotplay(value:Bool) {
		if (dad != null) dad.botMode = value;
		return dadBotplay = value;
	}

	public function spawnSplash(note:Note) {
		grpNoteSplashes.spawnSplash(note);
	}

	inline function hitNote(note:Note, character:Character, botplayCheck:Bool = false, prefBot:Bool = false) {
		note.wasGoodHit = true;
		if (note.child != null)
			note.child.startedPress = true;

		if (character != null) {
			character.sing(note.noteData, note.altAnim);
			Conductor.vocals.volume = 1;
		}

		if (!botplayCheck || prefBot) {
			if (isPlayState) game.health += note.hitHealth[0];
			final rating:String = isPlayState ? game.popUpScore(note.strumTime, note) :
			CoolUtil.getNoteJudgement(CoolUtil.getNoteDiff(note));
			if (rating == "sick") spawnSplash(note); // Spawn splash
		}

		botplayCheck ? if (!vanillaUI) playStrumAnim(note) :
		note.targetStrum.playStrumAnim('confirm', true);
	}

	function pressSustain(sustain:Sustain, character:Character, botplayCheck:Bool = false, prefBot:Bool = false) {
		if (!sustain.exists)
			return;
		
		if (character != null) {
			character.sing(sustain.noteData, sustain.altAnim, false);
			Conductor.vocals.volume = 1;
		}

		if (!botplayCheck || prefBot) {
			if (isPlayState)
				game.health += sustain.hitHealth[1] * (FlxG.elapsed * 5);
		}
		else sustain.pressSustain();

		botplayCheck ? if (!vanillaUI) playStrumAnim(sustain) :
		sustain.targetStrum.playStrumAnim('confirm', true);
	}

	public var vanillaUI:Bool = false;
    
    public function new(_SONG:SwagSong, isPlayState:Bool = true) {
        super();
		instance = this;
		game = isPlayState ? PlayState.instance : null;
		this.isPlayState = isPlayState;
        SONG = Song.checkSong(_SONG, null, false); //Double check null values
		curSong = SONG.song;

		if (isPlayState) {
			boyfriend = game.boyfriend;
			dad = game.dad;
		}

		initStrumline();
        
		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;
		Conductor.offset[0] = SONG.offsets[0] ?? 0;
		Conductor.offset[1] = SONG.offsets[1] ?? 0;
		Conductor.loadSong(curSong);
		
		songSpeed = getPref('use-const-speed') && isPlayState ? getPref('const-speed') : SONG.speed;
        inBotplay = getPref('botplay') && isPlayState;
		vanillaUI = getPref('vanilla-ui');

		goodNoteHit = new FlxTypedSignal<Note->Void>();
		goodSustainPress = new FlxTypedSignal<Sustain->Void>();
		
		noteMiss = new FlxTypedSignal<BasicNote->Void>();
		badNoteHit = new FlxTypedSignal<Int->Void>();
		
		opponentNoteHit = new FlxTypedSignal<Note->Void>();
		opponentSustainPress = new FlxTypedSignal<Sustain->Void>();
		
		// Setup functions
		goodNoteHit.add((note:Note) -> {
			if (note.wasGoodHit) return;
			hitNote(note, boyfriend, inBotplay, getPref("botplay"));
			ModdingUtil.addCall('goodNoteHit', [note]);
			ModdingUtil.addCall('noteHit', [note, true]);
			note.removeNote();
		});

		goodSustainPress.add((sustain:Sustain) -> {
			pressSustain(sustain, boyfriend, inBotplay, getPref("botplay"));
			ModdingUtil.addCall('goodSustainPress', [sustain]);
			ModdingUtil.addCall('sustainPress', [sustain, true]);
		});

		opponentNoteHit.add((note:Note) -> {
			if (note.wasGoodHit) return;
			hitNote(note, dad, dadBotplay);
			ModdingUtil.addCall('opponentNoteHit', [note]);
			ModdingUtil.addCall('noteHit', [note, false]);
			note.removeNote();
		});

		opponentSustainPress.add((sustain:Sustain) -> {
			pressSustain(sustain, dad, dadBotplay);
			ModdingUtil.addCall('opponentSustainPress', [sustain]);
			ModdingUtil.addCall('sustainPress', [sustain, false]);
		});

		if (!isPlayState) return;

		noteMiss.add((note:BasicNote) -> {
			if (game.combo > 4) game.gf.playAnim('sad');
			game.combo = 0;
				
			Conductor.vocals.volume = 0;
			final healthLoss = note.missHealth[note.isSustainNote ? 1 : 0];

			var healthMult = 1.0;
			if (note.isSustainNote) {
				final sus:Sustain = note.toSustain();
				healthMult = (sus.startedPress ? sus.percentLeft : 1) * (sus.susLength / Conductor.stepCrochet) * 4;
			}

			game.health -= healthLoss * healthMult;
			game.songScore -= Std.int(10 * healthMult);

			game.noteCount++;
			game.songMisses++;
					
			ModdingUtil.addCall('noteMiss', [note]);

			(note.mustPress ? boyfriend : game.dad).sing(note.noteData, "miss");
			
			game.updateScore();
		});

		badNoteHit.add((data:Int) -> {
			game.health -= 0.04;
			game.songScore -= 10;
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			ModdingUtil.addCall('badNoteHit', [data]);

			if (!inBotplay)
				boyfriend.sing(data, 'miss');

			if (!dadBotplay)
				dad.sing(data, 'miss');

			game.updateScore();
		});
    }

	function initStrumline() {
		StrumLineGroup.strumLineY = getPref('downscroll') ? FlxG.height - 150 : 50;
		
		opponentStrums = new StrumLineGroup(0);
		add(opponentStrums);
		
		playerStrums = new StrumLineGroup(1);
		add(playerStrums);

		grpNoteSplashes = new SplashGroup();
		add(grpNoteSplashes);
	}

	// Make the song
    public function init(startPos:Float = -5000) {
		Conductor.songPosition = startPos;
		generateSong();
    }

	private function generateSong():Void {
		ModdingUtil.addCall('generateSong', [SONG]);

		unspawnNotes = [];
		events = [];
		notes = new TypedGroup<BasicNote>();
		add(notes);

		// Prevent the need for pushing (in most songs)
		for (i in 0...15)
			notes.members.push(null);
	
		SONG.notes.fastForEach((section, i) ->
		{
			for (songNotes in section.sectionNotes)
			{
				var strumTime:Float = songNotes[0];
				var initNoteData:Int = songNotes[1];
				var susLength:Float = songNotes[2] ?? 0;
				
				if ((strumTime + susLength) < Conductor.songPosition) continue; // Save on creating missed notes
				if (initNoteData < 0) continue; // Negative notes arent supported

				var noteData:Int = initNoteData % Conductor.NOTE_DATA_LENGTH;
				var noteType:String = NoteUtil.getTypeName(songNotes[3]);
				var mustPress:Bool = section.mustHitSection ? initNoteData < Conductor.NOTE_DATA_LENGTH : initNoteData >= Conductor.NOTE_DATA_LENGTH;
				var targetStrum:NoteStrum = mustPress ? playerStrums.members[noteData] : opponentStrums.members[noteData];
				var skin:String = NoteUtil.getTypeJson(noteType)?.skin ?? SkinUtil.curSkin;

				var note:Note = new Note(noteData, strumTime, skin);
				note.targetStrum = targetStrum;
				note.mustPress = mustPress;
				note.noteType = noteType;
				note.noteSpeed = songSpeed;
				unspawnNotes.push(note);

				if (susLength > 0) {
					var sustain:Sustain = new Sustain(noteData, strumTime, susLength, skin, note);
					sustain.noteSpeed = songSpeed;
					
					// Too short sustains shouldnt be added
					if (sustain.alive) {
						sustain.targetStrum = targetStrum;
						sustain.mustPress = mustPress;
						sustain.noteType = noteType;
						unspawnNotes.push(sustain);

						note.child = sustain;
					}
				}

				//	Add notetype for scripts
				if (!songNotetypes.contains(noteType)) {	
					songNotetypes.push(noteType);
				}
			}

			section.sectionEvents.fastForEach((e, i) -> {
				var strumTime:Float = e[0];
				var eventName:String = e[1];
				var eventValues:Array<Dynamic> = e[2];
				
				events.push(new Event(strumTime, eventName, eventValues));

				//	Add event for scripts
				if (!songEvents.contains(eventName)) {
					songEvents.push(eventName);
				}
			});
		});

		scrollSpeed = songSpeed;

		unspawnNotes.sort((a:BasicNote, b:BasicNote) -> return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime));
		events.sort((a:Event, b:Event) -> return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime));

		curSpawnNote = unspawnNotes[0];
		curCheckEvent = events[0];
		
		if (isPlayState)
		{
			//Notetype Scripts
			ModdingUtil.getSubFolderScriptList('data/notetypes', [curSong]).fastForEach((script, i) -> {
				if (songNotetypes.contains(script.split('.hx')[0].split('notetypes/')[1]))
					ModdingUtil.addScript(script);
			});
			
			//Event Scripts
			ModdingUtil.getSubFolderScriptList('data/events', [curSong]).fastForEach((script, i) -> {
				if (songEvents.contains(script.split('.hx')[0].split('events/')[1]))
					ModdingUtil.addScript(script);
			});
		}

		FlxG.bitmap.clearUnused();
		generatedMusic = true;
	}

	public var scrollSpeed(default, set):Float = 1.0; // Shortcut to change all notes scroll speed
	public function set_scrollSpeed(value:Float = 1.0) {
		if (value != scrollSpeed)
		{
			unspawnNotes.fastForEach((note, i) -> note.noteSpeed = value);

			notes.members.fastForEach((note, i) -> {
				if (note != null)
					note.noteSpeed = value;
			});
			
			if (value < scrollSpeed)
				spawnNotes();
		}
		return scrollSpeed = value;
	}

    public var goodNoteHit:FlxTypedSignal<Note->Void>;
    public var goodSustainPress:FlxTypedSignal<Sustain->Void>;
    
	public var noteMiss:FlxTypedSignal<BasicNote->Void>;
    public var badNoteHit:FlxTypedSignal<Int->Void>;
    
    public var opponentNoteHit:FlxTypedSignal<Note->Void>;
    public var opponentSustainPress:FlxTypedSignal<Sustain->Void>;

    //Makes the conductor song go vroom vroom
    inline function updateConductor(elapsed:Float)
	{
		if (isPlayState)
		{
			// Prevent repeating vocals
			if (Conductor.inst.playing) {
				if (Conductor.songPosition - SONG.offsets[1] >= Conductor.vocals.length)
					Conductor.vocals.volume = 0;
			}

			final inStart:Bool = game.startingSong;
			if (!game.inCutscene) if ((Conductor.playing || inStart || Conductor.songPosition < game.songLength))
			{
				Conductor.update(elapsed);
				if (game.startedCountdown) if (inStart) {
					if (Conductor.songPosition >= 0)
						game.startSong();
				}
				else
				{
					if (!game.paused) if (!Conductor.inst.playing)
						Conductor.play();
				}
			}
		}
		else
		{
			Conductor.update(elapsed);
			if (!Conductor.inst.playing) Conductor.play();
			if (Conductor.songPosition % Conductor.stepCrochet <= 5)
				Conductor.autoSync();
		}
    }

	public var curSpawnNote(default, null):BasicNote;

	inline function spawnNotes():Void { // Generate notes
		if (curSpawnNote != null) {
			final zoom = 1 / camera.zoom;
			
			while (unspawnNotes.length > 0 &&
				((curSpawnNote.strumTime - Conductor.songPosition) < (((1500 / curSpawnNote.calcSpeed()) * zoom) * curSpawnNote.spawnMult)))
			{
				curSpawnNote.update(0.0);
				ModdingUtil.addCall('noteSpawn', [curSpawnNote]);

				// Skip sorting
				curSpawnNote.isSustainNote ? notes.insertBelow(curSpawnNote) : notes.insertTop(curSpawnNote);
				
				unspawnNotes.removeAt(0);
				curSpawnNote = unspawnNotes[0];
			}
		}
	}

	public var curCheckEvent(default, null):Event;

	inline function checkEvents():Void {
		if (curCheckEvent != null) {
			while (events.length > 0 && curCheckEvent.strumTime <= Conductor.songPosition) {
				ModdingUtil.addCall('eventHit', [curCheckEvent]);
				events.removeAt(0);
				curCheckEvent = events[0];
			}
		}
	}

	inline public function isCpuNote(note:BasicNote):Bool {
		return note.mustPress ? inBotplay : dadBotplay;
	}

	public inline function checkCpuNote(note:BasicNote):Void {
		if (note.mustHit) if (isCpuNote(note)) if (Conductor.songPosition >= note.strumTime) {
			if (note.isSustainNote) {
				final sus:Sustain = note.toSustain();
				sus.pressSustain();
				
				if (sus.pressed)
					note.mustPress ? goodSustainPress.dispatch(sus) : opponentSustainPress.dispatch(sus);
			}
			else {
				note.strumTime = Conductor.songPosition; // force sick rating (because lag)
				note.mustPress ? goodNoteHit.dispatch(note.toNote()) : opponentNoteHit.dispatch(note.toNote());
			}
		}
	}

	public inline function checkMissNote(note:BasicNote):Void {
		if (!note.activeNote) if (!note.isSustainNote) {
			if (note.mustHit) if (!isCpuNote(note))
				noteMiss.dispatch(note);
	
			note.removeNote();
		}
	}

	public function sustainMiss(note:Sustain):Void {
		note.missedPress = true;
		if (note.mustHit)
			noteMiss.dispatch(note);
	}

    override function update(elapsed:Float):Void
	{
        super.update(elapsed);
        updateConductor(elapsed);

		if (!generatedMusic)
			return; // Stuff that needs notes / events
		
		spawnNotes();
		checkEvents();

		notes.members.fastForEach((note, i) -> {
			if (note != null) {
				checkCpuNote(note);
				checkMissNote(note);
			}
		});

        if (isPlayState) {
            if (game.inCutscene)
				return; // No controls in cutscenes >:(
        }

        controls();
		checkStrumAnims();
    }

	public var controlArray:Array<Bool> = [];

	private inline function pushControls(strums:StrumLineGroup, value:Bool) {
		strums.members.fastForEach((strum, i) -> controlArray.push(value ? false : strum.getControl(JUST_PRESSED)));
	}

	// Calculate input bullshit
	private var possibleNotes:Array<Note> = [];
	private var removeList:Array<Note> = [];
	private var ignoreList:Array<Int> = [];

    private function controls():Void
	{
		controlArray.clear();
		pushControls(playerStrums, inBotplay);
		pushControls(opponentStrums, dadBotplay);

		if (generatedMusic)
		{
			final hasControl:Bool = controlArray.contains(true);
			if (possibleNotes.length > 0) possibleNotes.clear();
			if (removeList.length > 0) removeList.clear();
			if (ignoreList.length > 0) ignoreList.clear();

			notes.forEachAlive((note:BasicNote) -> {
				if (isCpuNote(note))
					return;

				if (note.isSustainNote) // Handle sustain notes
				{
					final sus:Sustain = note.toSustain();
					sus.pressed = false;
					if (!sus.missedPress)
					{
						if (sus.startedPress)
						{
							if (sus.targetStrum.getControl(PRESSED)) {
								sus.pressSustain();
								if (sus.pressed) // Sustain isnt finished
									sus.mustPress ? goodSustainPress.dispatch(sus) : opponentSustainPress.dispatch(sus);
							}
							else {
								sustainMiss(sus);
								return;
							}
						}
						else
						{
							if (Conductor.songPosition > sus.strumTime + Conductor.safeZoneOffset * sus.hitMult) {
								sustainMiss(sus);
								return;
							}
						}
					}
				}
				else // Handle normal notes
				{
					if (hasControl)
					{
						final note:Note = note.toNote();
						if (note.canBeHit) if (!note.wasGoodHit)
						{
							if (ignoreList.contains(note.noteData))
							{
								possibleNotes.fastForEach((posNote, i) -> {
									if (posNote.noteData == note.noteData)
									{
										if (Math.abs(note.strumTime - posNote.strumTime) < 10) 	removeList.push(note);
										else if (note.strumTime < posNote.strumTime) 			possibleNotes.unsafeSet(i, note);
									}
								});
							}
							else {
								possibleNotes.push(note);
								ignoreList.push(note.noteData);
							}
						}
					}
				}
			});

			if (hasControl)
			{
				removeList.fastForEach((note, i) -> note.removeNote());
				
				final ghostOff:Bool = isPlayState ? !game.ghostTapEnabled : false;

				if (possibleNotes.length > 0)
				{
					if (ghostOff) {
						controlArray.fastForEach((control, i) -> {
							if (control) {
								final data:Int = i % Conductor.NOTE_DATA_LENGTH;
								if (!ignoreList.contains(data))
									badNoteHit.dispatch(data);
							}
						});
					}

					possibleNotes.fastForEach((note, i) -> {
						if (note.exists) if (note.targetStrum.getControl(JUST_PRESSED))
							note.mustPress ? goodNoteHit.dispatch(note) : opponentNoteHit.dispatch(note);
					});
				}
				else if (ghostOff) {
					controlArray.fastForEach((control, i) -> {
						if (control)
							badNoteHit.dispatch(i % Conductor.NOTE_DATA_LENGTH);
					});
				}
			}
		}
	}

	inline function checkStrumAnims():Void
	{
		if (!inBotplay) {
			playerStrums.checkStrums();
			playerStrums.checkCharSinging(boyfriend);
		}

		if (!dadBotplay) {
			opponentStrums.checkStrums();
			opponentStrums.checkCharSinging(dad);
		}
	}

	public function playStrumAnim(note:BasicNote, anim:String = 'confirm', forced:Bool = true):Void
	{
		if (note.targetStrum != null) {
			note.targetStrum.playStrumAnim(anim, forced);
			note.targetStrum.staticTime = Conductor.stepCrochetMills;
		}
	}

	override function destroy():Void {
		super.destroy();
		curSpawnNote = null;
		curCheckEvent = null;
		unspawnNotes = FlxDestroyUtil.destroyArray(unspawnNotes);

		controlArray = null;
		possibleNotes = null;
		removeList = null;
		ignoreList = null;

		goodNoteHit = cast FlxDestroyUtil.destroy(goodNoteHit);
		goodSustainPress = cast FlxDestroyUtil.destroy(goodSustainPress);
		noteMiss = cast FlxDestroyUtil.destroy(noteMiss);
		badNoteHit = cast FlxDestroyUtil.destroy(badNoteHit);
		opponentNoteHit = cast FlxDestroyUtil.destroy(opponentNoteHit);
		opponentSustainPress = cast FlxDestroyUtil.destroy(opponentSustainPress);
	}
}