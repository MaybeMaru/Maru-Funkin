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

        var angle:Float = note.distanceToStrum() * speed;
        var sine:Float = scaleWidth(percent * FunkMath.sinAngle(angle));

        note.x += sine;
        if (note.isSustainNote) {
            note.wigglePower = (sine * -2) / note.scale.x; // TODO: make sustains based on points
        }
    }

    // [percentage, speed]
    override function getDefaultValues() {
        return [0.5, 0.75];
    }
}