package funkin.substates;

import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState implements IMusicBeat {
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curSection:Int = 0;

	private var curStepDecimal:Float = 0;
	private var curBeatDecimal:Float = 0;
	private var curSectionDecimal:Float = 0;

	public function new() {
		super();
	}

	public var _update:Dynamic = null;
	override function update(elapsed:Float) {
		if (MusicBeatState.instance != null) MusicBeatState.instance.scriptConsole.update(elapsed);
		handleSteps();
		ModdingUtil.addCall('subStateUpdate', [elapsed]);
		if (_update != null) Reflect.callMethod(null, _update, [elapsed]);
		super.update(elapsed);
	}

	private function handleSteps():Void {
		var oldStep:Int = curStep;
		updateStep();
		updateBeat();
		updateSection();
		if (oldStep != curStep && curStep >= 0) {
			stepHit();
		}
	}

	private function updateSection():Void {
		curSectionDecimal = curBeatDecimal / Conductor.BEATS_PER_MEASURE;
		curSection = Math.floor(curSectionDecimal);
	}

	private function updateBeat():Void {
		curBeatDecimal = curStepDecimal / Conductor.STEPS_PER_BEAT;
		curBeat = Math.floor(curBeatDecimal);
	}

	private function updateStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime) {
				lastChange = Conductor.bpmChangeMap[i];
			}
		}
		curStepDecimal = lastChange.stepTime + (Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet;
		curStep = Math.floor(curStepDecimal);
	}

	public function stepHit():Void {
		ModdingUtil.addCall('subStateStepHit', [curStep]);
		if (curStep % Conductor.STEPS_PER_BEAT == 0) {
			beatHit();
		}
	}

	public function beatHit():Void {
		ModdingUtil.addCall('subStateBeatHit', [curBeat]);
		if (curBeat % Conductor.BEATS_PER_MEASURE == 0) {
			sectionHit();
		}
	}

	public function sectionHit():Void {
		ModdingUtil.addCall('subStateSectionHit', [curSection]);
	}

	//Just a quicker way to get settings
	inline function getPref(pref:String) return Preferences.getPref(pref);
	inline function getKey(key:String) return Controls.getKey(key);
}
