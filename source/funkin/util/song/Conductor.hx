package funkin.util.song;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor {
	inline public static var NOTE_DATA_LENGTH:Int = 4;
	inline public static var STRUMS_LENGTH:Int = NOTE_DATA_LENGTH * 2;
	inline public static var BEATS_LENGTH:Int = 4;
	inline public static var STEPS_LENGTH:Int = 4;
	inline public static var STEPS_SECTION_LENGTH:Int = STEPS_LENGTH * BEATS_LENGTH;

	public static var bpm(default, set):Float = 100;
	public static var crochetMills:Float = 60 / bpm;
	public static var stepCrochetMills:Float = crochetMills * 0.25;
	public static var sectionCrochetMills:Float = crochetMills * 4;
	public static var crochet:Float = crochetMills * 1000; 					// beats in milliseconds
	public static var stepCrochet:Float = stepCrochetMills * 1000;			// steps in milliseconds
	public static var sectionCrochet:Float = sectionCrochetMills * 1000;	// sections in milliseconds

	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var settingOffset:Float = 0;
	public static var songOffset:Array<Int> = [0,0];
	public static var songPitch:Float = 1;

	public static var inst(get, default):FlxSound = null;
	static function get_inst() return inst == null ? inst = new FlxSound() : inst;
	public static var vocals(get, default):FlxSound = null;
	static function get_vocals() return vocals == null ? vocals = new FlxSound() : vocals;

	public static inline function loadMusic(song:String) {
		inst = new FlxSound().loadEmbedded(Paths.inst(song));
		FlxG.sound.list.add(inst);
		vocals = Paths.exists(Paths.voices(song, true), MUSIC) ? new FlxSound().loadEmbedded(Paths.voices(song)) : new FlxSound();
		FlxG.sound.list.add(vocals);

		inst.onComplete = function () {}
		vocals.onComplete = function () {}
	}

	public static var safeFrames:Int = 15;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; //safeFrames in milliseconds

	public static function init():Void {
		settingOffset = SaveData.getSave('offset');
	}

	public static function set_bpm(value:Float):Float {
		crochetMills = 60 / value;
		stepCrochetMills = crochetMills * 0.25;
		sectionCrochetMills = crochetMills * 4;
		crochet = crochetMills * 1000;
		stepCrochet = stepCrochetMills * 1000;
		sectionCrochet = sectionCrochetMills * 1000;
		return bpm = value;
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
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = STEPS_SECTION_LENGTH;
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

	public static function getLastBpmChange(?time:Float):BPMChangeEvent {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm
		}

		time = (time != null ? time : songPosition);
		for (i in bpmChangeMap) {
			if (time >= i.songTime) lastChange = i;
		}

		return lastChange;
	}

	public static function setVolume(volume:Float = 1.0) {
		inst.volume = volume;
		vocals.volume = volume;
	}

	public static function play():Void {
		inst.play();
		vocals.play();
	}

	public static function pause():Void {
		inst.pause();
		vocals.pause();
	}

	public static function stop():Void {
		inst.stop();
		vocals.stop();
	}

	public static function sync():Void {
		soundSync(inst, songOffset[0]);
		soundSync(vocals, songOffset[1]);
	}

	public static function soundSync(?sound:FlxSound, offset:Float = 0) {
		if (sound == null) return;
		var playing:Bool = sound.playing;
		sound.pause();
		sound.time = songPosition - offset - settingOffset;
		if (playing) sound.play();
	}

	public static function autoSync(minOff:Int = 20):Void {
		var syncInst = Math.abs(songPosition - (inst.time + songOffset[0] + settingOffset)) > minOff * songPitch;
		if (syncInst) soundSync(inst, songOffset[0]);
		var syncVocals = Math.abs(songPosition - (vocals.time + songOffset[1] + settingOffset)) > minOff * songPitch;
		if (syncVocals) soundSync(vocals, songOffset[1]);
	}

	public static function setPitch(pitch:Float = 1, forceVar:Bool = true, forceTime:Bool = true):Void {
		pitch = FlxMath.bound(pitch, 0.25, 2);
		songPitch = (forceVar) ? pitch : songPitch;
		FlxG.timeScale = (forceTime) ? pitch : FlxG.timeScale;
		inst.pitch = pitch;
		vocals.pitch = pitch;
	}
}