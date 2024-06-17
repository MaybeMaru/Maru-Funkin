package funkin.util.frontend.modifiers;

import funkin.util.frontend.ModchartManager.Modifiers;

class CosModifier extends BasicModifier
{
    public function new() {
        super(COS, false);
    }

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, beat:Float) {
        var size:Float = data[0];
        if (FunkMath.isZero(size))
            return;

        var speed:Float = scale(data[1]); 
        var offset:Float = data[2];
        
        strum.xModchart += FunkMath.sin((beatRads(beat, 4) + offset) * speed) * scaleWidth(size);
    }

    // [size, speed, offset]
    override function getDefaultValues() {
        return [0.5, 0.5, 0];
    }
}