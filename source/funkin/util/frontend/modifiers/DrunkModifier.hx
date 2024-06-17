package funkin.util.frontend.modifiers;

import funkin.objects.note.BasicNote;
import funkin.util.frontend.ModchartManager.Modifiers;

class DrunkModifier extends BasicModifier
{
    public function new() {
        super(DRUNK, true);
    }

    override function manageStrumNote(strum:NoteStrum, note:BasicNote)
    {
        var percent:Float = data[0];
        if (FunkMath.isZero(percent))
            return;

        var speed:Float = data[1];

        // Stole part of this from schmovin because im stupid
		var phaseShift = -note.distanceToStrum() / 222 * FunkMath.PI;
		var offsetX = scaleWidth(FunkMath.sin(phaseShift * speed)) * percent;

        note.x += offsetX;
        //if (note.isSustainNote) {
        //    note.wigglePower = (offsetX * -2) / note.scale.x; // TODO: make sustains based on points
        //}
    }

    // [percentage, speed]
    override function getDefaultValues() {
        return [0.5, 0.75];
    }
}