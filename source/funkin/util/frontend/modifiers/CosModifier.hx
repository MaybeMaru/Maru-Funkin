package funkin.util.frontend.modifiers;

import funkin.util.frontend.modifiers.BasicModifier.Modifiers;

class CosModifier extends BasicModifier
{
    public function new() {
        super(COS, false);
    }

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, timeElapsed:Float) {
        strum.xModchart += (FunkMath.cos((timeElapsed + (data[2] * 0.001)) * data[1]) * data[0]);
    }

    // [size, speed, offset]
    override function getDefaultValues() {
        return [0, 1, 0];
    }
}