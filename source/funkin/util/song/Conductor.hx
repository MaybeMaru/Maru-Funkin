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
	public static var crochet:Float = ((60 / bpm) * 1000); 	// beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; 		// steps in milliseconds
	public static var sectionCrochet:Float = crochet * 4; 	// sections in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var settingOffset:Float = 0;
	public static var songOffset:Array<Int> = [0,0];
	public static var songPitch:Float = 1;

	public static var safeFrames:Int = 15;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; //safeFrames in milliseconds

	public static function init():Void {
		settingOffset = SaveData.getSave('offset');
	}

	public static function set_bpm(value:Float):Float {
		crochet = (60 / value) * 1000;
		stepCrochet = crochet / 4;
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
		trace('new BPM map BUDDY $bpmChangeMap');
	}

	public static function getLastBpmChange(time:Float = 0):BPMChangeEvent {
		if (bpmChangeMap.length > 0) {
			for (i in 0...bpmChangeMap.length) {
				if (time >= bpmChangeMap[i].songTime)
					return bpmChangeMap[i];
			}
		}
		return {
			stepTime: 0,
			songTime: 0,
			bpm: bpm
		};
	}

	public static function sync(inst:FlxSound, ?vocals:FlxSound):Void {
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

	//	Resync if sounds if they are off by 20 milliseconds by default
	public static function autoSync(inst:FlxSound, ?vocals:FlxSound, minOff:Int = 20):Void {
		var syncInst = Math.abs(songPosition - (inst.time + songOffset[0] + settingOffset)) > minOff * songPitch;
		if (syncInst) soundSync(inst, songOffset[0]);

		if (vocals == null) return;
		var syncVocals = Math.abs(songPosition - (vocals.time + songOffset[1] + settingOffset)) > minOff * songPitch;
		if (syncVocals) soundSync(vocals, songOffset[1]);
	}

	public static function setPitch(pitch:Float = 1, forceVar:Bool = true, forceTime:Bool = true):Void {
		pitch = FlxMath.bound(pitch, 0.25, 2);
		songPitch = (forceVar) ? pitch : songPitch;
		FlxG.timeScale = (forceTime) ? pitch : FlxG.timeScale;
		if (PlayState.game != null) {
			if (PlayState.game.inst != null) 	PlayState.game.inst.pitch = pitch;
			if (PlayState.game.vocals != null) 	PlayState.game.vocals.pitch = pitch;
		}
	}
}