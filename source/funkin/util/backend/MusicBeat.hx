package funkin.util.backend;

import flixel.FlxBasic;

class MusicBeat extends FlxBasic {
    public var curStep(default, null):Int = 0;
	public var curBeat(default, null):Int = 0;
	public var curSection(default, null):Int = 0;

	public var curStepDecimal(default, null):Float = 0;
	public var curBeatDecimal(default, null):Float = 0;
	public var curSectionDecimal(default, null):Float = 0;

	public var targetSound:FlxSound = null;
    
	public var hasParent(default, null):Bool = false;
	public var parent(default, set):IMusicGetter = null;
	inline function set_parent(value:IMusicGetter):IMusicGetter {
		hasParent = value != null;
		return parent = value;
	}
	
	public function new(?parent:IMusicGetter) {
        this.parent = parent;
        super();
    }

	var lastStep(default, null):Int = -1;

    override function update(elapsed:Float):Void {
        if (targetSound != null) if (targetSound.playing)
			Conductor.songPosition = targetSound.time - Conductor.latency;
		
		lastStep = curStep;
		
		updateStep();
		updateBeat();
		updateSection();

		if (lastStep != curStep && curStep >= 0) {
			stepHit();
		}

		#if FLX_DEBUG
		FlxG.watch.addQuick("curSection", 	curSection);
		FlxG.watch.addQuick("curBeat", 		curBeat);
		FlxG.watch.addQuick("curStep", 		curStep);
		#end
	}

	private inline function updateSection():Void {
		curSectionDecimal = curBeatDecimal / Conductor.BEATS_PER_MEASURE;
		curSection = Math.floor(curSectionDecimal);
	}

	private inline function updateBeat():Void {
		curBeatDecimal = curStepDecimal / Conductor.STEPS_PER_BEAT;
		curBeat = Math.floor(curBeatDecimal);
	}

	private inline function updateStep():Void {
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

	public inline function stepHit():Void {
		if (hasParent) parent.stepHit(curStep);
        if (curStep % Conductor.STEPS_PER_BEAT == 0) {
			beatHit();
		}
	}

	public inline function beatHit():Void {
		if (hasParent) parent.beatHit(curBeat);
		if (curBeat % Conductor.BEATS_PER_MEASURE == 0) {
			sectionHit();
		}
	}

	public inline function sectionHit():Void {
		if (hasParent) parent.sectionHit(curSection);
	}
}