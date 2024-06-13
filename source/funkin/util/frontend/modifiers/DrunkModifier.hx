package funkin.util.frontend.modifiers;

import funkin.util.frontend.modifiers.BasicModifier.Modifiers;

class DrunkModifier extends BasicModifier
{
    public function new() {
        super(DRUNK, true);
    }

    override function manageStrumNote(strum:NoteStrum, note:Note)
    {
        var percent:Float = data[0];
        if (FunkMath.isZero(percent))
            return;

        var speed:Float = data[1];

        var angle = note.distanceToStrum() * speed;
        var sine = percent * FunkMath.sinAngle(angle) * (NoteUtil.noteWidth / 2);

        note.x += sine;
        if (note.child != null) {
            note.child.x += sine;
            note.child.wigglePower = sine * -2; // TODO: make sustains based on points
        }
            
    }

    // [percentage, speed]
    override function getDefaultValues() {
        return [0, 1];
    }
}