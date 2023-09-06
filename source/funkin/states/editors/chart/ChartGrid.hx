package funkin.states.editors.chart;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class ChartGrid extends FlxTypedGroup<Dynamic> {
    inline public static var GRID_SIZE:Int = 40;
    public var grid:FlxBackdrop;
    public var gridShadow:FlxSprite;

    public var notesGroup:FlxTypedGroup<ChartNote>;
    public var sustainsGroup:FlxTypedGroup<ChartNote>;
    public var textGroup:FlxTypedGroup<FunkinText>;
    public var waveformVocals:ChartWaveform;
    public var waveformInst:ChartWaveform;

    public function new() {
        super();
        var _gridBitmap:FlxSprite = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE,  GRID_SIZE * Conductor.STRUMS_LENGTH, GRID_SIZE * Conductor.STEPS_PER_MEASURE, true, 0xff7c7c7c, 0xff6e6e6e);
        for (i in 0...Conductor.BEATS_PER_MEASURE) _gridBitmap.pixels.fillRect(new Rectangle(0, ((_gridBitmap.height/Conductor.BEATS_PER_MEASURE) * i) - 1, _gridBitmap.width, 2), 0xff505050);
        _gridBitmap.pixels.fillRect(new Rectangle(_gridBitmap.width / 2 - 1, 0, 2, _gridBitmap.height), FlxColor.BLACK);
        
        grid = new FlxBackdrop(_gridBitmap.pixels, Y);
        grid.screenCenter(X);
        add(grid);

        waveformInst = new ChartWaveform(Conductor.inst, 0x923c70);
        waveformInst.visible = false;
        add(waveformInst);

        waveformVocals = new ChartWaveform(Conductor.vocals);
        waveformVocals.visible = false;
        add(waveformVocals);

        notesGroup = new FlxTypedGroup<ChartNote>();
        sustainsGroup = new FlxTypedGroup<ChartNote>();
        textGroup = new FlxTypedGroup<FunkinText>();
        add(sustainsGroup);
        add(notesGroup);
        add(textGroup);

        gridShadow = new FlxSprite(grid.x,grid.y-grid.height);
        gridShadow.makeGraphic(cast grid.width, cast grid.height*3, FlxColor.BLACK);
        gridShadow.pixels.fillRect(new Rectangle(0, gridShadow.height / 3, grid.width, grid.height), FlxColor.fromRGB(0,0,0,1));
        gridShadow.alpha = 0.6;
        add(gridShadow);

        updateWaveform();
    }

    public function updateWaveform() {
        waveformInst.soundOffset = Conductor.songOffset[0];
        waveformVocals.soundOffset = Conductor.songOffset[1];
        for (i in [waveformInst, waveformVocals]) {
            i.updateWaveform();
            i.setPosition(grid.x, grid.y);
        }
    }

    public var sectionData(default, set):SwagSection;
    public var sectionIndex:Int = 0;
    public var sectionTime:Float = 0;

    public function set_sectionData(value:SwagSection):SwagSection {
        clearSection();
        drawSectionData(value);
        return sectionData = value;
    }

    public function drawSectionData(value:SwagSection, cutHalf:Bool = false) {
        if (value == null) return;
        if (value.sectionNotes.length <= 0) return;
        if (!cutHalf) {
            for (i in value.sectionNotes)
                drawNote(i);
        } else {
            value.sectionNotes.sort(function(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]));
            for (i in Std.int(value.sectionNotes.length*0.5)...value.sectionNotes.length)
                drawNote(value.sectionNotes[i]);
        }
    }

    public function setData(sectionIndex:Int = 0) {
        this.sectionIndex = sectionIndex;
        sectionTime = ChartingState.getSecTime(sectionIndex);
        this.sectionData = ChartingState.SONG.notes[sectionIndex];

        drawSectionData(ChartingState.SONG.notes[sectionIndex-1], true);
        drawSectionData(ChartingState.SONG.notes[sectionIndex+1]);
    }

    public function clearNote(note:ChartNote) {
        note.kill();
        note.x = -999;
        if (note.childNote != null) note.childNote.kill();
        if (note.txt != null) note.txt.kill();
    }

    public function clearSection() {
        for (i in notesGroup)
            clearNote(i);
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
		&& obj1.y > obj2.y && obj1.y < obj2.y + (GRID_SIZE * Conductor.STEPS_PER_MEASURE);
	}

    public static inline function getGridCoords(obj1:Dynamic, obj2:Dynamic, snapY:Bool = true) {
        var tileX = obj2.x + Math.floor((obj1.x - obj2.x) / ChartGrid.GRID_SIZE) * ChartGrid.GRID_SIZE;
        var tileY = snapY ? obj2.y + (Math.floor((obj1.y - obj2.y) / ChartGrid.GRID_SIZE) * ChartGrid.GRID_SIZE) : obj1.y;
        return new FlxPoint(tileX, tileY);
    }
}

class ChartNote extends Note {

    public function new() {
        super();
        scrollFactor.set(1,1);
        susEndHeight = 0;
        active = false;
    }

    public var gridNoteData:Int = 0;
    public var txt:FunkinText = null;
    public var startInit:Bool = false;

    public function init(_time, _data, _xPos, _yPos, _sus, _skin, forceSus = false, ?_parent:Note) {
        strumTime = _time;
        noteData = _data % Conductor.NOTE_DATA_LENGTH;
        gridNoteData = _data;
        isSustainNote = forceSus;
        _skin = _skin == null ? SkinUtil.curSkin : _skin;
        txt = null;

        alpha = isSustainNote ? 0.6 : 1;
        setPosition(_xPos, _yPos);
        if (skin != _skin || !startInit) {
            skin = _skin;
            createGraphic(false);
            startInit = true;
        } else updateAnims();
        updateHitbox();

        if (isSustainNote) {
            var _scale = _parent.scale.x;
            scale.set(_scale,_scale);
            updateHitbox();
            
            var _off = ChartingState.getYtime(ChartGrid.GRID_SIZE * 0.5);
            var _height = Math.floor(((FlxMath.remapToRange(_sus + _off, 0, Conductor.stepCrochet * Conductor.STEPS_PER_MEASURE, 0, ChartGrid.GRID_SIZE * Conductor.STEPS_PER_MEASURE))/* + ChartGrid.GRID_SIZE / 2*/) / _scale);
            drawSustainCached(_height);
            updateHitbox();
            offset.x -= ChartGrid.GRID_SIZE / 2 - width / 2.125;
            offset.y -= ChartGrid.GRID_SIZE / 2;
        } else {
            setGraphicSize(ChartGrid.GRID_SIZE,ChartGrid.GRID_SIZE);
            updateHitbox();
        }
    }
}