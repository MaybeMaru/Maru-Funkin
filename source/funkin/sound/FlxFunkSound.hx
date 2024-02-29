package funkin.sound;

import openfl.Lib;
import openfl.media.SoundMixer;
import lime.media.AudioSource;
import openfl.media.SoundTransform;
import openfl.media.Sound;

/*
 * Copy of FlxSound with some changes
 * Skip sound channel / audio source on-stop disposing
 * Interpolated sound time for more accuracy
**/

@:access(lime.media.AudioSource)
@:access(openfl.media.SoundMixer)
@:access(openfl.media.Sound)
class FlxFunkSound extends FlxBasic
{
    var sound(default, set):Sound;
    var transform:SoundTransform;
    var source:AudioSource;

    public var pausable:Bool = true;
    public var persist:Bool = false; // If sound can be destroyed from the group
    
    var __resume:Bool = false;
    var __gainFocus:Bool = false;

    public function new(addGroup:Bool = true) {
        super();
        source = new AudioSource();
        transform = new SoundTransform();

        source.onComplete.add(__soundFinish);
        
        if (addGroup)
            FlxFunkSoundGroup.group.add(this);
    }

    override function destroy() {
        FlxFunkSoundGroup.group.remove(this);
        source.onComplete.removeAll();
        dispose();
        
        transform = null;
        source = null;
        
        super.destroy();
    }

    public function dispose() {
        source.dispose();
    }

    function set_sound(value:Sound) {
        if (value != null)
        {
            source.buffer = value.__buffer;
            source.init();
            __initMixer();
        }
        
        return sound = value;
    }

    public var onComplete:()->Void;
    
    private function __soundFinish() {        
        if (onComplete != null)
            onComplete();
        
        if (looped) {
            _lastStopTime = 0;
            __play();
        }
        else
        {
            stop();
        }
    }

    public function loadSound(sound:Sound):FlxFunkSound {
        this.sound = sound;
        return this;
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

    public var loops(default, set):Int = 0;
    inline function set_loops(value:Int) {
        if (value < 1) loops = 1;
        return loops = source.loops = value - 1;
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
        source.gain = FlxG.sound.muted ? 0 : _gain * volume * FlxG.sound.volume;
    }

    public function fadeIn(duration:Float = 1.0, startVolume:Float = 0, ?endVolume:Float) {
        endVolume ??= volume;
        volume = startVolume;
        updateVolume();
        fadeOut(duration, endVolume);
    }

    public function fadeOut(duration:Float = 1.0, endVolume:Float = 0) {
        FlxTween.tween(this, {volume: endVolume}, duration);
    }

    override function update(elapsed:Float) {
        updateVolume();
    }

    var _lastStopTime:Int;

    public function stop():Void {
        if (playing) {
            _lastStopTime = Std.int(time);
            source.stop();
            playing = false;
        }
    }

    public function pause():Void {
        if (playing) {
            _lastStopTime = Std.int(time);
            source.pause();
            playing = false;
        }
    }

    public function play(forced:Bool = false) {
        if (forced || !playing) {
            if (forced)
                _lastStopTime = 0;

            __play();
        }
    }

    public function resume():Void {
        if (paused)
            __play();
    }

    inline function __play() {
        source.play();
        source.currentTime = _lastStopTime;
        playing = true;
    }

    private function __initMixer()
    {
        var pan = SoundMixer.__soundTransform.pan + transform.pan;
        if (pan > 1) pan = 1;
        else if (pan < -1) pan = -1;

        var volume = SoundMixer.__soundTransform.volume * transform.volume;
        _gain = volume;
        updateVolume();

        var position = source.position;
        position.x = pan;
        position.z = -1 * Math.sqrt(1 - Math.pow(pan, 2));
        source.position = position;
    }

    var __lastLibTime:Float = 0;
    var __lastTime:Float = 0;

    // Quick interpolate fix until the ninjamuffin lime pr gets merged
    public function getTime():Float
    {
        final time = source.currentTime;

        if (time != __lastTime) {
            __lastTime = time;
            __lastLibTime = Lib.getTimer();
            return time;
        }

        return time + Lib.getTimer() - __lastLibTime;
    }
}