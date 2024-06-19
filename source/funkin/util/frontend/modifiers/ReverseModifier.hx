package funkin.util.frontend.modifiers;

import funkin.objects.note.BasicNote;
import funkin.util.frontend.ModchartManager.Modifiers;

class ReverseModifier extends BasicModifier
{
    public function new() {
        super(REVERSE, true);
        isDownscroll = getPref("downscroll");
    }

    var speedMult:Float = 1;
    var isDownscroll:Bool = false;

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, beat:Float) {
        var value:Float = data[0];
        value = FlxMath.bound(value, 0, 1);

        speedMult = 2 * (0.5 - value);
        
        var offsetY = FlxMath.lerp(0, 525, value);
        if (isDownscroll) offsetY = -offsetY;
        
        strum.yModchart += offsetY;
    }

    override function manageStrumNote(strum:NoteStrum, note:BasicNote)
    {
        note.speedMult *= Math.max(Math.abs(speedMult), 0.001);
        note.approachAngle =( (speedMult < 0) ? (isDownscroll ? 0 : 180) : (isDownscroll ? 180 : 0));
    }

    // [value]
    override function getDefaultValues():Array<Dynamic> {
        return [0.0];
    }
}