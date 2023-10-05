package funkin.util.frontend;

typedef CutsceneEvent = {
    var time:Float;
    var callback:Dynamic;
}

class CutsceneManager extends flixel.FlxBasic {
    public var targetSound:FlxSound = null;
    public var events:Array<CutsceneEvent> = [];
    public var soundPosition:Float = 0;

    public static function makeManager(?targetSound:FlxSound) {
        var manager:CutsceneManager = new CutsceneManager(targetSound);
        return manager;
    }

    public function start() {
        FlxG.state.add(this);
        if (targetSound != null) targetSound.play(true);
        active = true;
        _check();
    }

    public function pushEvent(time:Float, callback:Dynamic) {
        events.push({
            time: time*1000,
            callback: callback
        });
        events.sort((a, b) -> Std.int(a.time - b.time));
    }

    var startSoundOffset:Float = 0;

    public function setSound(sound:FlxSound) {
        targetSound = sound;
        startSoundOffset = soundPosition;
        targetSound.play(true);
    }

    public function new(?targetSound:FlxSound) {
        super();
        this.targetSound = targetSound;
        if (targetSound != null) {
            targetSound.stop();
        }
        soundPosition = 0;
        active = false;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        soundPosition += elapsed * 1000;
        _check();
    }

    function _check() {
        syncSound();
        callEvents();
    }

    function syncSound() {
        if (targetSound == null || targetSound.time <= 0) return;
        final _time = soundPosition - startSoundOffset;
        final _resync = Math.abs(_time - targetSound.time) > (40 * FlxG.timeScale);
        if (_resync) {
            targetSound.pause();
            targetSound.time = _time;
            targetSound.play();
        }
    }

    function callEvents() {
        if (events[0] != null) {
			while (events.length > 0 && events[0].time <= soundPosition) {
                var event = events[0];
                event.callback();
                events.splice(events.indexOf(event), 1);
			}
		} else {
            destroy();
        }
    }
}