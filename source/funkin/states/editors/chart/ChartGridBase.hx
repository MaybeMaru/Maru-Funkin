package funkin.states.editors.chart;

import flixel.util.FlxArrayUtil;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import funkin.states.editors.chart.ChartGridBase.GRID_SIZE;

class ChartGridBase extends FlxTypedGroup<Dynamic> {
    var isNote:Bool = true;
    public var grid:FlxBackdrop;
    var gridShadow:FlxSprite;

    public var objectsGroup:FlxTypedGroup<Dynamic>;
    
    public function new(isNote:Bool) {
        super();
        this.isNote = isNote;

        // Draw grid bitmap
        var _gridBitmap:FlxSprite = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE,  GRID_SIZE * (isNote ? Conductor.STRUMS_LENGTH : 1), GRID_SIZE * Conductor.STEPS_PER_MEASURE, true, 0xff7c7c7c, 0xff6e6e6e);
        for (i in 0...Conductor.BEATS_PER_MEASURE) _gridBitmap.pixels.fillRect(new Rectangle(0, ((_gridBitmap.height/Conductor.BEATS_PER_MEASURE) * i) - 1, _gridBitmap.width, 2), 0xff505050);
        if (isNote) _gridBitmap.pixels.fillRect(new Rectangle(_gridBitmap.width * .5 - 1, 0, 2, _gridBitmap.height), FlxColor.BLACK);

        // Add grid
        grid = new FlxBackdrop(_gridBitmap.pixels, Y);
        grid.screenCenter(X);
        add(grid);

        // Events grid offset
        if (!isNote) {
            grid.x -= GRID_SIZE * 5;
        }

        objectsGroup = (isNote ? new FlxTypedGroup<ChartNote>() : new FlxTypedGroup<ChartEvent>());
        add(objectsGroup);

        gridShadow = new FlxSprite(grid.x,grid.y-grid.height);
        gridShadow.makeGraphic(cast grid.width, cast grid.height*3, FlxColor.BLACK);
        gridShadow.pixels.fillRect(new Rectangle(0, gridShadow.height / 3, grid.width, grid.height), FlxColor.fromRGB(0,0,0,1));
        gridShadow.alpha = 0.6;
        add(gridShadow);
    }

    public var sectionData(default, set):SwagSection;
    public var sectionIndex:Int = 0;
    public var sectionTime:Float = 0;

    public function set_sectionData(value:SwagSection):SwagSection {
        clearSection();
        drawSectionData(value, false, true);
        return sectionData = value;
    }

    public function drawSectionData(?value:SwagSection, cutHalf:Bool = false, pushList:Bool = false) {
        if (value != null) {
            final secMidTime = ChartingState.getSecTime(sectionIndex-1) + Conductor.sectionCrochet * 0.625; // lol
            for (i in (isNote ? value.sectionNotes : value.sectionEvents)) {
                if (!cutHalf || (i[0] + (isNote ? i[2] : 0)) >= secMidTime) {
                    final obj = drawObject(i);
                    if (pushList) curSecContent.push(obj); // Only clear sec objs on clear sec button
                }
            }
        }
    }

    public function setData(sectionIndex:Int = 0) {
        this.sectionIndex = sectionIndex;
        sectionTime = ChartingState.getSecTime(sectionIndex);
        this.sectionData = ChartingState.SONG.notes[sectionIndex];

        drawSectionData(ChartingState.SONG.notes[sectionIndex-1], true);
        drawSectionData(ChartingState.SONG.notes[sectionIndex+1]);
    }

    public var curSecContent:Array<Dynamic> = [];
    public function clearObject(obj:Dynamic) {
        obj.kill();
        if (cast obj is ChartNote) {
            obj.x = -999;
            if (obj.childNote != null) obj.childNote.kill();
            if (obj.txt != null) obj.txt.kill();
        }
    }

    public function clearSection(full:Bool = true) {
        var objArray:Array<Dynamic> = full ? objectsGroup.members : curSecContent;
        for (i in objArray) clearObject(i);
        FlxArrayUtil.clearArray(curSecContent);
    }

    public function getObjectData(obj:Dynamic):Array<Dynamic> {
        for (i in (isNote ? sectionData.sectionNotes : sectionData.sectionEvents)) {
            if (Math.floor(obj.strumTime) == Math.floor(i[0])) { // Same strum time
                if (!isNote || i[1] == obj.gridNoteData) // Notedata check for notes
                    return i;
            }
        }
        return null;
    }

    public function getDataObject(data:Array<Dynamic>):Dynamic {
        for (i in objectsGroup) {
            if (Math.floor(i.strumTime) == Math.floor(data[0])) { // Same strum time
                if (!isNote || data[1] == i.gridNoteData) // Notedata check for notes
                    return i;
            }
        }
        return null;
    }
    
    public function updateObject(obj:Dynamic, ?data:Array<Dynamic>) {
        final _data = data ?? getObjectData(obj);
        clearObject(obj);
        drawObject(_data);
    }

    public function drawObject(data:Array<Dynamic>):Dynamic {
        return null;
    }

    // Dw about this
    inline public static var GRID_SIZE:Int = 40;

    public static inline function getGridOverlap(obj1:Dynamic, obj2:Dynamic):Bool {
		return obj1.x > obj2.x && obj1.x < obj2.x + obj2.width
		&& obj1.y > obj2.y && obj1.y < obj2.y + (GRID_SIZE * Conductor.STEPS_PER_MEASURE);
	}

    public static inline function getGridCoords(obj1:Dynamic, obj2:Dynamic, snapY:Bool = true) {
        final tileX = obj2.x + Math.floor((obj1.x - obj2.x) / GRID_SIZE) * GRID_SIZE;
        final tileY = snapY ? obj2.y + (Math.floor((obj1.y - obj2.y) / GRID_SIZE) * GRID_SIZE) : obj1.y;
        return new FlxPoint(tileX, tileY);
    }
}

