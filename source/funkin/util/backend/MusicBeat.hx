package funkin.util.backend;

import flixel.FlxBasic;

class MusicBeat extends FlxBasic
{
    public var curStep(default, null):Int = 0;
	public var curBeat(default, null):Int = 0;
	public var curSection(default, null):Int = 0;

	public var curStepDecimal(default, null):Float = 0;
	public var curBeatDecimal(default, null):Float = 0;
	public var curSectionDecimal(default, null):Float = 0;

	public var targetSound:FlxSound;
	public var parent:IMusicGetter;
	
	public function new(?parent:IMusicGetter) {
        this.parent = parent;
        super();
    }

	var lastStep(default, null):Int = -1;

    override function update(elapsed:Float):Void
	{
        if (targetSound != null) if (targetSound.playing)
			Conductor.songPosition = targetSound.time - Conductor.latency;
		
		lastStep = curStep;
		
		updateStep();
		updateBeat();
		updateSection();

		if (curStep > lastStep) if (curStep > -1) {
			for (i in 0...(curStep - lastStep)) {
				curStep = lastStep + i + 1;
				stepHit();
			}
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

	private inline function updateStep():Void
	{
		var lastStep:Int = 0;
		var lastTime:Float = 0;

		if (Conductor.bpmChangeMap.length > 0)
		{
			Conductor.bpmChangeMap.fastForEach((event, i) -> {
				if (Conductor.songPosition >= event.songTime) {
					lastTime = event.songTime;
					lastStep = event.stepTime;
				}
				else break; // No need to loop through the rest
			});
		}

		curStepDecimal = lastStep + (Conductor.songPosition - lastTime) / Conductor.stepCrochet;
		curStep = Math.floor(curStepDecimal);
	}

	public inline function stepHit():Void {
		if (parent != null) parent.stepHit(curStep);
        if (curStep % Conductor.STEPS_PER_BEAT == 0) {
			beatHit();
		}
	}

	public inline function beatHit():Void {
		if (parent != null) parent.beatHit(curBeat);
		if (curBeat % Conductor.BEATS_PER_MEASURE == 0) {
			sectionHit();
		}
	}

	public inline function sectionHit():Void {
		if (parent != null) parent.sectionHit(curSection);
	}
}