package funkin.states;

import funkin.util.backend.MusicBeat;
import flixel.addons.ui.FlxUIState;

interface IMusicGetter {
    public var musicBeat(default, null):MusicBeat;
	public function stepHit(curStep:Int):Void;
	public function beatHit(curBeat:Int):Void;
	public function sectionHit(curSection:Int):Void;
}

class MusicBeatState extends FlxUIState implements IMusicGetter {
	public static var instance:MusicBeatState;
	public static var curState:String;
	public var scriptConsole:ScriptConsole;

	public var transition(get, default):CustomTransition = null;
	function get_transition() {
		return (transition != null ? transition : transition = new CustomTransition());
	}

	public var musicBeat(default, null):MusicBeat;
	override function create():Void {
		instance = this;
		curState = CoolUtil.formatClass(this, false);
		super.create();
		add(musicBeat = new MusicBeat(this));
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
		ModdingUtil.addCall('stateUpdate', [elapsed]);
		if (FlxG.keys.justPressed.F1) scriptConsole.show = !scriptConsole.show;
		super.update(elapsed);
	}

	public function stepHit(curStep:Int):Void {
		ModdingUtil.addCall('stateStepHit', [curStep]);
	}

	public function beatHit(curBeat:Int):Void {
		ModdingUtil.addCall('stateBeatHit', [curBeat]);
	}

	public function sectionHit(curSection:Int):Void {
		ModdingUtil.addCall('stateSectionHit', [curSection]);
	}

	public function switchState(newState:FlxState) {
		if (!CustomTransition.skipTrans) openSubState(new TransitionSubstate());
		transition.startTrans(newState);
	}

	public function resetState() {
		if (!CustomTransition.skipTrans) openSubState(new TransitionSubstate());
		transition.startTrans(null, function () FlxG.resetState());
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

class TransitionSubstate extends FlxSubState {
	override function update(elapsed:Float) {
		super.update(elapsed);
		MusicBeatState.instance == null ? return : MusicBeatState.instance.transition == null ? return :
		MusicBeatState.instance.transition.update(elapsed);
	}
}