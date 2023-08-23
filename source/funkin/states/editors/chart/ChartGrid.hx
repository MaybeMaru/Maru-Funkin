package funkin.states.editors.chart;

import flixel.addons.display.FlxGridOverlay;

class ChartGrid extends FlxTypedGroup<Dynamic> {
    inline public static var GRID_SIZE:Int = 40;
    
    public var grid:FlxSprite;
    public var notesGroup:FlxTypedGroup<ChartNote>;
    public var sustainsGroup:FlxTypedGroup<ChartNote>;
    public var textGroup:FlxTypedGroup<FunkinText>;
    public var waveform:ChartWaveform;
    
    public function new() {
        super();
        grid = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE,  GRID_SIZE * Conductor.STRUMS_LENGTH, GRID_SIZE * Conductor.STEPS_SECTION_LENGTH, true, 0xff7c7c7c, 0xff6e6e6e);
        grid.pixels.fillRect(new Rectangle(grid.width / 2 - 1, 0, 2, grid.height), FlxColor.BLACK);
        grid.screenCenter();
        add(grid);

        waveform = new ChartWaveform(Conductor.hasVocals ? Conductor.vocals : Conductor.inst);
        add(waveform);

        notesGroup = new FlxTypedGroup<ChartNote>();
        sustainsGroup = new FlxTypedGroup<ChartNote>();
        textGroup = new FlxTypedGroup<FunkinText>();
        add(sustainsGroup);
        add(notesGroup);
        add(textGroup);

        updateWaveform();
    }

    public function updateWaveform() {
        waveform.soundOffset = Conductor.songOffset[Conductor.hasVocals ? 1 : 0];
        waveform.updateWaveform();
        waveform.setPosition(grid.x, grid.y);
    }

    public var sectionData(default, set):SwagSection;
    public var sectionIndex:Int = 0;
    public var sectionTime:Float = 0;

    public function set_sectionData(value:SwagSection):SwagSection {
        clearSection();
        for (i in value.sectionNotes) {
            drawNote(i);
        }
        return sectionData = value;
    }

    public function setData(sectionData:SwagSection, sectionIndex:Int = 0) {
        this.sectionIndex = sectionIndex;
        sectionTime = ChartingState.getSecTime(sectionIndex);
        this.sectionData = sectionData;
    }

    public function clearNote(note:ChartNote) {
        note.kill();
        if (note.childNote != null) note.childNote.kill();
        if (note.txt != null) note.txt.kill();
    }

    public function clearSection() {
        for (i in notesGroup) {
            clearNote(i);
        }
    }

    public function getNoteData(note:ChartNote):Array<Dynamic> {
        for (i in sectionData.sectionNotes) {
            if (Math.floor(note.strumTime) == Math.floor(i[0]) && i[1] == note.gridNoteData) {
                return i;
            }
        }
        return null;
    }

    public function getNoteObject(note:Array<Dynamic>):ChartNote {
        for (i in notesGroup) {
            if (Math.floor(note[0]) == Math.floor(i.strumTime) && note[1] == i.gridNoteData) {
                return i;
            }
        }
        return null;
    }

    public function updateNote(note:ChartNote, ?data:Array<Dynamic>) {
        var _data = (data != null ? data : getNoteData(note));
        clearNote(note);
        drawNote(_data);
    }

    public function drawNote(note:Array<Dynamic>):ChartNote {
        var strumTime:Float = note[0];
        var noteData:Int = note[1];
        var susLength:Float = note[2];
        var noteType:String = NoteUtil.getTypeName(note[3]);
        var typeData:NoteTypeJson = NoteUtil.getTypeJson(noteType);

        var gridPos = new FlxPoint(grid.x + Math.floor(noteData * GRID_SIZE), grid.y + Math.floor(ChartingState.getTimeY(strumTime - sectionTime)));

        var _note:ChartNote = notesGroup.recycle(ChartNote);
        _note.init(strumTime, noteData, gridPos.x, gridPos.y, 0, typeData.skin);

        var susNote:ChartNote = null;
        if (susLength > 0) {
            susNote = sustainsGroup.recycle(ChartNote);
            susNote.init(strumTime, noteData, gridPos.x, gridPos.y, susLength, typeData.skin, true, _note);
            sustainsGroup.add(susNote);
        }

        if (typeData.showText) {
            var typeStr:String = (noteType.startsWith('default')) ? noteType.split('default')[1].replace('-','') : noteType;
            if (typeStr.length > 0) {
                var typeText:FunkinText = textGroup.recycle(FunkinText);
                typeText.text = typeStr;
                typeText.setPosition(_note.x - (typeText.width/2 - _note.width/2), _note.y - (typeText.height/2 - _note.height/2));
                typeText.scrollFactor.set(1,1);
                textGroup.add(typeText);
                _note.txt = typeText;
            }
        }

        _note.childNote = susNote;
        notesGroup.add(_note);
        return _note;
    }

    public static inline function getGridOverlap(obj1:Dynamic, obj2:Dynamic):Bool {
		return obj1.x > obj2.x && obj1.x < obj2.x + obj2.width
		&& obj1.y > obj2.y && obj1.y < obj2.y + (GRID_SIZE * Conductor.STEPS_SECTION_LENGTH);
	}
}