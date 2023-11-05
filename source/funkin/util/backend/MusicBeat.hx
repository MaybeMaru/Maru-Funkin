package funkin.util.backend;

interface IMusicBeat {
	public var curStep(default, null):Int;
	public var curBeat(default, null):Int;
	public var curSection(default, null):Int;

	public var curStepDecimal(default, null):Float;
	public var curBeatDecimal(default, null):Float;
	public var curSectionDecimal(default, null):Float;

	private function updateStep():Void;
	private function updateBeat():Void;
	private function updateSection():Void;

	public function stepHit():Void;
	public function beatHit():Void;
	public function sectionHit():Void;
}

enum abstract MusicBeatEvent(Int) {
    var STEP_EVENT = 0;
    var BEAT_EVENT = 1;
    var SECTION_EVENT = 2;
}

class MusicBeat extends flixel.FlxBasic implements IMusicBeat {
    public var curStep(default, null):Int = 0;
	public var curBeat(default, null):Int = 0;
	public var curSection(default, null):Int = 0;

	public var curStepDecimal(default, null):Float = 0;
	public var curBeatDecimal(default, null):Float = 0;
	public var curSectionDecimal(default, null):Float = 0;

	public var targetSound:FlxSound = null;
    public var parent:IMusicGetter = null;
    public function new(?parent:IMusicGetter) {
        this.parent = parent;
        super();
    }

    override function update(elapsed:Float):Void {
        if (targetSound != null && targetSound.playing) {
			Conductor.songPosition = targetSound.time - Conductor.settingOffset;
		}
		
		final oldStep:Int = curStep;
		updateStep();
		updateBeat();
		updateSection();
		if (oldStep != curStep && curStep >= 0) {
			stepHit();
		}
        super.update(elapsed);
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
        event(STEP_EVENT);
        if (curStep % Conductor.STEPS_PER_BEAT == 0) {
			beatHit();
		}
	}

	public inline function beatHit():Void {
        event(BEAT_EVENT);
		if (curBeat % Conductor.BEATS_PER_MEASURE == 0) {
			sectionHit();
		}
	}

	public inline function sectionHit():Void {
        event(SECTION_EVENT);
	}

    private inline function event(event:MusicBeatEvent) {
        switch (event) {
            case STEP_EVENT:    parent.stepHit(curStep);
            case BEAT_EVENT:    parent.beatHit(curBeat);
            case SECTION_EVENT: parent.sectionHit(curSection);
        }
    }
}