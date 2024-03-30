package funkin.util.song;

import funkin.sound.FlxFunkSound;

class BPMChangeEvent {
	public var bpm:Float;
	public var time:Float;
	public var step:Int;
	public function new(bpm, time, step) {this.bpm = bpm; this.time = time; this.step = step;}
}

class Conductor {
	inline public static var NOTE_DATA_LENGTH:Int = 4;
	inline public static var STRUMS_LENGTH:Int = NOTE_DATA_LENGTH * 2;

	public static var BEATS_PER_MEASURE:Int = 4;
	public static var STEPS_PER_BEAT:Int = 4;
	public static var STEPS_PER_MEASURE:Int = STEPS_PER_BEAT * BEATS_PER_MEASURE;

	public static inline function setTimeSignature(top:Int = 4, bottom:Int = 4, ?_bpm:Float) { // Is this how it works??
		BEATS_PER_MEASURE = top;
		STEPS_PER_BEAT = bottom;
		set_bpm(_bpm ?? bpm); // Update values
	}

	public static var crochetMills:Float;
	public static var stepCrochetMills:Float;
	public static var sectionCrochetMills:Float;

	public static var crochet:Float;
	public static var stepCrochet:Float;
	public static var sectionCrochet:Float;

	public static var bpm(default, set):Float;

	public static inline function set_bpm(value:Float):Float {
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

	public static var hasVocals:Bool = true;
	public static var inst:FlxFunkSound;
	public static var vocals:FlxFunkSound;
	
	public static var _loadedSong:String = "";

	public static inline function loadMusic(song:String)
	{
		if (inst == null) {
			inst = new FlxFunkSound(true);
			vocals = new FlxFunkSound(true);

			inst.persist = true;
			vocals.persist = true;
		}
		
		song = Song.formatSongFolder(song);
		if (_loadedSong != song)
		{
			inst.loadSound(Paths.inst(song));
			
			hasVocals = Paths.exists(Paths.voicesPath(song), MUSIC);
			if (hasVocals)
				vocals.loadSound(Paths.voices(song));

			// Reload song file on dispose
			AssetManager.getAsset(Paths.instPath(song)).onDispose = () -> {
				inst.dispose();
				vocals.dispose();
				_loadedSong = "";
			}
		}
		_loadedSong = song;
		inst.onComplete = null;
		vocals.onComplete = null;
	}

	public static inline var safeFrames:Int = 15;
	public static inline var safeZoneOffset:Float = (safeFrames / 60) * 1000;
	public static inline var safeZoneOffsetMult:Float = 1 / safeZoneOffset;

	public static function init():Void {
		settingOffset = SaveData.getSave('offset');
	}

	public static var BPMChanges:Array<BPMChangeEvent>;

	public static function mapBPMChanges(song:Song):Array<BPMChangeEvent> {
		BPMChanges = new Array<BPMChangeEvent>();

		var BPM = song.BPM;
		var time = 0.0;
		var step = 0;

		song.sections.fastForEach((section, i) ->
		{
			if (section.changeBPM) if (section.bpm != BPM) {
				BPM = section.bpm;
				BPMChanges.push(new BPMChangeEvent(BPM, time, step));
			}

			step += STEPS_PER_MEASURE;
			time += ((60 / BPM) * 250) * STEPS_PER_MEASURE;
		});

		// If the song contains BPM changes, add an init BPM change for good measure
		if (BPMChanges.length > 0)
		{
			BPMChanges.push(new BPMChangeEvent(song.bpm, 0, 0));
			trace("new BPM map BUDDY " + BPMChanges);
		}

		return BPMChanges;
	}

	public static function getLastBPMChange(?songTime:Float, ?autoBPM:Float):BPMChangeEvent
	{
		if (BPMChanges.length > 0) {
			BPMChanges.fastForEach((change, i) -> {
				if (songTime >= change.time)
					return change;
			});
		}

		return new BPMChangeEvent(autoBPM ?? bpm, 0, 0);
	}

	public static var volume(default, set):Float = 1.0;
	static inline function set_volume(value:Float) {
		if (inst != null)
			inst.volume = vocals.volume = value;

		return volume = value;
	}

	public static var playing(default, null):Bool = false;

	inline public static function play():Void {
		playing = true;
		if (inst != null)
		{
			inst.play();
			if (hasVocals) vocals.play();
		}
	}

	inline public static function pause():Void {
		playing = false;
		if (inst != null)
		{
			inst.pause();
			if (hasVocals) vocals.pause();
		}
	}

	inline public static function stop():Void {
		playing = false;
		if (inst != null)
		{
			inst.stop();
			if (hasVocals) vocals.stop();
		}
	}

	public static function sync():Void {
		soundSync(inst, songOffset[0]);
		if (hasVocals) soundSync(vocals, songOffset[1]);
	}

	public static function soundSync(?sound:FlxFunkSound, offset:Float = 0) {
		if (sound != null)
			sound.time = songPosition - offset - settingOffset;
	}

	public static function autoSync(maxOff:Int = 40):Void {
		var maxOff = maxOff * songPitch;
		
		var offInst = songOffset[0];
		var syncInst = Math.abs(songPosition - (inst.time + offInst + settingOffset)) > maxOff;
		if (syncInst)
			soundSync(inst, offInst);

		if (hasVocals)
		{
			var offVocs = songOffset[1];
			var syncVocs = Math.abs(songPosition - (vocals.time + offVocs + settingOffset)) > maxOff;
			if (syncInst)
				soundSync(vocals, offVocs);
		}
	}

	public static var songPitch:Float = 1;

	public static function setPitch(pitch:Float = 1, forceVar:Bool = true, forceTime:Bool = true):Void {
		pitch = FlxMath.bound(pitch, 0.25, 2);
		songPitch = (forceVar) ? pitch : songPitch;
		FlxG.timeScale = (forceTime) ? pitch : FlxG.timeScale;
		inst.pitch = pitch;
		if (hasVocals) vocals.pitch = pitch;
	}
}