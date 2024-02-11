package funkin.sound;

import openfl.media.SoundMixer;
import lime.media.AudioSource;
import openfl.media.SoundTransform;
import openfl.media.Sound;

@:access(lime.media.AudioSource)
@:access(openfl.media.SoundMixer)
@:access(openfl.media.Sound)
class FlxFunkSound extends FlxBasic
{
    var sound(default, set):Sound;
    var transform:SoundTransform;
    var source:AudioSource;

    public function new() {
        super();
        source = new AudioSource();
        transform = new SoundTransform();

        source.onComplete.add(__soundFinish);
    }

    override function destroy() {
        source.onComplete.removeAll();
        
        transform = null;
        source = null;
        
        super.destroy();
    }

    function set_sound(value:Sound) {
        if (value != null)
        {
            source.buffer = value.__buffer;
            source.init();
        }
        
        return sound = value;
    }

    public var onComplete:()->Void;
    
    private function __soundFinish() {
        if (onComplete != null)
            onComplete();
        
        if (looped)
            play(true);
    }

    public function loadSound(sound:Sound) {
        this.sound = sound;
    }

    public var playing(default, null):Bool = false;
    public var paused(get, never):Bool;
    inline function get_paused() return !playing;

    public var time(get, set):Float;
    inline function get_time() return getTime();
    inline function set_time(value:Float) return source.currentTime = Std.int(value);

    public var pitch(default, set):Float = 1.0;
    inline function set_pitch(value:Float) {
        source.pitch = value;
        return pitch = value;
    }

    public var looped:Bool = false;
    public var offset(default, set):Float = 0.0;
    inline function set_offset(value:Float) {
        source.offset = Std.int(-value);
        return offset = value;
    }
    
    private var _gain:Float = 1.0;
    public var volume:Float = 1.0;

    inline function updateVolume() {
        source.gain = _gain * volume * FlxG.sound.volume;
    }

    override function update(elapsed:Float) {
        updateVolume();
    }

    var lastTime:Int;

    public function stop():Void {
        if (playing) {
            lastTime = Std.int(time);
            source.stop();
            playing = false;
        }
    }

    public function pause():Void {
        if (playing) {
            lastTime = Std.int(time);
            source.pause();
            playing = false;
        }
    }

    public function resume():Void {
        if (paused)
            __play();
    }

    inline function __play() {
        source.play();
        source.currentTime = lastTime;
        playing = true;
    }

    public function play(forced:Bool = false, ?offset:Float, loops:Int = 0) {
        if (sound == null || (playing && !forced))
            return;
        
        var pan = SoundMixer.__soundTransform.pan + transform.pan;
		if (pan > 1) pan = 1;
		else if (pan < -1) pan = -1;

		var volume = SoundMixer.__soundTransform.volume * transform.volume;
        _gain = volume;
        updateVolume();

        if (offset != null)
            this.offset = offset;

        if (loops > 1)
            source.loops = loops - 1;

        if (forced)
            source.currentTime = 0;

		var position = source.position;
		position.x = pan;
		position.z = -1 * Math.sqrt(1 - Math.pow(pan, 2));
		source.position = position;

        __play();
    }

    var __elapsed:Float = 0;
    var __lastTime:Float = 0;

    // Quick interpolate fix until the ninjamuffin lime pr gets merged
    public function getTime():Float
    {
        final time = source.currentTime;

        if (time != __lastTime) {
            __lastTime = time;
            __elapsed = 0;
            return time;
        }

        __elapsed += FlxG.elapsed * 1000;
        return time + __elapsed;
    }
}