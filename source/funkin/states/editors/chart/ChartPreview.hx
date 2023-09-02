package funkin.states.editors.chart;
import openfl.geom.Rectangle;

// TODO: FINISH THIS SHIT; ITS 2 AM AND IM TIRED

class ChartPreview extends FlxSpriteExt {
    inline static var NOTE_SIZE:Int = 1;
    public var SONG:SwagSong = null;

    public function new(SONG:SwagSong):Void {
        super(50,100);
        makeGraphic(NOTE_SIZE * Conductor.STRUMS_LENGTH, NOTE_SIZE * Conductor.STEPS_PER_MEASURE, FlxColor.GRAY, true, '_CHART_PREVIEW_');
        antialiasing = false;
        scrollFactor.set();
        this.SONG = SONG;
        
        resetDraw();
        setScale(8);
    }

    public function resetDraw(?section:Int) {
        drawChecks();
        drawPreview(section);
    }

    public function drawChecks() { // Draw checkboard pattern
        var CHECK_SIZE = NOTE_SIZE * Conductor.BEATS_PER_MEASURE;
        for (Y in 0...Std.int(height / CHECK_SIZE)) {
            for (X in 0...Std.int(width / CHECK_SIZE))
                drawRect(X*CHECK_SIZE, Y*CHECK_SIZE, CHECK_SIZE, CHECK_SIZE, [0xff7c7c7c, 0xff6e6e6e][(X+Y)%2]);
        }
    }

    public function drawPreview(?section:Int) {
        if (SONG == null) return;
        if (section != null) {
            var secNotes = SONG.notes[section].sectionNotes;
            var startTime = Song.getSectionTime(SONG, section);
            var endTime = Song.getSectionTime(SONG, section + 1);
            drawSection(secNotes, startTime, endTime);
        }/* else {
            for (i in 0...16) {//SONG.notes.length) {
                var secNotes = SONG.notes[i].sectionNotes;
                var startTime = Song.getSectionTime(SONG, i);
                var endTime = Song.getSectionTime(SONG, i + 1);
                drawSection(secNotes, startTime, endTime);
            }
        }*/
    }

    public function drawSection(notes:Array<Array<Dynamic>>, startTime:Float = 0, endTime:Float = 0) {
        for (n in notes) {
            var note = n.copy();
            var noteColor = getNoteColor(note);
            note[0] -= startTime;
            var noteY = FlxMath.remapToRange(note[0], 0, endTime - startTime, 0, NOTE_SIZE * Conductor.STEPS_PER_MEASURE);
            if (note[2] > 0) { // Draw sustain
                var susY = FlxMath.remapToRange(note[2], 0, endTime - startTime, 0, NOTE_SIZE * Conductor.STEPS_PER_MEASURE);
                drawRect(note[1]*NOTE_SIZE, noteY, NOTE_SIZE, NOTE_SIZE + susY,
                FlxColor.fromRGB(noteColor.red,noteColor.green,noteColor.blue,Std.int(noteColor.alpha*0.6)));
            }
            drawRect(note[1]*NOTE_SIZE, noteY, NOTE_SIZE, NOTE_SIZE, noteColor);
        }
    }

    function drawRect(X:Float,Y:Float,W:Float,H:Float,C:Int) {
        pixels.fillRect(new Rectangle(X, Y, W, H), C);
    }

    var colorMap:Map<String, FlxColor> = [];

    function getNoteColor(note:Array<Dynamic>):FlxColor {
        var key = '${note[3]}-${note[1]%4}';
        if (colorMap.exists(key)) return colorMap.get(key);
        var _skin = NoteUtil.getTypeJson(NoteUtil.getTypeName(note[3])).skin;
        var _colors = SkinUtil.getSkinData(_skin).noteData.noteColorArray;
        var color = FlxColor.fromString(_colors[Std.int(note[1]%4)]);
        colorMap.set(key, color);
        return color;
    }
}