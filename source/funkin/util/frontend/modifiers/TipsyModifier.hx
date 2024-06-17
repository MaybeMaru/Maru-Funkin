package funkin.util.frontend.modifiers;

import funkin.util.frontend.ModchartManager.Modifiers;

class TipsyModifier extends BasicModifier
{
    public function new() {
        super(TIPSY, false);
    }

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, beat:Float) {
        var size:Float = data[0];
        if (FunkMath.isZero(size))
            return;
        
        var speed:Float = data[1];
        var period:Float = data[2] * speed;

        strum.yModchart += FunkMath.sin((beatRads(beat, 4) + (strum.noteData * period)) * scale(speed)) * scaleHeight(size);
    }

    // [size, speed, period]
    override function getDefaultValues() {
        return [0.5, 0.5, 0.1];
    }
}