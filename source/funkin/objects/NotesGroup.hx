package funkin.objects;

import funkin.objects.note.StrumLineGroup;

class NotesGroup extends FlxGroup
{
    public var SONG:SwagSong;

    public static var songSpeed:Float = 1.0;
    public var curSong:String = 'test';
    public var songNotetypes:Array<String> = [];
	public var songEvents:Array<String> = [];

	public var generatedMusic:Bool = false;

    public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var events:Array<Event> = [];

    public var skipStrumIntro:Bool = false;

	public var strumLineNotes(get, never):Array<NoteStrum>;
	public function get_strumLineNotes() return opponentStrums.members.concat(playerStrums.members);
	public var playerStrums:StrumLineGroup;
	public var opponentStrums:StrumLineGroup;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var strumLineInitPos(get, never):Array<FlxPoint>;
	public function get_strumLineInitPos() return opponentStrums.initPos.concat(playerStrums.initPos);
	public var playerStrumsInitPos(get, never):Array<FlxPoint>;
	public function get_playerStrumsInitPos() return playerStrums.initPos;
	public var opponentStrumsInitPos(get, never):Array<FlxPoint>;
	public function get_opponentStrumsInitPos() return playerStrums.initPos;

    public var inBotplay:Bool = false;
	public var dadBotplay:Bool = true;
	public var isPlayState:Bool = true;

