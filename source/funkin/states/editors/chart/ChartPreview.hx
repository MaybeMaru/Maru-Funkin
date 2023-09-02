package funkin.states.editors.chart;
import openfl.geom.Rectangle;

// TODO: FINISH THIS SHIT; ITS 2 AM AND IM TIRED

class ChartPreview extends FlxSpriteExt {
    inline static var NOTE_SIZE:Int = 1;
    public var moveConductor:Bool = true;
    public var SONG:SwagSong = null;

    public function new(moveConductor:Bool = true, SONG:SwagSong):Void {
        super(50,100);
        makeGraphic(NOTE_SIZE * Conductor.STRUMS_LENGTH, NOTE_SIZE * 16, FlxColor.GRAY, true, '_CHART_PREVIEW_');
        antialiasing = false;
        scrollFactor.set();
        this.moveConductor = moveConductor;
        this.SONG = SONG;
        
        drawChecks();
        drawPreview();

        setScale(8);
    }

    inline static var CHECK_SIZE:Int = 4;
    public function drawChecks() {
        for (Y in 0...Std.int(height / CHECK_SIZE)) {
            for (X in 0...Std.int(width / CHECK_SIZE)) {
                drawRect(X*CHECK_SIZE, Y*CHECK_SIZE, CHECK_SIZE, CHECK_SIZE, [0xff7c7c7c, 0xff6e6e6e][(X+Y)%2]);
            }
        }
    }

    public function drawPreview(?section:Int) {
        if (SONG == null) return;
        if (section != null) {
            trace('u dum dum this isnt finished');
        } else {
            for (i in 0...1) {//SONG.notes.length) {
                var secNotes = SONG.notes[i].sectionNotes;
                var startTime = Song.getSectionTime(SONG, i);
                var endTime = Song.getSectionTime(SONG, i + 1);
                drawSection(secNotes, startTime, endTime);
            }
        }
    }

    public function drawSection(notes:Array<Array<Dynamic>>, startTime:Float = 0, endTime:Float = 0) {
        for (n in notes) {
            var note = n.copy();
            var noteColor = getNoteColor(note);
            note[0] -= startTime;
            var noteY = FlxMath.remapToRange(note[0], 0, endTime - startTime, 0, height);
            if (note[2] > 0) { // Draw sustain
                var susY = FlxMath.remapToRange(note[2], 0, endTime - startTime, 0, height);
                drawRect(note[1]*NOTE_SIZE, noteY, NOTE_SIZE, NOTE_SIZE + susY,
                FlxColor.fromRGB(noteColor.red,noteColor.green,noteColor.blue,Std.int(noteColor.alpha*0.6)));
            }
            drawRect(note[1]*NOTE_SIZE, noteY, NOTE_SIZE, NOTE_SIZE, noteColor);
        }
    }

    function drawRect(X:Float,Y:Float,W:Float,H:Float,C:Int) {
        pixels.fillRect(new Rectangle(X, Y, W, H), C);
    }

    function getNoteColor(note:Array<Dynamic>):FlxColor {
        var _skin = NoteUtil.getTypeJson(NoteUtil.getTypeName(note[3])).skin;
        var _colors = SkinUtil.getSkinData(_skin).noteData.noteColorArray;
        return FlxColor.fromString(_colors[Std.int(note[1]%4)]);
    }
}