package funkin.substates;

import funkin.util.backend.MusicBeat;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState implements IMusicGetter {
	public var musicBeat(default, null):MusicBeat;
	public function new(createMusic:Bool = true) {
		super();
		if (createMusic)
			add(musicBeat = new MusicBeat(this));
	}

	public var _update:Dynamic = null;
	override function update(elapsed:Float) {
		if (MusicBeatState.instance != null) {
			MusicBeatState.instance.console.update(elapsed);
		}
		
		ModdingUtil.addCall('subStateUpdate', [elapsed]);
		if (_update != null) Reflect.callMethod(null, _update, [elapsed]);
		super.update(elapsed);
	}

	public function stepHit(curStep:Int):Void {
		ModdingUtil.addCall('subStateStepHit', [curStep]);
	}

	public function beatHit(curBeat:Int):Void {
		ModdingUtil.addCall('subStateBeatHit', [curBeat]);
	}

	public function sectionHit(curSection:Int):Void {
		ModdingUtil.addCall('subStateSectionHit', [curSection]);
	}

	// Some shortcuts
	inline public function getPref(pref:String) return Preferences.getPref(pref);
	inline public function getKey(key:String) 	return Controls.getKey(key);
	
	public var curStep(get, never):Int; 	inline function get_curStep() return musicBeat.curStep;
	public var curBeat(get, never):Int; 	inline function get_curBeat() return musicBeat.curBeat;
	public var curSection(get, never):Int; 	inline function get_curSection() return musicBeat.curSection;

	public var curStepDecimal(get, never):Float; 	inline function get_curStepDecimal() return musicBeat.curStepDecimal;
	public var curBeatDecimal(get, never):Float; 	inline function get_curBeatDecimal() return musicBeat.curBeatDecimal;
	public var curSectionDecimal(get, never):Float; inline function get_curSectionDecimal() return musicBeat.curSectionDecimal;
}
