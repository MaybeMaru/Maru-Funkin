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

	public function startTransition():Void {} // Called in CoolUtil

	public function new() {
		super();
		ScriptUtil.objMap = new Map<String, Dynamic>();
	}

	override function create():Void {
		instance = this;
		curState = CoolUtil.formatClass(this, false);
		super.create();
		add(musicBeat = new MusicBeat(this));

		//State Scripts
		if (!curState.endsWith("PlayState")) {
			ModdingUtil.clearScripts();
			final globalStateScripts:Array<String> = ModdingUtil.getScriptList('data/scripts/state');
			final curStateScripts:Array<String> = ModdingUtil.getScriptList('data/scripts/state/${CoolUtil.formatClass(this).split('funkin/states/')[1]}');
			for (script in globalStateScripts.concat(curStateScripts)) ModdingUtil.addScript(script);
			ModdingUtil.addCall('stateCreate', []);
		}

		Main.transition.exitTrans();
	}

	override function draw() {
		if (ScriptUtil.stateQueue != null) {
			CoolUtil.switchState(ScriptUtil.stateQueue.state, ScriptUtil.stateQueue.skipTransOpen, ScriptUtil.stateQueue.skipTransClose);
			ScriptUtil.stateQueue = null;
			if (!Transition.skipTransOpen) __superDraw();
		}
		else __superDraw();
	}

	@:noCompletion
	inline private function __superDraw():Void {
		if (persistentDraw) {
			@:privateAccess {
				final oldDefaultCameras = FlxCamera._defaultCameras;
				if (cameras != null)
					FlxCamera._defaultCameras = cameras;
		
				for (i in 0...members.length) {
					final basic:FlxBasic = CoolUtil.unsafeGet(members, i);
					if (basic != null && basic.exists && basic.visible)
						basic.draw();
				}
		
				FlxCamera._defaultCameras = oldDefaultCameras;
			}
		}

		if (subState != null)
			subState.draw();
	}

	override function update(elapsed:Float):Void {
		__superUpdate(elapsed);
	}

	@:noCompletion
	inline private function __superUpdate(elapsed:Float) {
		ModdingUtil.addCall('stateUpdate', [elapsed]);
		for (i in 0...members.length) {
			final basic:FlxBasic = CoolUtil.unsafeGet(members, i);
			if (basic != null && basic.exists && basic.active)
				basic.update(elapsed);
		}
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
		CoolUtil.gc(false);
	}

	// Some shortcuts
	inline public function getPref(pref:String) return Preferences.getPref(pref);
	inline public function getKey(key:String) 	return Controls.getKey(key);
	inline public function switchState(newState:FlxState, ?skipStart:Bool, ?skipEnd:Bool) CoolUtil.switchState(newState, skipStart, skipEnd);
	inline public function resetState(?skipStart:Bool, ?skipEnd:Bool) CoolUtil.resetState(skipStart, skipEnd);
	
	public var curStep(get, never):Int; 	inline function get_curStep() return musicBeat.curStep;
	public var curBeat(get, never):Int; 	inline function get_curBeat() return musicBeat.curBeat;
	public var curSection(get, never):Int; 	inline function get_curSection() return musicBeat.curSection;

	public var curStepDecimal(get, never):Float; 	inline function get_curStepDecimal() return musicBeat.curStepDecimal;
	public var curBeatDecimal(get, never):Float; 	inline function get_curBeatDecimal() return musicBeat.curBeatDecimal;
	public var curSectionDecimal(get, never):Float; inline function get_curSectionDecimal() return musicBeat.curSectionDecimal;
}