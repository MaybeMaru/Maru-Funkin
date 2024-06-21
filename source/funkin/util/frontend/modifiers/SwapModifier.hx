package funkin.util.frontend.modifiers;

import funkin.util.frontend.ModchartManager.Modifiers;
import funkin.objects.note.*;

class SwapModifier extends BasicModifier
{
    public function new() {
        super(SWAP, false);
    }

    var otherStrum:NoteStrum;

    // Find the opposite strum of this
    override function init() {
        var id:Int = data[1];
        if (id == -1) {
            for (strumlineId => strumline in manager.strumLines) {
                if (strumline != parentStrumLine) {
                    id = strumlineId;
                    break;
                }
            }
        }

        otherStrum = manager.strumLines.get(id).strums[parentStrum.noteData];
    }

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, beat:Float) {
        var percent:Float = data[0];
        if (FunkMath.isZero(percent))
            return;

        percent = FlxMath.bound(percent, 0, 1);

        var diff = (otherStrum.initPos.x - strum.initPos.x);
        strum.xModchart += FlxMath.lerp(0, diff, percent);
    }

    // [percent, targetStrumline]
    override function getDefaultValues():Array<Dynamic> {
        return [0.0, -1];
    }
}