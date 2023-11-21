package funkin.util.song;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor {
	inline public static var NOTE_DATA_LENGTH:Int = 4;
	inline public static var STRUMS_LENGTH:Int = NOTE_DATA_LENGTH * 2;

	public static var BEATS_PER_MEASURE:Int = 4;
	public static var STEPS_PER_BEAT:Int = 4;
	public static var STEPS_PER_MEASURE:Int = STEPS_PER_BEAT * BEATS_PER_MEASURE;

	public static function setTimeSignature(top:Int = 4, bottom:Int = 4, ?_bpm:Float) { // Is this how it works??
		BEATS_PER_MEASURE = top;
		STEPS_PER_BEAT = bottom;
		set_bpm(_bpm ?? bpm); // Update values
	}

	public static var bpm(default, set):Float = 100;
	public static var crochetMills:Float = 60 / bpm;
	public static var stepCrochetMills:Float = crochetMills / STEPS_PER_BEAT;
	public static var sectionCrochetMills:Float = crochetMills * BEATS_PER_MEASURE;
	public static var crochet:Float = crochetMills * 1000; 					// beats in milliseconds
	public static var stepCrochet:Float = stepCrochetMills * 1000;			// steps in milliseconds
	public static var sectionCrochet:Float = sectionCrochetMills * 1000;	// sections in milliseconds

	public static function set_bpm(value:Float):Float {
		crochetMills = 60 / value;
		stepCrochetMills = crochetMills / STEPS_PER_BEAT;
		sectionCrochetMills = crochetMills * BEATS_PER_MEASURE;
		crochet = crochetMills * 1000;
		stepCrochet = stepCrochetMills * 1000;
		sectionCrochet = sectionCrochetMills * 1000;
		return bpm = value;
	}

	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var settingOffset:Float = 0;
	public static var songOffset:Array<Int> = [0,0];
	public static var songPitch:Float = 1;

	public static var inst(get, default):FlxSound = null;
	static function get_inst() return inst ?? (inst = new FlxSound());
	public static var vocals(get, default):FlxSound = null;
	static function get_vocals() return vocals ?? (vocals = new FlxSound());
	public static var hasVocals:Bool = true;
	
	public static var _loadedSong:String = "";

	public static inline function loadMusic(song:String) {
		song = Song.formatSongFolder(song);
		if (_loadedSong != song) {
			inst.destroy();
			vocals.destroy();
			
			inst = new FlxSound().loadEmbedded(Paths.inst(song));
			inst.persist = true;
			FlxG.sound.list.add(inst);
			hasVocals = Paths.exists(Paths.voices(song, true), MUSIC);
			vocals = hasVocals ? new FlxSound().loadEmbedded(Paths.voices(song)) : new FlxSound();
			vocals.persist = true;
			FlxG.sound.list.add(vocals);
		}
		_loadedSong = song;
		inst.onComplete = function () {}
		vocals.onComplete = function () {}
	}

	public static var safeFrames:Int = 15;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; //safeFrames in milliseconds

	public static function init():Void {
		settingOffset = SaveData.getSave('offset');
	}

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function mapBPMChanges(song:SwagSong):Void {
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		for (i in 0...song.notes.length) {
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM) {
				curBPM = song.notes[i].bpm;
				final event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			final deltaSteps:Int = STEPS_PER_MEASURE;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}

		if (bpmChangeMap.length > 0) {
			bpmChangeMap.insert(0, {
				stepTime: 0,
				songTime: 0,
				bpm: song.bpm
			});
		}
		trace('new BPM map BUDDY $bpmChangeMap');
	}

	public static function getLastBpmChange(?time:Float, ?autoBPM:Float):BPMChangeEvent {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: autoBPM ?? bpm
		}

		time = (time ?? songPosition);
		for (i in bpmChangeMap) {
			if (time >= i.songTime) lastChange = i;
		}

		return lastChange;
	}

	public static var volume(default, set):Float = 1.0;
	static inline function set_volume(value:Float) {
		return volume = inst.volume = vocals.volume = value;
	}

	public static var playing(default, null):Bool = false;

	inline public static function play():Void {
		playing = true;
		inst.play();
		vocals.play();
	}

	inline public static function pause():Void {
		playing = false;
		inst.pause();
		vocals.pause();
	}

	inline public static function stop():Void {
		playing = false;
		inst.stop();
		vocals.stop();
	}

	inline public static function sync():Void {
		soundSync(inst, songOffset[0]);
		if (hasVocals) soundSync(vocals, songOffset[1]);
	}

	public static function soundSync(?sound:FlxSound, offset:Float = 0) {
		if (sound == null) return;
		final playing:Bool = sound.playing;
		sound.pause();
		sound.time = songPosition - offset - settingOffset;
		if (playing) sound.play();
	}

	public static function autoSync(minOff:Int = 40):Void {
		final pitchedMin:Float = minOff * songPitch;
		final syncInst = Math.abs(songPosition - (inst.time + songOffset[0] + settingOffset)) > pitchedMin;
		if (syncInst) soundSync(inst, songOffset[0]);
		if (hasVocals) {
			final syncVocals = Math.abs(songPosition - (vocals.time + songOffset[1] + settingOffset)) > pitchedMin;
			if (syncVocals) soundSync(vocals, songOffset[1]);
		}
	}

	public static function setPitch(pitch:Float = 1, forceVar:Bool = true, forceTime:Bool = true):Void {
		pitch = FlxMath.bound(pitch, 0.25, 2);
		songPitch = (forceVar) ? pitch : songPitch;
		FlxG.timeScale = (forceTime) ? pitch : FlxG.timeScale;
		inst.pitch = pitch;
		if (hasVocals) vocals.pitch = pitch;
	}
}