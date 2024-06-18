package funkin.util.frontend.modifiers;

import funkin.objects.note.BasicNote;
import funkin.util.frontend.ModchartManager.Modifiers;

class BoostModifier extends BasicModifier
{
    public function new() {
        super(BOOST, true);
    }

    override function manageStrumNote(strum:NoteStrum, note:BasicNote)
    {
        var boost:Float = data[0];
        if (FunkMath.isZero(boost))
            return;

        var startY:Float = data[1];
        var diff:Float = -note.timeToStrum();
        var pos:Float = diff * (0.45 * note.noteSpeed);

        if (pos <= startY)
        {
            var targetTime = startY / (0.45 * note.noteSpeed);
            var mult = (1 - (diff / targetTime)) * boost;
            
            note.speedMult *= Math.max((1 + mult), 0.05);
        }
    }

    // [acceleration, startPosition]
    override function getDefaultValues() {
        return [0.5, 500];
    }
}