package funkin.util.frontend.modifiers;

import funkin.util.frontend.ModchartManager.Modifiers;

class BeatModifier extends BasicModifier
{
    public function new() {
        super(BEAT, false);
    }

    function getAmplitude(currentBeat:Float)
    {
        var beat = currentBeat % 1;
        var amp:Float = 0;
        if (beat <= 0.3)
            amp = FlxEase.quadIn((0.3 - beat) / 0.3) * 0.3;
        else if (beat >= 0.7)
            amp = -FlxEase.quadOut((beat - 0.7) / 0.3) * 0.3;
        var neg = 1;
        if (currentBeat % 2 >= 1)
            neg = -1;
        return amp / 0.3 * neg;
    }

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, beat:Float) {
        var size:Float = data[0];
        if (FunkMath.isZero(size))
            return;

        strum.xModchart += scaleWidth(getAmplitude(Math.abs(beat))) * size;
    }

    // [size]
    override function getDefaultValues() {
        return [0.5];
    }
}