class ChartNoteGrid extends ChartGridBase {
    public var sustainsGroup:FlxTypedGroup<ChartNote>;
    public var textGroup:FlxTypedGroup<FunkinText>;
    public var waveformVocals:ChartWaveform;
    public var waveformInst:ChartWaveform;

    public var group:FlxTypedGroup<ChartNote>;

    override function drawObject(note:Array<Dynamic>):Dynamic {
        final strumTime:Float = note[0];
        final noteData:Int = note[1];
        final susLength:Float = note[2];
        final noteType:String = NoteUtil.getTypeName(note[3]);
        final typeData:NoteTypeJson = NoteUtil.getTypeJson(noteType);

        final gridPos = new FlxPoint(grid.x + Math.floor(noteData * GRID_SIZE), grid.y + Math.floor(ChartingState.getTimeY(strumTime - sectionTime)));

        final _note:ChartNote = objectsGroup.recycle(ChartNote);
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
                typeText.setPosition(_note.x - (typeText.width * .5 - _note.width * .5), _note.y - (typeText.height * .5 - _note.height * .5));
                typeText.scrollFactor.set(1,1);
                textGroup.add(typeText);
                _note.txt = typeText;
            }
        }

        _note.childNote = susNote;
        objectsGroup.add(_note);
        return _note;
    }
    
    public function new() {        
        super(true);

        // Waveforms
        waveformInst = new ChartWaveform(Conductor.inst, 0x923c70);
        insert(this.members.indexOf(objectsGroup), waveformInst);
        waveformVocals = new ChartWaveform(Conductor.vocals);
        insert(this.members.indexOf(objectsGroup), waveformVocals);
        waveformInst.visible = waveformVocals.visible = false;

        sustainsGroup = new FlxTypedGroup<ChartNote>();
        insert(this.members.indexOf(objectsGroup), sustainsGroup);
        
        textGroup = new FlxTypedGroup<FunkinText>();
        add(textGroup);

        updateWaveform();

        this.group = cast this.objectsGroup;
    }

    public function updateWaveform() {
        waveformInst.soundOffset = Conductor.songOffset[0];
        waveformVocals.soundOffset = Conductor.songOffset[1];
        for (i in [waveformInst, waveformVocals]) {
            i.updateWaveform();
            i.setPosition(grid.x, grid.y);
        }
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

        setPosition(_xPos, _yPos);
        if (skin != _skin || !startInit) {
            skin = _skin;
            createGraphic(false);
            startInit = true;
        } else updateAnims();
        updateHitbox();

        if (isSustainNote) {
            alpha = 0.6;
            var _scale = _parent.scale.x;
            scale.set(_scale,_scale);
            updateHitbox();
            
            var _off = ChartingState.getYtime(GRID_SIZE * 0.5);
            var _height = Math.floor(((FlxMath.remapToRange(_sus + _off, 0, Conductor.stepCrochet * Conductor.STEPS_PER_MEASURE, 0, GRID_SIZE * Conductor.STEPS_PER_MEASURE))) / _scale);
            drawSustainCached(_height);
            updateHitbox();
            offset.x -= GRID_SIZE * 0.5 - width / 2.125;
            offset.y -= GRID_SIZE * 0.5;
        } else {
            alpha = 1;
            setGraphicSize(GRID_SIZE, GRID_SIZE);
            updateHitbox();
        }
    }
}

