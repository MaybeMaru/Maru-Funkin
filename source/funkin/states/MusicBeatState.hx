package funkin.states;

import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState {
	public static var instance:MusicBeatState;
	public static var curState:String;
	public var scriptConsole:ScriptConsole;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curSection:Int = 0;

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
		
		var topCam = CoolUtil.getTopCam();
		if (topCam != null) transition.cameras = [topCam];
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
		updateCurStep();
		updateBeat();
		updateSection();
		if (oldStep != curStep && curStep >= 0) {
			stepHit();
		}
	}

	private function updateSection():Void {
		curSection = Math.floor(curBeat / Conductor.BEATS_LENGTH);
	}

	private function updateBeat():Void {
		curBeat = Math.floor(curStep / Conductor.BEATS_LENGTH);
	}

	private function updateCurStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.songPosition - Conductor.settingOffset >= Conductor.bpmChangeMap[i].songTime) {
				lastChange = Conductor.bpmChangeMap[i];
			}
		}
		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - Conductor.settingOffset - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void {
		ModdingUtil.addCall('stateStepHit', [curStep]);
		if (curStep % Conductor.BEATS_LENGTH == 0) {
			beatHit();
		}
	}

	public function beatHit():Void {
		ModdingUtil.addCall('stateBeatHit', [curBeat]);
		if (curBeat % Conductor.BEATS_LENGTH == 0) {
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