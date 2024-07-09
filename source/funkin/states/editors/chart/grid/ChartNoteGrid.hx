package funkin.states.editors.chart.grid;

import funkin.states.editors.chart.grid.ChartNote.ChartSustain;
import flixel.text.FlxBitmapText;
import funkin.sound.AudioWaveform;

import funkin.states.editors.chart.ChartGridBase.GRID_SIZE;
import funkin.states.editors.chart.ChartGridBase.getGridOverlap;
import funkin.states.editors.chart.ChartGridBase.getGridCoords;

class ChartNoteGrid extends ChartGridBase<ChartNote>
{
    public var instWaveform:AudioWaveform;
    public var voicesWaveform:AudioWaveform;

    public var sustainsGroup:TypedGroup<ChartSustain>;

    override function drawSectionClipping(section:SectionJson, minTime:Float, ?pushArray:Array<ChartNote>) {
        var hasArray:Bool = pushArray != null;
        section.sectionNotes.fastForEach((data, i) ->
        {
            if (data[0] + data[2] >= minTime)
            {
                var note = drawObject(data);
                if (hasArray) {
                    pushArray.push(note);
                }
            }
        });
    }

    override function drawObject(data:Array<Dynamic>):ChartNote
    {
        final strumTime:Float = data[0];
        final noteData:Int = data[1];
        final susLength:Float = data[2];
        
        final noteType:String = NoteUtil.resolveType(data[3]);
        final typeData:NoteTypeJson = NoteUtil.getTypeJson(noteType);

        var pos:FlxPoint = FlxPoint.get(
            grid.x + Math.floor(noteData * GRID_SIZE),
            grid.y + Math.floor(ChartingState.getTimeY(strumTime - sectionTime))
        );

        // Create note
        var note:ChartNote = group.recycle(ChartNote);
        note.init(data, typeData.skin, pos);
        group.add(note);
        
        // Create sustain
        if (susLength > 0) {
            var sustain:ChartSustain = sustainsGroup.recycle(ChartSustain);
            sustain.init(data, typeData.skin, pos, note);
            sustainsGroup.add(sustain);
            note.child = sustain;
        }
        else
        {
            note.child = null;
        }

        // Create type text
        if (typeData.showText) if (noteType != 'default')
        {
            final type:String = (noteType.startsWith('default')) ? noteType.replace('default', '').replace('-','') : noteType;
            if (type.length > 0)
            {
                var text:FlxBitmapText = ChartingState.instance.recycleText();
                text.text = type;
                text.x = pos.x - (text.width - note.width) * .5;
                text.y = pos.y - (text.height - note.height) * .5;
                note.text = text;
            }
        }

        pos.put();

        return note;
    }

    override function equalObjectData(note:ChartNote, data:Array<Dynamic>) {
        if (FunkMath.isZero(note.strumTime - data[0])) if (note.gridNoteData == data[1])
            return note;

        return null;
    }
    
    public function new() {        
        super(8);

        grid.pixels.fillRect(new Rectangle(
            (grid.pixels.width / 2) - 1,
            0,
            2,
            grid.pixels.height
        ), FlxColor.BLACK);

        if (Conductor.inst.stream) {
            var song = Conductor.loadedSong;
            @:privateAccess
            Conductor.loadedSong = "";
            Conductor.loadSong(song);
        }

        // Waveforms
        instWaveform = new AudioWaveform(grid.x, grid.y, grid.width, grid.height, Conductor.inst.sound);
        voicesWaveform = new AudioWaveform(grid.x, grid.y, grid.width, grid.height, Conductor.vocals.sound);
        
        instWaveform.visible = false;
        voicesWaveform.visible = false;

        insert(members.indexOf(group), instWaveform);
        insert(members.indexOf(group), voicesWaveform);
        updateWaveform();

        instWaveform.color = 0x923c70;
        voicesWaveform.color = 0x5e3c92;

        sustainsGroup = new TypedGroup<ChartSustain>();
        insert(members.indexOf(group), sustainsGroup);
    }

    public function updateWaveform():Void
    {
        instWaveform.audioOffset = Conductor.offset[0];
        voicesWaveform.audioOffset = Conductor.offset[1];

        var index = ChartingState.sectionIndex;
        var start = ChartingState.getSecTime(index);
        var end = ChartingState.getSecTime(index + 1);

        instWaveform.setSegment(start, end);
        voicesWaveform.setSegment(start, end);
    }
}