class ChartEventGrid extends ChartGridBase {
    public var group:FlxTypedGroup<ChartEvent>;

    override function drawObject(event:Array<Dynamic>):Dynamic {
        var strumTime:Float = event[0];
        var eventName:String = event[1];
        var eventValues:Array<Dynamic> = event[2];
        var gridY = grid.y + Math.floor(ChartingState.getTimeY(strumTime - sectionTime));

        var _event:ChartEvent = objectsGroup.recycle(ChartEvent);
        _event.init(strumTime, eventName, eventValues, new FlxPoint(grid.x, gridY));

        objectsGroup.add(_event);
        return _event;
    }
    
    public function new() {
        super(false);
        this.group = cast this.objectsGroup;
    }

    /*override function drawSectionData(?value:SwagSection, cutHalf:Bool = false, pushList:Bool = false) {
        if (value == null) {
            return;
        }
        
        var packedEvents:Bool = false;
        final eventsMap:Map<Int, Array<Array<Dynamic>>> = [];
        for (i in value.sectionEvents) {
            final time = Math.floor(i[0]);
            final arr = eventsMap.get(time) ?? [];
            arr.push(i);
            eventsMap.set(time, arr);
            if (arr.length > 1) { // Has packed events
                packedEvents = true;
            }
        }

        // No packed events, draw normally
        if (!packedEvents) {
            super.drawSectionData(value, cutHalf, pushList);
        }
        // Draw w/ packed events
        else {
            for (time => events in eventsMap) {
                drawPackedEvent(time, events);
            }
        }
    }

    function drawPackedEvent(time:Float, events:Array<Array<Dynamic>>) {
        if (events.length == 1) {
            drawObject(events[0]);
        } else {
            var packedEvent:PackedChartEvent = objectsGroup.recycle(PackedChartEvent);
        }
    }*/
}

class ChartEvent extends FlxTypedSpriteGroup<Dynamic> {
    public var data:Array<Event> = [];
    public var sprite:FlxSpriteExt;
    public var text:FunkinText;

    public var strumTime:Float = 0;

    var img:String = "blankEvent";
    
    public function new() {
        super();
        sprite = new FlxSpriteExt();
        loadImage(img);
        add(sprite);
        
        text = new FunkinText(0,0,"",15);
        text.offset.y = -GRID_SIZE * 0.5 + text.height * 0.5;
        add(text);

        scrollFactor.set(1,1);
        data.push(new Event()); // Dummy event
    }

    public function loadSettings() {
        var eventData = EventUtil.getEventData(data[0].name);
        if (img != eventData.image) {
            loadImage(eventData.image);
        }
    }

    public function loadImage(image:String) {
        sprite.loadImage("events/" + image);
        sprite.setGraphicSize(GRID_SIZE, GRID_SIZE);
        sprite.updateHitbox();
        img = image;
    }

    public function arrayString(array:Array<Dynamic>) {
        var s:String = "[";
        for (i in 0...array.length) {
            s += Std.string(array[i]);
            if (i < array.length-1) s += ", ";
        }
        return s += "]";
    }

    public function updateText() {
        var txt = "";
        for (i in data) txt += arrayString(i.values) + " - " + i.name + "\n";
        text.text = txt;
        text.offset.x = text.width;
    }

    public function init(strumTime:Float, name:String, values:Array<Dynamic>, position:FlxPoint) {
        setPosition(position.x,position.y);
        this.strumTime = strumTime;
        data[0].strumTime = strumTime;
        data[0].name = name;
        data[0].values = values;
        updateText();
        loadSettings();
    }

    //public function init(strumTime, )
}