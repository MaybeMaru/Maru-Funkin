package funkin.util.frontend.modifiers;

import funkin.util.frontend.ModchartManager.Modifiers;

class ShakeModifier extends BasicModifier
{
    public function new() {
        super(SHAKE, false);
    }

    // Force shake running at 24 fps
    var timeElapsed:Float = 0;

    var shakeX:Float = 0;
    var shakeY:Float = 0;

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, beat:Float) {        
        var percent:Float = data[0];
        if (FunkMath.isZero(percent))
            return;

        var speed:Float = data[1];
        timeElapsed += (elapsed * speed);

        while (timeElapsed > (1 / 24)) {
            timeElapsed -= (1 / 24);

            shakeX = FlxG.random.float(-1, 1) * scaleWidth(percent);
            shakeY = FlxG.random.float(-1, 1) * scaleHeight(percent);
        }

        strum.xModchart += shakeX;
        strum.yModchart += shakeY;
    }

    // [percent]
    override function getDefaultValues() {
        return [0.1, 1];
    }
}