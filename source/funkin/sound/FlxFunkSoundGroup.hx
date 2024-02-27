package funkin.sound;

class FlxFunkSoundGroup<T:FlxFunkSound> extends FlxBasic
{
    public var sounds:Array<T> = [];

    override function update(elapsed:Float):Void
    {
        sounds.fastForEach((sound, i) -> {
            if (sound != null)
                sound.update(elapsed);
        });
    }

    // Resumes all sounds set with pausable 
    public function resume():Void @:privateAccess
    {
        sounds.fastForEach((sound, i) -> {
            if (sound != null) if (sound.__resume) {
                sound.__resume = false;
                sound.resume();
            }
        });
    }

    // Pauses all sounds set with pausable 
    public function pause():Void @:privateAccess
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
            splice ? sounds.splice(index, 1) : sounds[index] = null;
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
            sounds[nullIndex] = sound;
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
            if (sound != null) {
                sound.destroy();
                sounds[i] = null;
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