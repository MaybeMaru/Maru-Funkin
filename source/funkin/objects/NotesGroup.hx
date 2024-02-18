package funkin.objects;

import flixel.util.FlxSignal;
import flixel.util.typeLimit.OneOfTwo;
import funkin.objects.note.Sustain;
import funkin.objects.note.BasicNote;
import flixel.util.FlxArrayUtil;
import funkin.objects.note.StrumLineGroup;

class NotesGroup extends Group
{	
	public static var instance:NotesGroup = null;
    public var SONG:SwagSong;
	var game:PlayState = null;

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
	public function get_strumLineNotes() return opponentStrums.members.concat(playerStrums.members);
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
		if (isPlayState) game.boyfriend.botMode = value;
		return inBotplay = value;
	}

	public function set_dadBotplay(value:Bool) {
		if (isPlayState) game.dad.botMode = value;
		return dadBotplay = value;
	}

	public function spawnSplash(note:Note) {
		grpNoteSplashes.spawnSplash(note);
	}

	inline function hitNote(note:Note, ?character:Character, botplayCheck:Bool = false, prefBot:Bool = false) {
		note.wasGoodHit = true;
		if (note.child != null) note.child.startedPress = true;

		if (isPlayState) {
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

	inline function pressSustain(sustain:Sustain, ?character:Character, botplayCheck:Bool = false, prefBot:Bool = false) {
		if (isPlayState) {
			character.sing(sustain.noteData, sustain.altAnim, false);
			Conductor.vocals.volume = 1;
		}

		if (!botplayCheck || prefBot) {
			if (isPlayState) game.health += sustain.hitHealth[1] * (FlxG.elapsed * 5);
		} else {
			sustain.pressSustain();
		}

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
        
		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;
		Conductor.songOffset = SONG.offsets;
		Conductor.loadMusic(curSong);
		
		songSpeed = getPref('use-const-speed') && isPlayState ? getPref('const-speed') : SONG.speed;
        inBotplay = getPref('botplay') && isPlayState;
		vanillaUI = getPref('vanilla-ui');

		goodNoteHit = new FlxTypedSignal<(Note)->Void>();
		goodSustainPress = new FlxTypedSignal<(Sustain)->Void>();
		
		noteMiss = new FlxTypedSignal<(Int, BasicNote)->Void>();
		badNoteHit = new FlxSignal();
		
		opponentNoteHit = new FlxTypedSignal<(Note)->Void>();
		opponentSustainPress = new FlxTypedSignal<(Sustain)->Void>();
		
		// Setup functions
		goodNoteHit.add(function (note:Note) {
			if (note.wasGoodHit) return;
			hitNote(note, isPlayState ? game.boyfriend : null, inBotplay, getPref("botplay"));
			ModdingUtil.addCall('goodNoteHit', [note]);
			ModdingUtil.addCall('noteHit', [note, true]);
			note.removeNote();
		});

		goodSustainPress.add(function (sustain:Sustain) {
			pressSustain(sustain, isPlayState ? game.boyfriend : null, inBotplay, getPref("botplay"));
			ModdingUtil.addCall('goodSustainPress', [sustain]);
			ModdingUtil.addCall('sustainPress', [sustain, true]);
		});

		opponentNoteHit.add(function (note:Note) {
			if (note.wasGoodHit) return;
			hitNote(note, isPlayState ? game.dad : null, dadBotplay);
			ModdingUtil.addCall('opponentNoteHit', [note]);
			ModdingUtil.addCall('noteHit', [note, false]);
			note.removeNote();
		});

		opponentSustainPress.add(function (sustain:Sustain) {
			pressSustain(sustain, isPlayState ? game.dad : null, dadBotplay);
			ModdingUtil.addCall('opponentSustainPress', [sustain]);
			ModdingUtil.addCall('sustainPress', [sustain, false]);
		});

		if (!isPlayState) return;

		noteMiss.add(function(direction:Int = 1, ?note:BasicNote):Void {
			if (note == null) {
				game.health -= 0.04;
				game.songScore -= 10;
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
				ModdingUtil.addCall('badNoteHit', [direction]);
			}
			else {
				if (game.combo >= 5) game.gf.playAnim('sad');
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
			}

			final missChar = note == null ? game.boyfriend : note.mustPress ? game.boyfriend : game.dad;
			missChar.sing(direction, 'miss');
			
			game.updateScore();
		});

		badNoteHit.add(function () {
			controlArray.fastForEach((control, i) -> {
				if (control)
					noteMiss.dispatch(i, null);
			});
		});
    }

    public function init(startPos:Float = -5000) {
		StrumLineGroup.strumLineY = getPref('downscroll') ? FlxG.height - 150 : 50;
		
		opponentStrums = new StrumLineGroup(0, skipStrumIntro);
		add(opponentStrums);
		
		playerStrums = new StrumLineGroup(1, skipStrumIntro);
		add(playerStrums);

		grpNoteSplashes = new SplashGroup();
		add(grpNoteSplashes);

        //Make Song
		Conductor.songPosition = startPos;
		generateSong();
    }

	private function generateSong():Void {
		ModdingUtil.addCall('generateSong', [SONG]);

		unspawnNotes = [];
		events = [];
		notes = new TypedGroup<BasicNote>();
		add(notes);
	
		for (section in SONG.notes) {
			for (songNotes in section.sectionNotes) {
				final strumTime:Float = songNotes[0];
				final susLength:Null<Float> = songNotes[2];
				if ((susLength != null ? strumTime + susLength : strumTime) < Conductor.songPosition) continue; // Save on creating missed notes
				
				final noteData:Int = Std.int(songNotes[1] % Conductor.NOTE_DATA_LENGTH);
				final noteType:String = NoteUtil.getTypeName(songNotes[3]);
				final mustPress:Bool = section.mustHitSection ? songNotes[1] < Conductor.NOTE_DATA_LENGTH : songNotes[1] >= Conductor.NOTE_DATA_LENGTH;
				final targetStrum = mustPress ? playerStrums.members[noteData] : opponentStrums.members[noteData];
				final skin = NoteUtil.getTypeJson(noteType)?.skin ?? SkinUtil.curSkin;

				final note:Note = new Note(noteData, strumTime, skin);
				note.targetStrum = targetStrum;
				note.mustPress = mustPress;
				note.noteType = noteType;
				note.noteSpeed = songSpeed;
				unspawnNotes.push(note);

				if (susLength > 0) {
					final sustain:Sustain = new Sustain(noteData, strumTime, susLength, skin, note);
					sustain.noteSpeed = songSpeed;
					sustain.targetStrum = targetStrum;
					sustain.mustPress = mustPress;
					sustain.noteType = noteType;
					
					if (sustain.alive) // Too short sustains shouldnt be added
						unspawnNotes.push(sustain);

					note.child = sustain;
				}

				//	Add notetype for scripts
				if (!songNotetypes.contains(noteType)) {	
					songNotetypes.push(noteType);
				}
			}

			for (e in section.sectionEvents) {
				final strumTime:Float = e[0];
				final eventName:String = e[1];
				final eventValues:Array<Dynamic> = e[2];

				final event:Event = new Event(strumTime, eventName, eventValues);
				events.push(event);

				//	Add event for scripts
				if (!songEvents.contains(eventName)) {
					songEvents.push(eventName);
				}
			}
		}

		scrollSpeed = songSpeed;

		unspawnNotes.sort(CoolUtil.sortByStrumTime);
		events.sort(CoolUtil.sortByStrumTime);

		curSpawnNote = unspawnNotes[0];
		curCheckEvent = events[0];
		
		if (isPlayState) {
			final notetypeScripts:Array<String> = ModdingUtil.getSubFolderScriptList('data/notetypes', [curSong]);
			for (script in notetypeScripts) { //Notetype Scripts
				if (songNotetypes.contains(script.split('.hx')[0].split('notetypes/')[1])) {
					ModdingUtil.addScript(script);
				}
			}
			
			final eventScripts:Array<String> = ModdingUtil.getSubFolderScriptList('data/events', [curSong]);
			for (script in eventScripts) { //Event Scripts
				if (songEvents.contains(script.split('.hx')[0].split('events/')[1])) {
					ModdingUtil.addScript(script);
				}
			}
		}


		FlxG.bitmap.clearUnused();
		generatedMusic = true;
	}

	public var scrollSpeed(default, set):Float = 1.0; // Shortcut to change all notes scroll speed
	public function set_scrollSpeed(value:Float = 1.0) {
		if (value != scrollSpeed)
		{
			unspawnNotes.fastForEach((note, i) -> {
				note.noteSpeed = value;
			});

			notes.members.fastForEach((note, i) -> {
				note.noteSpeed = value;
			});
			
			if (value < scrollSpeed)
				spawnNotes();
		}
		return scrollSpeed = value;
	}

    public var goodNoteHit:FlxTypedSignal<(Note)->Void>;
    public var goodSustainPress:FlxTypedSignal<(Sustain)->Void>;
    
	public var noteMiss:FlxTypedSignal<(Int, BasicNote)->Void>;
    public var badNoteHit:FlxSignal;
    
    public var opponentNoteHit:FlxTypedSignal<(Note)->Void>;
    public var opponentSustainPress:FlxTypedSignal<(Sustain)->Void>;

    //Makes the conductor song go vroom vroom
    inline function updateConductor(elapsed:Float = 0) {
		if (Conductor.inst.playing) {
			if (Conductor.songPosition - SONG.offsets[1] >= Conductor.vocals.length && isPlayState) { // Prevent repeating vocals
				Conductor.vocals.volume = 0;
			}
		}

		if (isPlayState) {
			final starting = game.startingSong;
			if ((Conductor.playing || starting || Conductor.songPosition < game.songLength) && !game.inCutscene) {
				Conductor.songPosition += elapsed * 1000;
				if (game.startedCountdown && starting) {
					if (Conductor.songPosition >= 0)
						game.startSong();
				}
				else if (!game.paused && !Conductor.inst.playing) Conductor.play();
			}
		}
		else {
            Conductor.songPosition += elapsed * 1000;
			if (!Conductor.inst.playing) Conductor.play();
			if (Conductor.songPosition % Conductor.stepCrochet <= 5) {
				Conductor.autoSync();
			}
		}
    }

	public var curSpawnNote(default, null):BasicNote = null;

	inline function spawnNotes() { // Generate notes
		if (curSpawnNote != null) {
			while (unspawnNotes.length > 0 && curSpawnNote.strumTime - Conductor.songPosition < 1500 / curSpawnNote.noteSpeed / camera.zoom * curSpawnNote.spawnMult) {
				final spawnNote:BasicNote = curSpawnNote;
				spawnNote.update(0.0);
				ModdingUtil.addCall('noteSpawn', [spawnNote]);
				unspawnNotes.splice(0, 1);

				// Skip sorting
				if (spawnNote.isSustainNote)	notes.insert(0, spawnNote);
				else							notes.add(spawnNote);
				curSpawnNote = unspawnNotes[0];
			}
		}
	}

	public var curCheckEvent(default, null):Event = null;

	inline function checkEvents() {
		if (curCheckEvent != null) {
			while (events.length > 0 && curCheckEvent.strumTime <= Conductor.songPosition) {
				final runEvent:Event = curCheckEvent;
				ModdingUtil.addCall('eventHit', [runEvent]);
				events.splice(0, 1);
				curCheckEvent = events[0];
			}
		}
	}

	inline public function isCpuNote(note:BasicNote) {
		return (note.mustPress && inBotplay) || (!note.mustPress && dadBotplay);
	}

	public inline function checkCpuNote(note:BasicNote) {
		if (!isCpuNote(note)) return;
		if (Conductor.songPosition >= note.strumTime && note.mustHit) {
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

	public inline function checkMissNote(note:BasicNote) {
		if (note.activeNote || note.isSustainNote) return;
		if (!isCpuNote(note) && note.mustHit)
			noteMiss.dispatch(note.noteData % Conductor.NOTE_DATA_LENGTH, note);

		note.removeNote();
	}

	public function sustainMiss(note:Sustain) {
		note.missedPress = true;
		if (note.mustHit)
			noteMiss.dispatch(note.noteData % Conductor.NOTE_DATA_LENGTH, note);
	}

    override function update(elapsed:Float) {
        super.update(elapsed);
        updateConductor(elapsed);

		if (!generatedMusic) return; // Stuff that needs notes / events
		spawnNotes();
		checkEvents();

		notes.members.fastForEach((note, i) -> {
			checkCpuNote(note);
			checkMissNote(note);
		});

        if (isPlayState) {
            if (game.inCutscene) return; // No controls in cutscenes >:(
        }
        controls();
		checkStrumAnims();
    }

	public var controlArray:Array<Bool> = [];

	private inline function pushControls(strums:StrumLineGroup, value:Bool) {
		strums.members.fastForEach((strum, i) -> {
			controlArray.push(value ? false : strum.getControl(JUST_PRESSED));
		});
	}

    private inline function controls():Void {
		controlArray.splice(0, controlArray.length);
		pushControls(playerStrums, inBotplay);
		pushControls(opponentStrums, dadBotplay);

		if (generatedMusic) {
			final possibleNotes:Array<Note> = [];
			final ignoreList:Array<Int> = [];
			final removeList:Array<Note> = [];

			notes.forEachAlive(function (note:BasicNote) {
				if (isCpuNote(note)) return;

				if (note.isSustainNote) { // Handle sustain notes
					final sus:Sustain = note.toSustain();
					sus.pressed = false;
					if (!sus.missedPress) {
						if ((Conductor.songPosition > sus.strumTime + Conductor.safeZoneOffset * sus.hitMult) && !sus.startedPress) {
							sustainMiss(sus);
							return;
						}
						if (sus.startedPress) {
							final holding = sus.targetStrum.getControl(PRESSED);
							if (!holding) { // Sustain stopped being pressed
								sustainMiss(sus); 
								return;
							}
							else {
								if (holding) sus.pressSustain(); // Pressed sustain
								if (sus.pressed)
									sus.mustPress ? goodSustainPress.dispatch(sus) : opponentSustainPress.dispatch(sus);
							}
						}
					}
				}
				else { // Handle normal notes
					if (controlArray.contains(true)) {
						final note:Note = note.toNote();
						if (note.canBeHit && !note.wasGoodHit) {
							if (ignoreList.contains(note.noteData)) {
								possibleNotes.fastForEach((possibleNote, i) -> {
									final possibleNote:Note = possibleNotes[i];
									if (possibleNote.noteData == note.noteData && Math.abs(note.strumTime - possibleNote.strumTime) < 10) {
										removeList.push(note);
									}
									else if (possibleNote.noteData == note.noteData && note.strumTime < possibleNote.strumTime) {
										possibleNotes.remove(possibleNote);
										possibleNotes.push(note);
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

			if (controlArray.contains(true)) {
				removeList.fastForEach((note, i) -> {
					note.removeNote();
				});
				
				final onGhost = isPlayState ? game.ghostTapEnabled : true;

				if (possibleNotes.length > 0) {
					if (!onGhost) {
						controlArray.fastForEach((control, i) -> {
							if (control && !ignoreList.contains(i))
								badNoteHit.dispatch();
						});
					}

					possibleNotes.fastForEach((note, i) -> {
						if (note.targetStrum.getControl(JUST_PRESSED))
							note.mustPress ? goodNoteHit.dispatch(note) : opponentNoteHit.dispatch(note);
					});
				}
				else if (!onGhost)
					badNoteHit.dispatch();
			}
		}
	}

	inline function checkStrums(array:Array<NoteStrum>) {
		array.fastForEach((strum, i) -> {
			final anim = strum.animation.curAnim;
			if (anim == null) continue; // Lil null check
			
			if (strum.getControl(JUST_PRESSED) && !anim.name.startsWith('confirm'))
				strum.playStrumAnim('pressed');
			
			if (!strum.getControl())
				strum.playStrumAnim('static');
		});
	}

	inline function checkStrumAnims():Void {
		if (!inBotplay) checkStrums(playerStrums.members);
		if (!dadBotplay) checkStrums(opponentStrums.members);

		// Check for sing animations in PlayState characters
        if (isPlayState) {
			if (!inBotplay) checkOverSinging(game.boyfriend, playerStrums);
			if (!dadBotplay) checkOverSinging(game.dad, opponentStrums);
		}
	}

	function checkOverSinging(char:Character, strums:StrumLineGroup) {
		var anim = char.animation.curAnim;
		if (anim == null) return;
		var name:String = anim.name;
		
		var overSinging:Bool =
		(char.holdTimer > (Conductor.stepCrochetMills * Conductor.STEPS_PER_BEAT)
		&& name.startsWith('sing')
		&& !name.endsWith('miss'));

		if (overSinging) {
			var isHolding:Bool = false;
			strums.members.fastForEach((strum, i) -> {
				if (strum.animation.curAnim.name.startsWith('confirm')) {
					isHolding = true;
					break;
				}
			});

			if (!isHolding)
				char.restartDance();
		}
	}

	public function playStrumAnim(note:BasicNote, anim:String = 'confirm', forced:Bool = true) {
		var strum = note.targetStrum;
		if (strum != null) {
			strum.playStrumAnim(anim, forced);
			strum.staticTime = Conductor.stepCrochetMills;
		}
	}

	override function destroy() {
		super.destroy();
		curSpawnNote = null;
		curCheckEvent = null;
		controlArray = null;
		unspawnNotes = FlxDestroyUtil.destroyArray(unspawnNotes);

		goodNoteHit = cast FlxDestroyUtil.destroy(goodNoteHit);
		goodSustainPress = cast FlxDestroyUtil.destroy(goodSustainPress);
		noteMiss = cast FlxDestroyUtil.destroy(noteMiss);
		badNoteHit = cast FlxDestroyUtil.destroy(badNoteHit);
		opponentNoteHit = cast FlxDestroyUtil.destroy(opponentNoteHit);
		opponentSustainPress = cast FlxDestroyUtil.destroy(opponentSustainPress);
	}
}