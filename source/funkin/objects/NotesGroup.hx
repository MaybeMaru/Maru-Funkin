package funkin.objects;

import flixel.util.typeLimit.OneOfTwo;
import funkin.objects.note.Sustain;
import funkin.objects.note.BasicNote;
import flixel.util.FlxArrayUtil;
import funkin.objects.note.StrumLineGroup;

class NotesGroup extends FlxGroup
{
    public var SONG:SwagSong;

    public static var songSpeed:Float = 1.0;
    public var curSong:String = 'test';
    public var songNotetypes:Array<String> = [];
	public var songEvents:Array<String> = [];

	public var generatedMusic:Bool = false;

    public var notes:FlxTypedGroup<BasicNote>;
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
		if (isPlayState) PlayState.instance.boyfriend.botMode = value;
		return inBotplay = value;
	}

	public function set_dadBotplay(value:Bool) {
		if (isPlayState) PlayState.instance.dad.botMode = value;
		return dadBotplay = value;
	}

	public function spawnSplash(note:Note) {
		grpNoteSplashes.spawnSplash(note);
	}

	function hitNote(note:Note, ?character:Character, botplayCheck:Bool = false, prefBot:Bool = false) {
		note.wasGoodHit = true;
		if (note.child != null) note.child.startedPress = true;

		if (isPlayState) {
			character.sing(note.noteData, note.altAnim);
			Conductor.vocals.volume = 1;
		}

		if (!botplayCheck || prefBot) {
			if (isPlayState) PlayState.instance.health += note.hitHealth[0];
			final rating:String = isPlayState ? PlayState.instance.popUpScore(note.strumTime, note) :
			CoolUtil.getNoteJudgement(CoolUtil.getNoteDiff(note));
			if (rating == "sick") spawnSplash(note); // Spawn splash
		}

		botplayCheck ? if (!getPref('vanilla-ui')) playStrumAnim(note) :
		note.targetStrum.playStrumAnim('confirm', true);
	}

	function pressSustain(note:Sustain, ?character:Character, botplayCheck:Bool = false, prefBot:Bool = false) {
		if (isPlayState) {
			character.sing(note.noteData, note.altAnim, false);
			Conductor.vocals.volume = 1;
		}

		if (!botplayCheck || prefBot) {
			if (isPlayState) PlayState.instance.health += note.hitHealth[1] * (FlxG.elapsed * 5);
		} else {
			note.pressSustain();
		}

		botplayCheck ? if (!getPref('vanilla-ui')) playStrumAnim(note) :
		note.targetStrum.playStrumAnim('confirm', true);
	}
    
    public function new(_SONG:SwagSong, isPlayState:Bool = true) {
        super();
		this.isPlayState = isPlayState;
        SONG = Song.checkSong(_SONG, null, false); //Double check null values
        Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;
		Conductor.songOffset = SONG.offsets;
		songSpeed = getPref('use-const-speed') && isPlayState ? getPref('const-speed') : SONG.speed;
        inBotplay = getPref('botplay') && isPlayState;
		
		// Setup functions
		final game:PlayState = isPlayState ? PlayState.instance : null;
		
		goodNoteHit = function (note:Note) {
			if (note.wasGoodHit) return;
			hitNote(note, isPlayState ? game.boyfriend : null, inBotplay, getPref("botplay"));
			ModdingUtil.addCall('goodNoteHit', [note]);
			ModdingUtil.addCall('noteHit', [note, true]);
			removeNote(note);
		}

		goodSustainPress = function (sustain:Sustain) {
			pressSustain(sustain, isPlayState ? game.boyfriend : null, inBotplay, getPref("botplay"));
			ModdingUtil.addCall('goodSustainPress', [sustain]);
			ModdingUtil.addCall('sustainPress', [sustain, true]);
		}

		opponentNoteHit = function (note:Note) {
			if (note.wasGoodHit) return;
			hitNote(note, isPlayState ? game.dad : null, dadBotplay);
			ModdingUtil.addCall('opponentNoteHit', [note]);
			ModdingUtil.addCall('noteHit', [note, false]);
			removeNote(note);
		}

		opponentSustainPress = function (sustain:Sustain) {
			pressSustain(sustain, isPlayState ? game.dad : null, dadBotplay);
			ModdingUtil.addCall('opponentSustainPress', [sustain]);
			ModdingUtil.addCall('sustainPress', [sustain, false]);
		}

		if (!isPlayState) return;

		noteMiss = function(direction:Int = 1, ?note:BasicNote):Void {
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
					final sus = cast(note, Sustain);
					healthMult = (sus.startedPress ? sus.percentLeft : 1) * (sus.susLength / Conductor.stepCrochet) * 4;
				}

				game.health -= healthLoss * healthMult;
				game.songScore -= Std.int(10 * healthMult);

				game.noteCount++;
				game.songMisses++;
					
				ModdingUtil.addCall('noteMiss', [note]);
			}

			final missChar = note == null ? game.boyfriend : note.mustPress ? game.boyfriend : game.dad;
			missChar.stunned = true;
			missChar.sing(direction, 'miss');
			new FlxTimer().start(0.083333333333333, function(tmr:FlxTimer) {
				missChar.stunned = false;
			});
			
			game.updateScore();
		}

		badNoteHit = function () {
			for (i in 0...controlArray.length) {
				if (controlArray[i])
					checkCallback(noteMiss, [i]);
			}
		}
    }

    public function init(startPos:Float = -5000) {
		StrumLineGroup.strumLineY = Preferences.getPref('downscroll') ? FlxG.height - 150 : 50;
		
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
		final songData:SwagSong = SONG;
		ModdingUtil.addCall('generateSong', [songData]);

		unspawnNotes = [];
		events = [];
		notes = new FlxTypedGroup<BasicNote>();
		add(notes);
	
		final noteData:Array<SwagSection> = songData.notes;
		curSong = songData.song;

        Conductor.loadMusic(curSong);
		Conductor.bpm = songData.bpm;
	
		for (section in noteData) {
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
				unspawnNotes.push(note);

				if (susLength > 0) {
					final sustain:Sustain = new Sustain(noteData, strumTime, susLength, skin, note);
					sustain.targetStrum = targetStrum;
					sustain.mustPress = mustPress;
					sustain.noteType = noteType;
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
		if (value != scrollSpeed) {
			for (i in unspawnNotes.concat(notes.members)) {
				i.noteSpeed = value;
			}
			spawnNotes();
		}
		return scrollSpeed = value;
	}

    public var goodNoteHit:Dynamic = null;
    public var goodSustainPress:Dynamic = null;
    public var noteMiss:Dynamic = null;
    public var badNoteHit:Dynamic = null;
    
    public var opponentNoteHit:Dynamic = null;
    public var opponentSustainPress:Dynamic = null;

    public function checkCallback(callback:Dynamic, ?args:Array<Dynamic>) {
        if (callback != null) Reflect.callMethod(this, callback, args ?? []); // Prevent null
    }

	public inline function removeNote(note:BasicNote) {
		notes.remove(note, true);
		note.destroy();
	}

    //Makes the conductor song go vroom vroom
    function updateConductor(elapsed:Float = 0) {
		if (Conductor.inst.playing) {
			if (Conductor.songPosition - SONG.offsets[1] >= Conductor.vocals.length && isPlayState) { // Prevent repeating vocals
				Conductor.vocals.volume = 0;
			}
		}

		if (isPlayState) {
			final game = PlayState.instance;
			if ((game.startingSong || Conductor.playing || Conductor.songPosition < game.songLength) && !game.inCutscene) {
				Conductor.songPosition += elapsed * 1000;
				if (game.startedCountdown && game.startingSong) {
					if (Conductor.songPosition >= 0) game.startSong();
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

	function spawnNotes() { // Generate notes
        if (unspawnNotes[0] != null) {
			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < 1500 / unspawnNotes[0].noteSpeed / cameras[0].zoom * unspawnNotes[0].spawnMult) {
				final spawnNote:BasicNote = unspawnNotes[0];
				spawnNote.update(0.0);
				ModdingUtil.addCall('noteSpawn', [spawnNote]);
				unspawnNotes.splice(unspawnNotes.indexOf(spawnNote), 1);

				notes.add(spawnNote);
				notes.sort(function (order:Int, note1:BasicNote, note2:BasicNote):Int {
					if (note1.strumTime == note2.strumTime) {
						if (note1.isSustainNote && !note2.isSustainNote) return -1;
						if (!note1.isSustainNote && note2.isSustainNote) return 1;
					}
					return CoolUtil.sortByStrumTime(note1, note2);
				}, FlxSort.DESCENDING);
			}
		}
	}

	function checkEvents() {
		if (events[0] != null) {
			while (events.length > 0 && events[0].strumTime <= Conductor.songPosition) {
				final runEvent:Event = events[0];
				ModdingUtil.addCall('eventHit', [runEvent]);
				events.splice(events.indexOf(runEvent), 1);
			}
		}
	}

	inline public function isCpuNote(note:BasicNote) {
		return (note.mustPress && inBotplay) || (!note.mustPress && dadBotplay);
	}

	public function checkCpuNote(note:BasicNote) {
		if (!isCpuNote(note)) return;
		if (Conductor.songPosition >= note.strumTime && note.mustHit) {
			if (note.isSustainNote) {
				final sus = cast(note, Sustain);
				sus.pressSustain();
				if (sus.pressed) checkCallback(note.mustPress ? goodSustainPress : opponentSustainPress, [note]);
			} else {
				note.strumTime = Conductor.songPosition; // force sick rating (because lag)
				checkCallback(note.mustPress ? goodNoteHit : opponentNoteHit, [note]);
			}
		}
	}

	public function checkMissNote(note:BasicNote) {
		if (note.active || Conductor.songPosition < note.strumTime) return;
		if (!isCpuNote(note) && !note.isSustainNote && note.mustHit)
			checkCallback(noteMiss, [note.noteData%Conductor.NOTE_DATA_LENGTH, note]);
		removeNote(note);
	}

	public function sustainMiss(note:Sustain) {
		note.missedPress = true;
		if (note.mustHit)
			checkCallback(noteMiss, [note.noteData%Conductor.NOTE_DATA_LENGTH, note]);
	}

    override function update(elapsed:Float) {
        super.update(elapsed);
        updateConductor(elapsed);

		if (!generatedMusic) return; // Stuff that needs notes / events
		spawnNotes();
		checkEvents();
		notes.forEachAlive(function(daNote:BasicNote) {
			checkCpuNote(daNote);
			checkMissNote(daNote);
		});

        if (isPlayState) {
            if (PlayState.instance.inCutscene) return; // No controls in cutscenes >:(
        }
        controls();
		checkStrumAnims();
    }

    public var holdingArray:Array<Bool> = [];
	public var controlArray:Array<Bool> = [];

	private inline function pushControls(strums:StrumLineGroup, value:Bool) {
		for (i in strums) {
			holdingArray.push(value ? false : i.getControl());
			controlArray.push(value ? false : i.getControl("-P"));
		}
	}

    private inline function controls():Void {
		holdingArray = [];
		controlArray = [];
		pushControls(playerStrums, inBotplay);
		pushControls(opponentStrums, dadBotplay);

		if (generatedMusic) {
			final possibleNotes:Array<Note> = [];
			final ignoreList:Array<Int> = [];
			final removeList:Array<Note> = [];

			notes.forEachAlive(function(note:BasicNote) {
				if (isCpuNote(note)) return; // Skip Cpu notes

				if (note.isSustainNote) { // Handle sustain notes
					final sustain:Sustain = cast(note, Sustain);
					sustain.pressed = false;
					if (!sustain.missedPress) {
						if ((Conductor.songPosition > sustain.strumTime + Conductor.safeZoneOffset * sustain.hitMult) && !sustain.startedPress) {
							sustainMiss(sustain);
							return;
						}
						if (sustain.startedPress) {
							final holding = sustain.targetStrum.getControl();
							if (!holding) { // Sustain stopped being pressed
								sustainMiss(sustain); 
								return;
							}
							else {
								if (holding) sustain.pressSustain(); // Pressed sustain
								if (sustain.pressed) checkCallback(sustain.mustPress ? goodSustainPress : opponentSustainPress, [sustain]);
							}
						}
					}
				}
				else { // Handle normal notes
					if (controlArray.contains(true)) {
						final note:Note = cast(note, Note);
						if (note.canBeHit && !note.wasGoodHit) {
							if (ignoreList.contains(note.noteData)) {
								for (i in 0...possibleNotes.length) {
									final possibleNote:Note = possibleNotes[i];
									if (possibleNote.noteData == note.noteData && Math.abs(note.strumTime - possibleNote.strumTime) < 10) {
										removeList.push(note);
									}
									else if (possibleNote.noteData == note.noteData && note.strumTime < possibleNote.strumTime) {
										possibleNotes.remove(possibleNote);
										possibleNotes.push(note);
									}
								}
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
				forEachArray(removeList, function (badNote) removeNote(badNote));
				final onGhost = isPlayState ? PlayState.instance.ghostTapEnabled : true;

				possibleNotes.sort(CoolUtil.sortByStrumTime);
				if (possibleNotes.length > 0) {
					if (!onGhost) {
						for (i in 0...controlArray.length) {
							if (controlArray[i] && !ignoreList.contains(i)) checkCallback(badNoteHit);
						}
					}

					forEachArray(possibleNotes, function (possibleNote) {
						if (possibleNote.targetStrum.getControl("-P"))
							checkCallback(possibleNote.mustPress ? goodNoteHit : opponentNoteHit, [possibleNote]);
					});
				}
				else if (!onGhost) {
                    checkCallback(badNoteHit);
				}
			}
		}
	}

	inline function forEachArray(array:Array<Dynamic>, func:Dynamic) {
		var i:Int = 0;
		while (i < array.length)
			func(array[i++]);
	}

	function checkStrumAnims():Void {
		final checkStrums:Array<NoteStrum> = (inBotplay ? [] : playerStrums.members).concat(dadBotplay ? [] : opponentStrums.members);
		for (strum in checkStrums) {
			final strumAnim = strum.animation.curAnim;
			if (strumAnim == null) continue; // Lil null check
			if (strum.getControl("-P") && !strumAnim.name.startsWith('confirm'))
				strum.playStrumAnim('pressed');
			if (!strum.getControl())
				strum.playStrumAnim('static');
		}

        if (!isPlayState) return; // Botplay handles sing anims and strums, not necessary
		if (!inBotplay) checkOverSinging(PlayState.instance.boyfriend, playerStrums);
		if (!dadBotplay) checkOverSinging(PlayState.instance.dad, opponentStrums);
	}

	function checkOverSinging(char:Character, strums:StrumLineGroup) {
		final overSinging:Bool = (char.holdTimer > (Conductor.stepCrochetMills * Conductor.STEPS_PER_BEAT)
		&& char.animation.curAnim.name.startsWith('sing')
		&& !char.animation.curAnim.name.endsWith('miss'));

		if (overSinging) {
			var isHolding:Bool = false;
			for (strum in strums) {
				if (strum.animation.curAnim.name.startsWith('confirm')) {
					isHolding = true;
					break;
				}
			}
			if (!isHolding) char.restartDance();
		}
	}

	public function playStrumAnim(note:BasicNote, anim:String = 'confirm', forced:Bool = true) {
		final strum = note.targetStrum;
		if (strum == null) return;
		strum.playStrumAnim(anim, forced);
		strum.staticTime = Conductor.stepCrochetMills;
	}

    inline function getPref(pref:String):Dynamic return Preferences.getPref(pref);
}