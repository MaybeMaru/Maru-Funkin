package funkin.objects;

class NotesGroup extends FlxGroup
{
    public var SONG:SwagSong;

    public static var songSpeed:Float = 1.0;
    public var curSong:String = 'test';
    public var songNotetypes:Array<String> = [];

	public var generatedMusic:Bool = false;

    public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var strumLine:FlxSprite;

    public var skipStrumIntro:Bool = false;
    public var strumLineNotes:FlxTypedGroup<NoteStrum>;
	public var playerStrums:FlxTypedGroup<NoteStrum>;
	public var opponentStrums:FlxTypedGroup<NoteStrum>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var strumLineInitPos:Array<FlxPoint> = [];
	public var playerStrumsInitPos:Array<FlxPoint> = [];
	public var opponentStrumsInitPos:Array<FlxPoint> = [];

    public var inBotplay:Bool = false;
	public var isPlayState:Bool = true;
    
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
			notes.remove(note, true);
			note.destroy();

			if (CoolUtil.getNoteJudgement(CoolUtil.getNoteDiff(note)) == 'sick') {
				var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
				splash.setupNoteSplash(note.x, note.y, note.noteData, note);
				grpNoteSplashes.add(splash);
			}
		}
		goodSustainPress = function (note:Note) {
			playerStrums.members[note.noteData].playStrumAnim('confirm', true);
		}
		opponentNoteHit = function (note:Note) {
			playStrumAnim(note.noteData%Conductor.NOTE_DATA_LENGTH);
			notes.remove(note, true);
			note.destroy();
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
        strumLine = new FlxSprite(0, !getPref('downscroll') ? 50 : FlxG.height - 150).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		strumLineNotes = new FlxTypedGroup<NoteStrum>();
		add(strumLineNotes);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		add(grpNoteSplashes);
		cacheSplash();
		playerStrums = new FlxTypedGroup<NoteStrum>();
		opponentStrums = new FlxTypedGroup<NoteStrum>();
		for (i in 0...2) generateStrums(i);

        //Make Song
		Conductor.songPosition = startPos;
		generateSong();
    }

    private function generateStrums(p:Int):Void {
		var startX:Float = NoteUtil.swagWidth * 0.666 + (FlxG.width / 2) * p;
		var startY:Float = strumLine.y;
		var offsetY:Float = getPref('downscroll') ? 10 : -10;
        var isPlayer:Bool = p == 1;
		
		for (i in 0...Conductor.NOTE_DATA_LENGTH) {
			var strumX:Float = startX + (NoteUtil.swagWidth + 5) * i;
			var strumNote:NoteStrum = new NoteStrum(strumX, startY, i);
			strumNote.ID = i;
			strumNote.updateHitbox();
			strumNote.scrollFactor.set();
			strumLineNotes.add(strumNote);
			strumLineInitPos.push(strumNote.getPosition());
			(isPlayer ? playerStrums : opponentStrums).add(strumNote);
			(isPlayer ? playerStrumsInitPos : opponentStrumsInitPos).push(strumNote.getPosition());
			
			if (!skipStrumIntro) {
				strumNote.alpha = 0;
				strumNote.y += offsetY;
			}

			ModdingUtil.addCall('generateStrum', [strumNote, isPlayer]);
		}
	}

	private function generateSong():Void {
		var songData:SwagSong = SONG;
		ModdingUtil.addCall('generateSong', [songData]);

		unspawnNotes = [];
		notes = new FlxTypedGroup<Note>();
		add(notes);
	
		var noteData:Array<SwagSection> = songData.notes;
		curSong = songData.song;

        Conductor.loadMusic(curSong);
		Conductor.bpm = songData.bpm;
	
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var strumTime:Int = songNotes[0];
				var sustainLength = songNotes[2];
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
						unspawnNotes.push(newSustain);
					}
					else newSustain.destroy();  // clear too small sustains
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

    public var goodNoteHit:Dynamic = null;
    public var goodSustainPress:Dynamic = null;
    public var noteMiss:Dynamic = null;
    public var badNoteHit:Dynamic = null;
    
    public var opponentNoteHit:Dynamic = null;
    public var opponentSustainPress:Dynamic = null;

    public function checkCallback(callback:Dynamic, ?args:Array<Dynamic>) {
        if (callback != null) Reflect.callMethod(this, callback, args != null ? args : []); // Prevent null
    }

    //Makes the conductor song go vroom vroom
    function updateConductor(elapsed:Float = 0) {
		if (Conductor.inst.playing) {
			if (Conductor.songPosition - SONG.offsets[1] >= Conductor.vocals.length) { // Prevent repeating vocals
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

        var game = PlayState.game;
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

    override function update(elapsed:Float) {
        super.update(elapsed);
        updateConductor(elapsed);

		if (!generatedMusic) return; // Stuff that needs notes
		spawnNotes();

		notes.forEachAlive(function(daNote:Note) {
			// Manage botplay notes
			if (inBotplay) {
				if (daNote.mustPress) {
					if (Conductor.songPosition >= daNote.strumTime && daNote.mustHit) {
						if (daNote.isSustainNote) {
							daNote.pressed = daNote.inSustain;
                               if (daNote.pressed) checkCallback(goodSustainPress, [daNote]);
						} else {
							daNote.strumTime = Conductor.songPosition; // force sick rating (because lag)
                               checkCallback(goodNoteHit, [daNote]);
						}
					}
				}
			}

			// Manage opponent notes
			if (!daNote.mustPress) {
				if (Conductor.songPosition >= daNote.strumTime && daNote.mustHit) {
					if (daNote.isSustainNote) {
						daNote.pressed = daNote.inSustain ;
                        if (daNote.pressed) checkCallback(opponentSustainPress, [daNote]);
					} else {
                        checkCallback(opponentNoteHit, [daNote]);
                    }
				}
			}

			//Remove missed Notes
			if (!daNote.active) {
				if (daNote.mustPress && daNote.mustHit) {
                    checkCallback(noteMiss, [daNote.noteData%Conductor.NOTE_DATA_LENGTH, daNote]);
				}
				notes.remove(daNote, true);
				daNote.destroy();
			}
		});

        if (isPlayState) {
            if (PlayState.game.inCutscene) return; // No controls in cutscenes >:(
        }
        controls();
    }

	public static var defaultHold = [false,false,false,false];
    public var holdingArray:Array<Bool> = [false,false,false,false];
	public var controlArray:Array<Bool> = [false,false,false,false];

    private function controls():Void {
		holdingArray = defaultHold.copy();
		controlArray = defaultHold.copy();
		if (inBotplay) return;
		
		holdingArray = Controls.getNoteKeys();
		controlArray = Controls.getNoteKeys('-P');

		if (generatedMusic) {
			var possibleNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];
			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote) { // Handle sustain notes
					daNote.pressed = holdingArray[daNote.noteData] && daNote.inSustain && daNote.mustPress;
                    if (daNote.pressed) checkCallback(goodSustainPress, [daNote]);
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
				if (controlArray[strum.noteData] && !strumAnim.name.startsWith('confirm'))
					strum.playStrumAnim('pressed');
				if (!holdingArray[strum.noteData])
					strum.playStrumAnim('static');
			}
		}

        if (!isPlayState) return;
        if (PlayState.game.boyfriend == null) return;

        var bf = PlayState.game.boyfriend;
		var overSinging:Bool = (bf.holdTimer > (Conductor.stepCrochetMills * Conductor.STEPS_LENGTH)
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
		var leStrum:NoteStrum = strumLineNotes.members[data];
		if (leStrum != null) {
			leStrum.playStrumAnim(anim, forced);
			leStrum.staticTime = Conductor.stepCrochet/1000;
		}
	}

    function getPref(pref:String):Dynamic return Preferences.getPref(pref);
    function getKey(key:String):Bool return Controls.getKey(key);
}