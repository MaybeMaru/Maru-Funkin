package funkin.states;

import flixel.addons.ui.FlxUIState;

interface IMusicBeat {
	private var curStep:Int;
	private var curBeat:Int;
	private var curSection:Int;

	private var curStepDecimal:Float;
	private var curBeatDecimal:Float;
	private var curSectionDecimal:Float;

	private function handleSteps():Void;
	private function updateStep():Void;
	private function updateBeat():Void;
	private function updateSection():Void;

	public function stepHit():Void;
	public function beatHit():Void;
	public function sectionHit():Void;
}

class MusicBeatState extends FlxUIState implements IMusicBeat {
	public static var instance:MusicBeatState;
	public static var curState:String;
	public var scriptConsole:ScriptConsole;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curSection:Int = 0;

	private var curStepDecimal:Float = 0;
	private var curBeatDecimal:Float = 0;
	private var curSectionDecimal:Float = 0;

	public var transition(get, default):CustomTransition = null;
	function get_transition() {
		return (transition != null ? transition : transition = new CustomTransition());
	}

	override function create():Void {
		instance = this;
		curState = CoolUtil.formatClass(this, false);
		super.create();
		scriptConsole = new ScriptConsole();
		add(scriptConsole);
		
		add(transition);
		transition.exitTrans();

		//State Scripts
		if (curState == "funkin.states.PlayState") return;
		ModdingUtil.clearScripts();
		var globalStateScripts:Array<String> = ModdingUtil.getScriptList('data/scripts/state');
		var curStateScripts:Array<String> = ModdingUtil.getScriptList('data/scripts/state/${CoolUtil.formatClass(this).split('funkin/states/')[1]}');
		for (script in globalStateScripts.concat(curStateScripts)) ModdingUtil.addScript(script);
		ModdingUtil.addCall('stateCreate', []);
	}

	override function update(elapsed:Float):Void {
		handleSteps();
		ModdingUtil.addCall('stateUpdate', [elapsed]);
		if (FlxG.keys.justPressed.F1) scriptConsole.show = !scriptConsole.show;
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
		ModdingUtil.addCall('stateStepHit', [curStep]);
		if (curStep % Conductor.STEPS_PER_BEAT == 0) {
			beatHit();
		}
	}

	public function beatHit():Void {
		ModdingUtil.addCall('stateBeatHit', [curBeat]);
		if (curBeat % Conductor.BEATS_PER_MEASURE == 0) {
			sectionHit();
		}
	}

	public function sectionHit():Void {
		ModdingUtil.addCall('stateSectionHit', [curSection]);
	}

	//Just a quicker way to get settings
	public function getPref(pref:String):Dynamic		return Preferences.getPref(pref);
	public function getKey(key:String):Dynamic			return Controls.getKey(key);

	public function switchState(newState:FlxState) {
		if (!CustomTransition.skipTrans) openSubState(new TransitionSubstate());
		transition.startTrans(newState);
	}

	public function resetState() {
		if (!CustomTransition.skipTrans) openSubState(new TransitionSubstate());
		transition.startTrans(null, function () FlxG.resetState());
	}
}

class TransitionSubstate extends FlxSubState {
	override function update(elapsed:Float) {
		super.update(elapsed);
		MusicBeatState.instance == null ? return : MusicBeatState.instance.transition == null ? return :
		MusicBeatState.instance.transition.update(elapsed);
	}
}