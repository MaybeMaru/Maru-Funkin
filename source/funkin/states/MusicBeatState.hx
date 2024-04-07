package funkin.states;

import flixel.util.typeLimit.OneOfTwo;
import funkin.util.modding.ScriptUtil;
import funkin.util.backend.MusicBeat;
import flixel.addons.ui.FlxUIState;

interface IMusicHit {
	public function stepHit(curStep:Int):Void;
	public function beatHit(curBeat:Int):Void;
	public function sectionHit(curSection:Int):Void;
}

interface IMusicGetter extends IMusicHit {
    /*@:optional*/ public var musicBeat(default, null):MusicBeat;

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

	override function create():Void {
		instance = this;
		curState = CoolUtil.formatClass(this, false);
		super.create();
		add(musicBeat = new MusicBeat(this));

		//State Scripts
		if (!curState.endsWith("PlayState"))
		{
			ModdingUtil.clearScripts();
			final globalStateScripts:Array<String> = ModdingUtil.getScriptList('data/scripts/state');
			final curStateScripts:Array<String> = ModdingUtil.getScriptList('data/scripts/state/${CoolUtil.formatClass(this).split('funkin/states/')[1]}');
			
			globalStateScripts.fastForEach((script, i) -> ModdingUtil.addScript(script));
			curStateScripts.fastForEach((script, i) -> ModdingUtil.addScript(script));
			
			ModdingUtil.addCall('stateCreate');
		}

		if (Main.transition != null)
			Main.transition.exitTrans();
	}

	// Only for backwards compatibility
	public var targetLayer:Layer;
	override function add(basic:FlxBasic):FlxBasic {
		if (targetLayer == null)
			return super.add(basic);

		return targetLayer.add(cast(basic, FlxObject));
	}

	override function draw() {
		if (ScriptUtil.stateQueue != null) {
			CoolUtil.switchState(ScriptUtil.stateQueue.state, ScriptUtil.stateQueue.skipTransOpen, ScriptUtil.stateQueue.skipTransClose);
			ScriptUtil.stateQueue = null;
			if (!Transition.skipTransOpen)
				__superDraw();
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
		
				members.fastForEach((basic, i) -> {
					if (basic != null) if (basic.exists) if (basic.visible)
						basic.draw();
				});
		
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
		
		members.fastForEach((basic, i) -> {
			if (basic != null) if (basic.exists) if (basic.active)
				basic.update(elapsed);
		});
	}

	public function stepHit(curStep:Int):Void {
		members.fastForEach((basic, i) -> {
			if (basic is IMusicHit) {
				if (basic != null) if (basic.exists) if (basic.active)
					cast(basic, IMusicHit).stepHit(curStep);
			}
		});

		
		ModdingUtil.addCall('stateStepHit', [curStep]);
	}

	public function beatHit(curBeat:Int):Void {
		members.fastForEach((basic, i) -> {
			if (basic is IMusicHit) {
				if (basic != null) if (basic.exists) if (basic.active)
					cast(basic, IMusicHit).beatHit(curBeat);
			}
		});

		ModdingUtil.addCall('stateBeatHit', [curBeat]);
	}

	public function sectionHit(curSection:Int):Void {
		members.fastForEach((basic, i) -> {
			if (basic is IMusicHit) {
				if (basic != null) if (basic.exists) if (basic.active)
					cast(basic, IMusicHit).sectionHit(curSection);
			}
		});

		ModdingUtil.addCall('stateSectionHit', [curSection]);
	}

	override function destroy() {
		instance = null;
		ModdingUtil.addCall('stateDestroy');
		super.destroy();
		CoolUtil.gc(true);
	}

	inline public function switchState(newState:FlxState, ?skipStart:Bool, ?skipEnd:Bool) CoolUtil.switchState(newState, skipStart, skipEnd);
	inline public function resetState(?skipStart:Bool, ?skipEnd:Bool) CoolUtil.resetState(skipStart, skipEnd);
	
	public var curStep(get, never):Int; 	inline function get_curStep() return musicBeat.curStep;
	public var curBeat(get, never):Int; 	inline function get_curBeat() return musicBeat.curBeat;
	public var curSection(get, never):Int; 	inline function get_curSection() return musicBeat.curSection;

	public var curStepDecimal(get, never):Float; 	inline function get_curStepDecimal() return musicBeat.curStepDecimal;
	public var curBeatDecimal(get, never):Float; 	inline function get_curBeatDecimal() return musicBeat.curBeatDecimal;
	public var curSectionDecimal(get, never):Float; inline function get_curSectionDecimal() return musicBeat.curSectionDecimal;
}