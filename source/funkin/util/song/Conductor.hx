package funkin.util.song;

import haxe.ds.Vector;
import funkin.sound.FlxFunkSound;

class BPMChangeEvent {
	public var stepTime:Int;
	public var songTime:Float;
	public var bpm:Float;
	
	public function new(s:Int, t:Float, b:Float) {
		stepTime = s;
		songTime = t;
		bpm = b;
	}

	public inline function toString():String
		return '(stepTime: $stepTime songTime: $songTime bpm: $bpm)';
}

class Conductor
{
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
		if (bpm != value) {
			crochetMills = 60 / value;
			stepCrochetMills = crochetMills / STEPS_PER_BEAT;
			sectionCrochetMills = crochetMills * BEATS_PER_MEASURE;
			crochet = crochetMills * 1000;
			stepCrochet = stepCrochetMills * 1000;
			sectionCrochet = sectionCrochetMills * 1000;
		}
		return bpm = value;
	}

	public static var songPosition:Float = 0.0;
	public static var latency:Float = 0.0;
	public static var offset:Vector<Int> = Vector.fromArrayCopy([0, 0]);

	public static var hasVocals:Bool = true;
	public static var inst:FlxFunkSound;
	public static var vocals:FlxFunkSound;
	
	public static var loadedSong(default, null):String = "";

	public static function loadSong(song:String)
	{
		if (inst == null) {
			inst = new FlxFunkSound(true);
			vocals = new FlxFunkSound(true);

			inst.persist = true;
			vocals.persist = true;
		}
		
		song = Song.formatSongFolder(song);
		if (loadedSong != song)
		{
			inst.loadSound(Paths.inst(song));
			
			hasVocals = Paths.exists(Paths.voicesPath(song), MUSIC);
			if (hasVocals)
				vocals.loadSound(Paths.voices(song));

			// Reload song file on dispose
			var asset = AssetManager.getAsset(Paths.instPath(song));
			if (asset != null) {
				asset.onDispose = () -> {
					inst.dispose();
					vocals.dispose();
					loadedSong = "";
				}
			}
		}
		loadedSong = song;
		inst.onComplete = null;
		vocals.onComplete = null;
	}

	public static inline var safeFrames:Int = 15;
	public static inline var safeZoneOffset:Float = (safeFrames / 60) * 1000;
	public static inline var safeZoneOffsetMult:Float = 1 / safeZoneOffset;

	public static function init():Void {
		latency = SaveData.getSave('offset');
	}

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function mapBPMChanges(song:SwagSong):Void
	{
		bpmChangeMap.clear();

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		song.notes.fastForEach((section, i) -> {
			if (section.changeBPM) if (section.bpm != curBPM) {
				curBPM = section.bpm;
				bpmChangeMap.push(new BPMChangeEvent(totalSteps, totalPos, curBPM));
			}

			totalSteps += STEPS_PER_MEASURE;
			totalPos += ((60 / curBPM) * 250) * STEPS_PER_MEASURE;
		});

		if (bpmChangeMap.length > 0) {
			bpmChangeMap.unshift(new BPMChangeEvent(0, 0, song.bpm));
			trace('new BPM map BUDDY $bpmChangeMap');
		}
	}

	static final dummyBPMChange = new BPMChangeEvent(0,0,0);

	public static function getLastBpmChange(?time:Float, ?autoBPM:Float):BPMChangeEvent
	{
		var lastChange:BPMChangeEvent = null;
		time ??= songPosition;

		bpmChangeMap.fastForEach((change, i) -> {
			if (time >= change.songTime)
				lastChange = change;
		});

		if (lastChange == null) {
			dummyBPMChange.bpm = autoBPM ?? bpm;
			lastChange = dummyBPMChange;
		}

		return lastChange;
	}

	public static inline function update(elapsed:Float) {
		songPosition = songPosition + (elapsed * 1000);
	}

	public static var volume(default, set):Float = 1.0;
	static inline function set_volume(value:Float) {
		if (inst != null)
			inst.volume = vocals.volume = value;

		return volume = value;
	}

	public static var playing(get, never):Bool;
	inline static function get_playing() return inst != null ? inst.playing : false;

	public static function play():Void {
		if (inst != null) {
			inst.play();
			if (hasVocals) vocals.play();
		}
	}

	public static function stop():Void {
		if (inst != null) {
			inst.stop();
			if (hasVocals) vocals.stop();
		}
	}

	public static function resume():Void {
		if (inst != null) {
			inst.resume();
			if (hasVocals) vocals.resume();
		}
	}

	public static function pause():Void {
		if (inst != null) {
			inst.pause();
			if (hasVocals) vocals.pause();
		}
	}

	public static function sync():Void {		
		soundSync(inst, offset[0]);
		if (hasVocals) soundSync(vocals, offset[1]);
	}

	public static function soundSync(sound:FlxFunkSound, offset:Float = 0) {
		if (sound != null)
			sound.time = songPosition - offset - latency;
	}

	public static function autoSync(maxOff:Float = 40):Void
	{
		maxOff = (maxOff * songPitch);
		
		if (Math.abs(songPosition - (inst.time + offset[0] + latency)) > maxOff)
			soundSync(inst, offset[0]);

		if (hasVocals)
		{
			if (Math.abs(songPosition - (vocals.time + offset[1] + latency)) > maxOff)
				soundSync(vocals, offset[1]);
		}
	}

	public static var songPitch:Float = 1;

	public static function setPitch(pitch:Float = 1, forceVar:Bool = true, forceTime:Bool = true):Void {
		#if !web // idk im workin on it
		pitch = FlxMath.bound(pitch, 0.25, 2);
		songPitch = (forceVar) ? pitch : songPitch;
		FlxG.timeScale = (forceTime) ? pitch : FlxG.timeScale;
		inst.pitch = pitch;
		if (hasVocals) vocals.pitch = pitch;
		#end
	}
}