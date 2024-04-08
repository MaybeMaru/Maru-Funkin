package funkin.states.newchart;

class ChartNote extends Group
{
    var note:Note;
    var sustain:Sustain;

    var hasSustain:Bool;
    
    public function new(noteData:Int, susLength:Float, downscroll:Bool) {
        super();

        note = new Note(0);
        note.setGraphicSize(40, 40);
        note.updateHitbox();

        hasSustain = (susLength > 0);

        if (hasSustain)
        {
            sustain = new Sustain(0);
            sustain.setScale(note.scale.x);
            add(sustain);

            sustain.setTiles(1, 1);
            sustain.repeatHeight = FlxMath.remapToRange(susLength, 0, Conductor.stepCrochet, 0, 40) + 20;

            sustain.offset.y = 0;
            sustain.offset.x -= (20 - (sustain.width * 0.5));
            sustain.origin.set((sustain.width * .5) / sustain.scale.x, 0);

            sustain.approachAngle = downscroll ? 180 : 0;
        }

        add(note);
        set(noteData);
    }

    public function setPos(x:Float, y:Float):Void
    {
        note.setPosition(x, y);
        if (hasSustain)
            sustain.setPosition(x, y + 20);
    }

    public function set(noteData:Int):Void
    {
        noteData %= 4;
        note.noteData = noteData;
        note.updateAnim();

        if (hasSustain)
            sustain.noteData = noteData;
    }
}