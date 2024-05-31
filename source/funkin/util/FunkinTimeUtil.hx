//This is VERY rudamentary, and will likely not work since my ass is so new to this.
//Bear with me here, please.
//- Uberfire F-5

package funkin.util;

class FunkinTimeUtil extends FunkMath
{
    public static var duration:Float = FlxG.sound.music.length;
    public static var currentTime:Float = Math.max(0, Conductor.songPosition);
    public static var entropy:Float = null;
    public static var songLifetime:Float = Math.floor(entropy / 1000);
}