package funkin.sound;

import openfl.events.Event;

@:access(funkin.sound.FlxFunkSound)
class FlxFunkSoundGroup<T:FlxFunkSound> extends FlxBasic
{
    public static var group:FlxFunkSoundGroup<FlxFunkSound>;

    public var sounds:Array<T> = [];

    public function new() {
        super();

        // Window lose focus, pause sounds
        FlxG.stage.addEventListener(Event.DEACTIVATE, (e) -> {
            sounds.fastForEach((sound, i) -> {
                if (sound != null) if (sound.playing) {
                    sound.__gainFocus = true;
                    sound.pause();
                }
            });
        });

        // Window gain focus, resume sounds
        FlxG.stage.addEventListener(Event.ACTIVATE, (e) -> {
            sounds.fastForEach((sound, i) -> {
                if (sound != null) if (sound.__gainFocus) {
                    sound.resume();
                    sound.__gainFocus = false;
                }
            });
        });
    }

    override function update(elapsed:Float):Void
    {
        sounds.fastForEach((sound, i) -> {
            if (sound != null)
                sound.update(elapsed);
        });
    }

    // Resumes all sounds set with pausable 
    public function resume():Void
    {
        sounds.fastForEach((sound, i) -> {
            if (sound != null) if (sound.__resume) {
                sound.__resume = false;
                sound.resume();
            }
        });
    }

    // Pauses all sounds set with pausable 
    public function pause():Void
    {
        sounds.fastForEach((sound, i) -> {
            if (sound != null) if (sound.pausable) if (sound.playing) {
                sound.__resume = true;
                sound.pause();
            }
        });
    }

    // Removes a sound from the group
    public function remove(sound:T, splice:Bool = false):Void
    {
        var index = sounds.indexOf(sound);
        if (index != -1)
        {
            splice ? sounds.splice(index, 1) : sounds.unsafeSet(index, null);
        }
    }

    // Adds a sound to the group
    public function add(sound:T):T
    {
        // Already part of the group, dont add it
        var index = sounds.indexOf(sound);
        if (index != -1) {
            return sound;
        }

        // Get the first null index of the group
        var nullIndex = sounds.indexOf(null);
        if (nullIndex != -1) {
            sounds.unsafeSet(nullIndex, sound);
            return sound;
        }

        // Aight fine, pushing the shit
        sounds.push(sound);
        return sound;
    }

    // Disposes ands sets to null all the sounds inside the group
    public function destroySounds()
    {
        sounds.fastForEach((sound, i) -> {
            if (sound != null) if (!sound.persist) {
                sound.destroy();
                sounds.unsafeSet(i, null);
            }
        });
    }

    override function destroy():Void
    {
        super.destroy();

        destroySounds();
        sounds = null;
    }
}