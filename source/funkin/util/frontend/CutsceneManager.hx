package funkin.util.frontend;

typedef SimpleEvent = {
    var time:Float;
    var callback:Dynamic;
}

class EventHandler extends flixel.FlxBasic {
    public var events:Array<SimpleEvent> = [];
    public var position:Float = 0;
    
    public function pushEvent(time:Float, callback:Dynamic) {
        events.push({
            time: time*1000,
            callback: callback
        });
        events.sort((a, b) -> Std.int(a.time - b.time));
    }

    public function pushStep(step:Int = 0, event:Dynamic) {
        pushEvent(step * Conductor.stepCrochetMills, event);
    }

    public function pushBeat(beat:Int = 0, event:Dynamic) {
        pushEvent(beat * Conductor.crochetMills, event);
    }

    public function pushSection(section:Int = 0, event:Dynamic) {
        pushEvent(section * Conductor.sectionCrochetMills, event);
        //Song.getSectionTime(PlayState.SONG, section) TODO maybe??
    }

    public function start() {
        FlxG.state.add(this);
        active = true;
        _check();
    }

    inline public function pause() {
        active = false;
    }

    inline public function resume() {
        active = true;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        position += elapsed * 1000;
        _check();
    }

    function _check() {
        callEvents();
    }

    function callEvents() {
        if (events[0] != null) {
			while (events.length > 0 && events[0].time <= position) {
                var event = events[0];
                event.callback();
                events.splice(events.indexOf(event), 1);
			}
		}/* else {
            destroy();
        }*/
    }
}

class CutsceneManager extends EventHandler {
    public var targetSound:FlxSound = null;

    public static inline function makeManager(?targetSound:FlxSound) {
        return new CutsceneManager(targetSound);
    }

    override public function start() {
        if (targetSound != null) targetSound.play(true);
        super.start();
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

    override function _check() {
        syncSound();
        callEvents();
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