package funkin.states;

import funkin.util.modding.ScriptUtil;
import funkin.util.backend.MusicBeat;
import flixel.addons.ui.FlxUIState;

interface IMusicGetter {
    /*@:optional*/ public var musicBeat(default, null):MusicBeat;
	public function stepHit(curStep:Int):Void;
	public function beatHit(curBeat:Int):Void;
	public function sectionHit(curSection:Int):Void;

	public var curStep(get, never):Int;
	public var curBeat(get, never):Int;
	public var curSection(get, never):Int;

	public var curStepDecimal(get, never):Float;
	public var curBeatDecimal(get, never):Float;
	public var curSectionDecimal(get, never):Float;
}

class MusicBeatState extends FlxUIState implements IMusicGetter {
	public static var instance:MusicBeatState;
	public static var curState:String;

	public var musicBeat(default, null):MusicBeat;

	public function new() {
		super();
		ScriptUtil.objMap = new Map<String, Dynamic>();
	}

	override function create():Void {
		instance = this;
		curState = CoolUtil.formatClass(this, false);
		super.create();
		add(musicBeat = new MusicBeat(this));
		
		Main.transition.exitTrans();

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
		super.update(elapsed);
	}

	public function stepHit(curStep:Int):Void {
		//callOnObjects('stepHit', [curStep]);
		ModdingUtil.addCall('stateStepHit', [curStep]);
	}

	public function beatHit(curBeat:Int):Void {
		//callOnObjects('beatHit', [curBeat]);
		ModdingUtil.addCall('stateBeatHit', [curBeat]);
	}

	public function sectionHit(curSection:Int):Void {
		//callOnObjects('sectionHit', [curSection]);
		ModdingUtil.addCall('stateSectionHit', [curSection]);
	}

	/*function callOnObjects(func:String, ?args:Array<Dynamic>) {
		var i:Int = 0;
		var getter:Dynamic = null;
		while (i < length) {
			getter = cast members[i++];
			if (getter != null && getter is IMusicGetter && getter != null && getter.exists && getter.active) {
				var _func = cast Reflect.field(getter, func);
				if (_func != null) Reflect.callMethod(getter, _func, args);
			}
		}
	}*/

	override function destroy() {
		instance = null;
		super.destroy();
		CoolUtil.runGc(false); // Minor Gc Clear
	}

	// Some shortcuts
	inline public function getPref(pref:String) return Preferences.getPref(pref);
	inline public function getKey(key:String) 	return Controls.getKey(key);
	inline public function switchState(newState:FlxState, ?skip:Bool) CoolUtil.switchState(newState, skip);
	inline public function resetState(?skip:Bool) CoolUtil.resetState(skip);
	
	public var curStep(get, never):Int; 	inline function get_curStep() return musicBeat.curStep;
	public var curBeat(get, never):Int; 	inline function get_curBeat() return musicBeat.curBeat;
	public var curSection(get, never):Int; 	inline function get_curSection() return musicBeat.curSection;

	public var curStepDecimal(get, never):Float; 	inline function get_curStepDecimal() return musicBeat.curStepDecimal;
	public var curBeatDecimal(get, never):Float; 	inline function get_curBeatDecimal() return musicBeat.curBeatDecimal;
	public var curSectionDecimal(get, never):Float; inline function get_curSectionDecimal() return musicBeat.curSectionDecimal;
}