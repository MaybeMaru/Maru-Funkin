package funkin.states.newchart;

class ChartGridContent extends FlxBasic
{
    public var sectionSustains:Array<Array<FlxObject>> = [];
    public var sectionNotes:Array<Array<FlxObject>> = [];
    public var sectionEvents:Array<Array<FlxObject>> = [];
    public var sectionTexts:Array<Array<FlxObject>> = [];

    public var renderSection:Int = 0;
    public var renderRange:Int = 3;

    override function draw():Void
    {
        for (i in 0...renderRange)
        {
            var index:Int = renderSection - 1 + i;

            // Sustains, Notes, Events, Texts
            // For text rendering maybe make a sort for repeating text graphics?
            // To save on bitmaps + batch rendering shit

            if (sectionNotes[index] != null) {
                sectionNotes[index].fastForEach((object, i) -> {
                    if (object != null) if (object.exists) if (object.visible)
                        object.draw();
                });
            }
        }
    }
}