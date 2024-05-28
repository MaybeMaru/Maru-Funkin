package funkin.util.frontend;

import flixel.FlxBasic;

typedef SimpleEvent = {
    var time:Float;
    var callback:()->Void;
}

abstract class EventHandler extends FlxBasic implements IMusicHit
{
    public var events:Array<SimpleEvent> = [];
    public var position:Float = 0;
    
    public function pushEvent(time:Float, callback:()->Void) {
        events.push({
            time: time * 1000,
            callback: callback
        });
        events.sort((a, b) -> Std.int(a.time - b.time));
    }

    // TODO: call events on beatHit() n all that for more accuracy

    public function pushStep(step:Float = 0, callback:()->Void) {
        pushEvent(step * Conductor.stepCrochetMills, callback);
    }

    public function pushBeat(beat:Float = 0, callback:()->Void) {
        pushEvent(beat * Conductor.crochetMills, callback);
    }

    public function pushSection(section:Float = 0, callback:()->Void) {
        pushEvent(section * Conductor.sectionCrochetMills, callback);
    }

    public function new() {
        super();
        pause();
    }

    public function start() {
        active = true;
        callEvents();

        // Fix shit getting added at the wrong times
        FlxG.signals.preUpdate.addOnce(() -> FlxG.state.add(this));
    }

    override function destroy() {
        super.destroy();
        FlxG.state.remove(this);
        pause();
        events.clear();
        events = null;
        position = 0;
    }

    inline public function pause() {
        active = false;
    }

    inline public function resume() {
        active = true;
    }

    public function stepHit(curStep:Int):Void {}

    public function beatHit(curBeat:Int):Void {}

    public function sectionHit(curSection:Int):Void {}
    
    override function update(elapsed:Float)
    {
        updatePosition();
        callEvents();
    }

    function updatePosition() {
        position += (FlxG.elapsed * 1000);
    }

    public var destroyOnComplete:Bool = true;

    function callEvents():Void {
        if (events.length > 0) {
			while (events.length > 0 && events[0].time <= position) {
                events.shift().callback();
			}
		}
        else if (destroyOnComplete) {
            destroy();
        }
    }
}

class CutsceneManager extends EventHandler
{
    public var targetSound:FlxSound;

    public static inline function makeManager(?targetSound:FlxSound) {
        return new CutsceneManager(targetSound);
    }

    override public function start() {
        if (targetSound != null) targetSound.play(true);
        super.start();
    }

    override function destroy() {
        super.destroy();
        if (targetSound != null) {
            targetSound.stop();
            targetSound = null;
        }
    }

    var startSoundOffset:Float = 0;

    public function setSound(sound:FlxSound) {
        targetSound = sound;
        startSoundOffset = position;
        targetSound.play(true);
    }

    public function new(?targetSound:FlxSound) {
        super();
        this.targetSound = targetSound;
        if (targetSound != null) {
            targetSound.stop();
        }
        position = 0;
        active = false;
    }

    override function callEvents() {
        syncSound();
        super.callEvents();
    }

    function syncSound() {
        if (targetSound == null || targetSound.time <= 0) return;
        final _time = position - startSoundOffset;
        final _resync = Math.abs(_time - targetSound.time) > (40 * FlxG.timeScale);
        if (_resync) {
            targetSound.pause();
            targetSound.time = _time;
            targetSound.play();
        }
    }
}