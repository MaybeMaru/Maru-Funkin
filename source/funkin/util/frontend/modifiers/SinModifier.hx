package funkin.util.frontend.modifiers;

import funkin.util.frontend.modifiers.BasicModifier.Modifiers;

class SinModifier extends BasicModifier
{
    public function new() {
        super(SIN, false);
    }

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, timeElapsed:Float) {
        strum.yModchart += (FunkMath.sin((timeElapsed + (data[2] * 0.001)) * data[1]) * data[0]);
    }

    // [size, speed, offset]
    override function getDefaultValues() {
        return [0, 0, 0];
    }
}