	public function spawnSplash(note:Note) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(note.x, note.y, note.noteData, note);
		grpNoteSplashes.add(splash);
	}
    
    public function new(_SONG:SwagSong, isPlayState:Bool = true) {
        super();
		this.isPlayState = isPlayState;
        SONG = Song.checkSong(_SONG); //Double check null values
        Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;
		Conductor.songOffset = SONG.offsets;
		songSpeed = getPref('use-const-speed') && isPlayState ? getPref('const-speed') : SONG.speed;
        inBotplay = getPref('botplay') && isPlayState;
		if (isPlayState) return;

		// Default values
		goodNoteHit = function (note:Note) {
			if (note.wasGoodHit) return;
			playerStrums.members[note.noteData].playStrumAnim('confirm', true);
			note.wasGoodHit = true;
			if (note.childNote != null) note.childNote.startedPress = true;
			removeNote(note);

			if (CoolUtil.getNoteJudgement(CoolUtil.getNoteDiff(note)) == 'sick') {
				spawnSplash(note);
			}
		}
		goodSustainPress = function (note:Note) {
			playerStrums.members[note.noteData].playStrumAnim('confirm', true);
		}
		opponentNoteHit = function (note:Note) {
			playStrumAnim(note.noteData%Conductor.NOTE_DATA_LENGTH);
			removeNote(note);
		}
		opponentSustainPress = function (note:Note) {
			playStrumAnim(note.noteData%Conductor.NOTE_DATA_LENGTH);
			note.setSusPressed();
		}
    }

	function cacheSplash() {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(0, 0, 0);
		grpNoteSplashes.add(splash);
		splash.kill();
	}

    public function init(startPos:Float = -5000) {
		StrumLineGroup.strumLineY = Preferences.getPref('downscroll') ? FlxG.height - 150 : 50;
		opponentStrums = new StrumLineGroup(0, skipStrumIntro);
		add(opponentStrums);
		playerStrums = new StrumLineGroup(1, skipStrumIntro);
		add(playerStrums);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		add(grpNoteSplashes);
		cacheSplash();

        //Make Song
		Conductor.songPosition = startPos;
		generateSong();
    }

	private function generateSong():Void {
		var songData:SwagSong = SONG;
		ModdingUtil.addCall('generateSong', [songData]);

		unspawnNotes = [];
		events = [];
		notes = new FlxTypedGroup<Note>();
		add(notes);
	
		var noteData:Array<SwagSection> = songData.notes;
		curSong = songData.song;

        Conductor.loadMusic(curSong);
		Conductor.bpm = songData.bpm;
	
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var strumTime:Float = songNotes[0];
				var sustainLength:Null<Float> = songNotes[2];
				if ((sustainLength != null ? strumTime + sustainLength : strumTime) < Conductor.songPosition) continue; // Save on creating missed notes
				var noteData:Int = Std.int(songNotes[1] % Conductor.NOTE_DATA_LENGTH);
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
					if (newSustain.alive) {
						newSustain.noteSpeed = songSpeed;
						newSustain.targetSpr = targetStrum;
						newSustain.mustPress = mustPress;
						newSustain.noteType = noteType;
						newSustain.parentNote = newNote;
						newNote.childNote = newSustain;
						unspawnNotes.push(newSustain);
					}
					else newSustain.destroy();  // clear too small sustains
				}

				//	Add notetype for scripts
				if (!songNotetypes.contains(noteType)) {	
					songNotetypes.push(noteType);
				}
			}

			for (e in section.sectionEvents) {
				var strumTime:Float = e[0];
				var eventName:String = e[1];
				var eventValues:Array<Dynamic> = e[2];

				var event:Event = new Event(strumTime, eventName, eventValues);
				events.push(event);

				//	Add event for scripts
				if (!songEvents.contains(eventName)) {
					songEvents.push(eventName);
				}
			}
		}

		unspawnNotes.sort(function(Obj1:Note, Obj2:Note):Int return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime));
		events.sort(function(Obj1:Event, Obj2:Event):Int return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime));
		
		//Notetype Scripts
		var notetypeScripts:Array<String> = ModdingUtil.getSubFolderScriptList('data/notetypes', [curSong]);
		for (script in notetypeScripts) {
			if (songNotetypes.contains(script.split('.hx')[0].split('notetypes/')[1])) {
				ModdingUtil.addScript(script);
			}
		}

		//Event Scripts
		var eventScripts:Array<String> = ModdingUtil.getSubFolderScriptList('data/events', [curSong]);
		for (script in eventScripts) {
			if (songEvents.contains(script.split('.hx')[0].split('events/')[1])) {
				ModdingUtil.addScript(script);
			}
		}

		FlxG.bitmap.clearUnused();
		generatedMusic = true;
	}

    public var goodNoteHit:Dynamic = null;
    public var goodSustainPress:Dynamic = null;
    public var noteMiss:Dynamic = null;
    public var badNoteHit:Dynamic = null;
    
    public var opponentNoteHit:Dynamic = null;
    public var opponentSustainPress:Dynamic = null;

    public function checkCallback(callback:Dynamic, ?args:Array<Dynamic>) {
        if (callback != null) Reflect.callMethod(this, callback, args != null ? args : []); // Prevent null
    }

	public function removeNote(note:Note) {
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
		
		if (!isPlayState) {
            Conductor.songPosition += FlxG.elapsed * 1000;
			if (!Conductor.inst.playing) Conductor.play();
			if (Conductor.songPosition % Conductor.stepCrochet <= 5) {
				Conductor.autoSync();
			}
            return;
        }

        var game = PlayState.instance;
        if ((game.startingSong || Conductor.inst.playing || Conductor.songPosition < game.songLength) && !game.inCutscene) {
            Conductor.songPosition += FlxG.elapsed * 1000;
            if (game.startedCountdown && game.startingSong) {
                if (Conductor.songPosition >= 0) game.startSong();
            }
            else if (!game.paused && !Conductor.inst.playing) Conductor.play();
        }
    }

	function spawnNotes() { // Generate notes
        if (unspawnNotes[0] != null) {
			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < 1500 / songSpeed / cameras[0].zoom) {
				var dunceNote:Note = unspawnNotes[0];
				ModdingUtil.addCall('noteSpawn', [dunceNote]);
				notes.add(dunceNote);
				dunceNote.update(FlxG.elapsed);
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
	}

	function checkEvents() {
		if (events[0] != null) {
			while (events.length > 0 && events[0].strumTime <= Conductor.songPosition) {
				var dunceEvent:Event = events[0];
				ModdingUtil.addCall('eventHit', [dunceEvent]);
				events.splice(events.indexOf(dunceEvent), 1);
			}
		}
	}

	public function checkCpuNote(note:Note) {
		if ((note.mustPress && !inBotplay) || (!note.mustPress && !dadBotplay)) return;
		if (Conductor.songPosition >= note.strumTime && note.mustHit) {
			if (note.isSustainNote) {
				note.pressed = note.inSustain;
				if (note.pressed) checkCallback(note.mustPress ? goodSustainPress : opponentSustainPress, [note]);
			} else {
				note.strumTime = Conductor.songPosition; // force sick rating (because lag)
				checkCallback(note.mustPress ? goodNoteHit : opponentNoteHit, [note]);
			}
		}
	}

	public function checkMissNote(note:Note) {
		if (note.active) return;
		if (note.mustPress && note.mustHit && !note.isSustainNote)
			checkCallback(noteMiss, [note.noteData%Conductor.NOTE_DATA_LENGTH, note]);
		removeNote(note);
	}

	public function sustainMiss(note:Note) {
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
		notes.forEachAlive(function(daNote:Note) {
			checkCpuNote(daNote);
			checkMissNote(daNote);
		});

        if (isPlayState) {
            if (PlayState.instance.inCutscene) return; // No controls in cutscenes >:(
        }
        controls();
    }

    public var holdingArray:Array<Bool> = [];
	public var controlArray:Array<Bool> = [];

    private function controls():Void {
		holdingArray = [];
		controlArray = [];
		for (i in playerStrums) {
			holdingArray.push(inBotplay ? false : i.getControl());
			controlArray.push(inBotplay ? false : i.getControl("-P"));
			if (inBotplay) return;
		}

		if (generatedMusic) {
			var possibleNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];
			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote) { // Handle sustain notes
					if (daNote.mustPress) {
						daNote.pressed = false;
						if (!daNote.missedPress) {
							if ((Conductor.songPosition > daNote.strumTime + Conductor.safeZoneOffset * daNote.hitMult) && !daNote.startedPress) {
								sustainMiss(daNote);
								return;
							}
							if (daNote.startedPress) {
								var holding = holdingArray[daNote.noteData];
								var pressing = holding && daNote.inSustain && daNote.mustPress;
								if (!holding) { // Sustain stopped being pressed
									sustainMiss(daNote); 
									return;
								}
								else {
									daNote.pressed = pressing; // Pressed sustain
									if (daNote.pressed) checkCallback(goodSustainPress, [daNote]);
								}
							}
						}
					}
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
                        if (controlArray[i] && !ignoreList.contains(i)) checkCallback(badNoteHit);
					}
					for (possibleNote in possibleNotes) {
                        if (controlArray[possibleNote.noteData]) checkCallback(goodNoteHit, [possibleNote]);
					}
				}
				else {
                    checkCallback(badNoteHit);
				}
			}
		}

		checkStrumAnims();
	}

	function checkStrumAnims():Void {
		for (strum in playerStrums) {
			var strumAnim = strum.animation.curAnim;
			if (strumAnim != null) {
				if (strum.getControl("-P") && !strumAnim.name.startsWith('confirm'))
					strum.playStrumAnim('pressed');
				if (!strum.getControl())
					strum.playStrumAnim('static');
			}
		}

        if (!isPlayState) return;
        if (PlayState.instance.boyfriend == null) return;

        var bf = PlayState.instance.boyfriend;
		var overSinging:Bool = (bf.holdTimer > (Conductor.stepCrochetMills * Conductor.STEPS_PER_BEAT)
		&& bf.animation.curAnim.name.startsWith('sing')
		&& !bf.animation.curAnim.name.endsWith('miss'));

		if (overSinging) {
			var isHolding:Bool = false;
			for (strum in playerStrums) {
				if (strum.animation.curAnim.name.startsWith('confirm')) {
					isHolding = true;
					break;
				}
			}
			if (!isHolding)
				bf.dance();
		}
	}

    public function playStrumAnim(data:Int = 0, anim:String = 'confirm', forced:Bool = true):Void {
		var leStrum:NoteStrum = strumLineNotes[data];
		if (leStrum != null) {
			leStrum.playStrumAnim(anim, forced);
			leStrum.staticTime = Conductor.stepCrochetMills;
		}
	}

    inline function getPref(pref:String):Dynamic return Preferences.getPref(pref);
}