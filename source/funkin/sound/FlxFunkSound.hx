package funkin.sound;

import openfl.events.Event;
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
    @:noCompletion
    public var sound(default, set):Sound;
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
        sound = null; 
    }

    function set_sound(value:Sound):Sound {
        sound = value;
        if (value != null)
        {
            var init:()->Void = () -> {
                length = value.length;
                
                if (stream) {
                    source = new AudioSource(value.__buffer);
                    source.onComplete.add(__soundFinish);
                }
                else {
                    source.buffer = value.__buffer;
                    source.init();
                }

                __initMixer();

                _lastStopTime = 0;

                if (this.onLoad != null)
                    this.onLoad();
            }

            if (value.__urlLoading)
            {
                var onLoad:Event->Void = (e:Event) -> {
                    if (value == e.target)
                        init();
                }
                value.addEventListener(Event.COMPLETE, onLoad, false, 0, true);
            }
            else
            {
                init();
            }
        }
        
        return value;
    }

    public var onComplete:()->Void;
    public var autoDestroy:Bool = false;
    
    private function __soundFinish():Void {        
        if (onComplete != null)
            onComplete();
        
        if (looped) {
            _lastStopTime = 0;
            __play();
        }
        else
        {
            stop();

            if (autoDestroy)
                destroy();
        }
    }

    public var onLoad:()->Void;

    public function loadSound(sound:Sound, ?onLoad:()->Void):FlxFunkSound
    {
        this.onLoad = onLoad;
        this.sound = sound;
        return this;
    }

    public var stream(get, never):Bool;
    inline function get_stream() @:privateAccess return #if (desktop && lime_vorbis) source.__backend.stream; #else false; #end

    public var playing(default, null):Bool = false;
    public var paused(get, never):Bool;
    inline function get_paused():Bool return !playing;

    public var length:Float = 0.0;
    public var time(get, set):Float;
    inline function get_time() return getTime();
    inline function set_time(value:Float) return setTime(value);

    public var pitch(default, set):Float = 1.0;
    inline function set_pitch(value:Float):Float {
        source.pitch = value;
        return pitch = value;
    }

    public var loops(default, set):Int = 0;
    inline function set_loops(value:Int):Int {
        if (value < 1) value = 1;
        return loops = source.loops = value - 1;
    }

    public var looped:Bool = false;
    
    /*public var offset(default, set):Float = 0.0;
    inline function set_offset(value:Float):Float {
        source.offset = Std.int(-value);
        return offset = value;
    }*/
    
    private var _gain:Float = 1.0;
    public var volume:Float = 1.0;

    inline function updateVolume():Void {
        source.gain = FlxG.sound.muted ? 0 : _gain * volume * FlxG.sound.volume;
    }

    public function fadeIn(duration:Float = 1.0, startVolume:Float = 0, ?endVolume:Float):Void {
        endVolume ??= volume;
        volume = startVolume;
        updateVolume();
        fadeOut(duration, endVolume);
    }

    public function fadeOut(duration:Float = 1.0, endVolume:Float = 0):Void {
        FlxTween.tween(this, {volume: endVolume}, duration);
    }

    override function update(elapsed:Float):Void {
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

    public function play(forced:Bool = false):Void {
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

    inline function __play():Void {
        source.play();
        source.currentTime = _lastStopTime;
        playing = true;
    }

    private function __initMixer():Void
    {
        var pan = SoundMixer.__soundTransform.pan + transform.pan;
        if (pan > 1) pan = 1;
        else if (pan < -1) pan = -1;

        var volume = SoundMixer.__soundTransform.volume * transform.volume;
        _gain = volume;
        updateVolume();

        var position = source.position;
        position.x = pan;
        position.z = -Math.sqrt(1 - Math.pow(pan, 2));
        source.position = position;
    }

    var __lastTick:Float = 0;
    var __lastTime:Float = 0;

    // Quick interpolate fix until the ninjamuffin lime pr gets merged
    public function getTime():Float
    {
        final time:Int = source.currentTime;

        if (time != __lastTime) {
            __lastTime = time;
            __lastTick = FlxG.game.ticks;
            return time;
        }

        return time + FlxG.game.ticks - __lastTick;
    }

    public function setTime(time:Float):Float {
        if (time <= 0) if (stream)
            time = 1.0; // hacky fix
        
        source.currentTime = Std.int(time);
        return time;
    }
}