package funkin.states.editors.chart;
import openfl.geom.Rectangle;

// TODO: FINISH THIS SHIT; ITS 2 AM AND IM TIRED

class ChartPreview extends FlxSpriteExt {
    inline static var NOTE_SIZE:Int = 1;
    public var SONG:SongJson;

    public function new(SONG:SongJson):Void {
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

    static final CHECKBOARD_COLORS:Array<Int> = [0xff7c7c7c, 0xff6e6e6e];

    public function drawChecks() { // Draw checkboard pattern
        final CHECK_SIZE = NOTE_SIZE * Conductor.BEATS_PER_MEASURE;
        for (Y in 0...Std.int(height / CHECK_SIZE)) {
            for (X in 0...Std.int(width / CHECK_SIZE))
                drawRect(X * CHECK_SIZE, Y * CHECK_SIZE, CHECK_SIZE, CHECK_SIZE, CHECKBOARD_COLORS[(X+Y)%2]);
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
        return; // TODO: Fix this later, crash is coming from somewhere in the draw note rect code. Im just lazy
        
        for (i in 0...notes.length) {
            final note = notes[i].copy();
            final noteColor = getNoteColor(note);
            note[0] -= startTime;
            
            final noteX:Float = note[1]*NOTE_SIZE;
            final noteY:Float = FlxMath.remapToRange(note[0], 0, endTime - startTime, 0, NOTE_SIZE * Conductor.STEPS_PER_MEASURE);
            
            if (note[2] > 0) { // Draw sustain
                final susY = FlxMath.remapToRange(note[2], 0, endTime - startTime, 0, NOTE_SIZE * Conductor.STEPS_PER_MEASURE);
                drawRect(noteX, noteY, NOTE_SIZE, NOTE_SIZE + susY,
                FlxColor.fromRGB(noteColor.red,noteColor.green,noteColor.blue,Std.int(noteColor.alpha*0.6)));
            }
            drawRect(noteX, noteY, NOTE_SIZE, NOTE_SIZE, noteColor);
        }
    }

    static final tempRect:Rectangle = new Rectangle();

    function drawRect(X:Float = 0.0, Y:Float = 0.0, W:Float = 0.0, H:Float = 0.0, C:Int = FlxColor.WHITE) {
        tempRect.setTo(X, Y, W, H);
        pixels.fillRect(tempRect, C);
    }

    var colorMap:Map<String, FlxColor> = [];

    function getNoteColor(note:Array<Dynamic>):FlxColor {
        final key =  note[3] + "-" + note[1] % 4;
        if (colorMap.exists(key)) return colorMap.get(key);
        final skin = NoteUtil.getTypeJson(NoteUtil.resolveType(note[3])).skin;
        final colors = SkinUtil.getSkinData(skin).noteData.noteColorArray;
        final color = FlxColorFix.fromString(colors[cast note[1] % 4]);
        colorMap.set(key, color);
        return color;
    }
}