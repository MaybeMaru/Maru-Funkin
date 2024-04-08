package funkin.states.editors.chart;

import funkin.sound.AudioWaveform;
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
        final color1 = isNote ? 0xff7c7c7c : 0xff6e6e6e;
        final color2 = isNote ? 0xff6e6e6e : 0xff7c7c7c;
        final _gridBitmap:FlxSprite = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE,  GRID_SIZE * (isNote ? Conductor.STRUMS_LENGTH : 1), GRID_SIZE * Conductor.STEPS_PER_MEASURE, true, color1, color2);
        for (i in 0...Conductor.BEATS_PER_MEASURE) _gridBitmap.pixels.fillRect(new Rectangle(0, ((_gridBitmap.height/Conductor.BEATS_PER_MEASURE) * i) - 1, _gridBitmap.width, 2), 0xff505050);
        if (isNote) _gridBitmap.pixels.fillRect(new Rectangle(_gridBitmap.width * .5 - 1, 0, 2, _gridBitmap.height), FlxColor.BLACK);

        // Add grid
        grid = new FlxBackdrop(_gridBitmap.pixels, Y);
        grid.screenCenter(X);
        add(grid);
        
        _gridBitmap.destroy();

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
            if (obj.child != null) obj.child.kill();
            if (obj.typeText != null) obj.typeText.kill();
        }
    }

    public function clearSection(full:Bool = true) {
        final objArray:Array<Dynamic> = full ? objectsGroup.members : curSecContent;
        for (i in objArray) clearObject(i);
        FlxArrayUtil.clearArray(curSecContent);
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
        final _data = data ?? obj.chartData;
        clearObject(obj);
        drawObject(_data);
    }

    public function drawObject(data:Array<Dynamic>):Dynamic {
        throw "Missing drawObject function";
    }

    // Dw about this
    inline public static var GRID_SIZE:Int = 40;

    public static inline function getGridOverlap(obj1:Dynamic, obj2:Dynamic):Bool {
		return obj1.x > obj2.x && obj1.x < obj2.x + obj2.width
		&& obj1.y > obj2.y && obj1.y < obj2.y + (GRID_SIZE * Conductor.STEPS_PER_MEASURE);
	}

    static final gridPos:FlxPoint = FlxPoint.get();

    public static inline function getGridCoords(obj1:Dynamic, obj2:Dynamic, snapY:Bool = true) {
        final tileX = obj2.x + Math.floor((obj1.x - obj2.x) / GRID_SIZE) * GRID_SIZE;
        final tileY = snapY ? obj2.y + (Math.floor((obj1.y - obj2.y) / GRID_SIZE) * GRID_SIZE) : obj1.y;
        gridPos.set(tileX, tileY);
        return gridPos;
    }
}

/*
    TODO: make bitmaps sustain system for charting state
*/

class ChartNoteGrid extends ChartGridBase
{
    public var instWaveform:AudioWaveform;
    public var voicesWaveform:AudioWaveform;

    public var sustainsGroup:FlxTypedGroup<ChartSustain>;
    public var textGroup:FlxTypedGroup<FunkinText>;

    override function drawObject(data:Array<Dynamic>):Dynamic {
        final strumTime:Float = data[0];
        final noteData:Int = data[1];
        final susLength:Float = data[2];
        
        final noteType:String = NoteUtil.getTypeName(data[3]);
        final typeData:NoteTypeJson = NoteUtil.getTypeJson(noteType);
        final pos:FlxPoint = FlxPoint.get(grid.x + Math.floor(noteData * GRID_SIZE), grid.y + Math.floor(ChartingState.getTimeY(strumTime - sectionTime)));

        // Create note
        final note:ChartNote = cast(objectsGroup.recycle(ChartNote), ChartNote);
        note.init(data, typeData.skin, pos);

        // Create sustain
        var sustain:ChartSustain = null;
        if (susLength > 0) {
            sustain = sustainsGroup.recycle(ChartSustain);
            sustain.init(data, typeData.skin, pos, note);
            sustainsGroup.add(sustain);
        }
        note.child = sustain;

        // Create type text
        if (typeData.showText) {
            final type:String = (noteType.startsWith('default')) ? noteType.split('default')[1].replace('-','') : noteType;
            if (type.length > 0) {
                final text:FunkinText = textGroup.recycle(FunkinText);
                text.text = type;

                text.setPosition(pos.x - (text.width * .5 - note.width * .5), pos.y - (text.height * .5 - note.height * .5));
                text.scrollFactor.set(1,1);

                note.typeText = text;
                textGroup.add(text);
            }
        }

        pos.put();
        objectsGroup.add(note);
        return note;
    }
    
    public function new() {        
        super(true);

        // Waveforms
        instWaveform = new AudioWaveform(grid.x, grid.y, grid.width, grid.height, Conductor.inst.sound);
        voicesWaveform = new AudioWaveform(grid.x, grid.y, grid.width, grid.height, Conductor.vocals.sound);
        
        instWaveform.visible = false;
        voicesWaveform.visible = false;

        insert(members.indexOf(objectsGroup), instWaveform);
        insert(members.indexOf(objectsGroup), voicesWaveform);

        instWaveform.color = 0x923c70;
        voicesWaveform.color = 0x5e3c92;

        sustainsGroup = new FlxTypedGroup<ChartSustain>();
        insert(members.indexOf(objectsGroup), sustainsGroup);
        
        textGroup = new FlxTypedGroup<FunkinText>();
        add(textGroup);

        updateWaveform();
    }

    public function updateWaveform():Void
    {
        instWaveform.audioOffset = Conductor.offset[0];
        voicesWaveform.audioOffset = Conductor.offset[1];

        var index = ChartingState.instance.sectionIndex;
        var start = ChartingState.getSecTime(index);
        var end = ChartingState.getSecTime(index + 1);

        instWaveform.setSegment(start, end);
        voicesWaveform.setSegment(start, end);
    }
}

class ChartNote extends Note {
    public function new() {
        super();
        scrollFactor.set(1,1);
        active = false;
    }

    public var chartData:Null<Array<Dynamic>> = null;
    public var typeText:Null<FunkinText> = null;
    public var gridNoteData:Int = 0;

    override function removeNote() {}

    public function init(?chartData:Array<Dynamic>, ?skin:String, position:FlxPoint) {
        this.chartData = chartData;

        strumTime = chartData[0];
        noteData = cast(chartData[1] % Conductor.NOTE_DATA_LENGTH, Int);
        gridNoteData = chartData[1];

        changeSkin(skin ?? SkinUtil.curSkin);
        playAnim('scroll' + CoolUtil.directionArray[noteData]);
        setGraphicSize(GRID_SIZE, GRID_SIZE);
        updateHitbox();

        setPosition(position.x, position.y);
    }
}

class ChartSustain extends Sustain {
    public function new() {
        super();
        scrollFactor.set(1,1);
        angle = 0;
        flipX = false;
        active = false;
    }

    public var chartData:Null<Array<Dynamic>> = null;
    public var chartParent:Null<ChartNote> = null;
    public var gridNoteData:Int = 0;

    override function removeNote() {}

    public function init(?chartData:Array<Dynamic>, ?skin:String, position:FlxPoint, ?parent:ChartNote) {
        this.chartData = chartData;
        this.chartParent = parent;

        strumTime = chartData[0];
        noteData = cast(chartData[1] % Conductor.NOTE_DATA_LENGTH, Int);
        gridNoteData = chartData[1];

        changeSkin(skin ?? SkinUtil.curSkin);
        setPosition(position.x, position.y);
        if (parent != null) {
            setScale(parent.scale.x);
            setTiles(1,1);
            offset.x -= GRID_SIZE * .5 - repeatWidth * .5;
            offset.y -= GRID_SIZE * .5;
        }

        repeatHeight = FlxMath.remapToRange(chartData[2], 0, Conductor.stepCrochet, 0, GRID_SIZE) + GRID_SIZE * .5;
    }
}

typedef EventData = Array<Dynamic>;

class ChartEventGrid extends ChartGridBase {
    public var group:FlxTypedGroup<ChartEvent>;

    override function drawObject(event:Array<Dynamic>):Dynamic {
        return drawPackedObject(event[0], [event]);
    }

    public function drawPackedObject(strumTime:Float = 0, events:Array<EventData>) {
        final gridY = grid.y + Math.floor(ChartingState.getTimeY(strumTime - sectionTime));

        final _event:ChartEvent = cast(objectsGroup.recycle(ChartEvent), ChartEvent);
        _event.init(strumTime, events, new FlxPoint(grid.x, gridY));

        objectsGroup.add(_event);
        return _event;
    }
    
    public function new() {
        super(false);
        this.group = cast this.objectsGroup;
    }

    override function drawSectionData(?value:SwagSection, cutHalf:Bool = false, pushList:Bool = false) {
        if (value == null)
            return;

        var packedEvents:Bool = false;
        final eventsMap:Map<Int, Array<EventData>> = [];
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
        else {
            for (time => events in eventsMap) {
                final e = drawPackedObject(time, events);
                if (pushList) curSecContent.push(e);
            }
        }
    }
}

class ChartEvent extends FlxTypedSpriteGroup<Dynamic> {
    public var data:Array<Event> = [];
    public var chartData:Array<EventData> = [];
    public var names:Array<String> = [];
    
    public var sprite:FlxSpriteExt;
    public var text:FunkinText;
    var packSprite:FlxSpriteExt;

    public var strumTime:Float = 0;

    var img:String = "blankEvent";
    
    public function new() {
        super();
        sprite = new FlxSpriteExt();
        loadEventImage(img);
        add(sprite);

        packSprite = new FlxSpriteExt().loadImage("options/packedEvent");
        packSprite.offset.set(-14,-20);
        add(packSprite);
        
        text = new FunkinText(0,0,"",15);
        text.alignment = RIGHT;
        text.borderStyle = NONE;
        add(text);

        scrollFactor.set(1,1);
        data.push(new Event()); // Dummy event
    }

    public function loadSettings() {
        final eventData = EventUtil.getEventData(data[0].name);
        if (img != eventData.image)
            loadEventImage(eventData.image);
    }

    public function loadEventImage(image:String) {
        sprite.loadImage("events/" + image);
        sprite.setGraphicSize(GRID_SIZE, GRID_SIZE);
        sprite.updateHitbox();
        img = image;
    }

    public function arrayString(array:EventData) {
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
        text.offset.set(text.width, -GRID_SIZE * 0.5 + text.height * 0.5);
        packSprite.visible = chartData.length > 1;
    }
    
    public function pushData(eventData:EventData) {
        chartData.push(eventData);
        eventData[0] = strumTime;
        if (data[chartData.length - 1] == null) data.push(new Event(strumTime, eventData[1] ?? "NULL", eventData[2]));
        else                                    data[chartData.length - 1].set(strumTime, eventData[1] ?? "NULL", eventData[2]);
        names.push(eventData[1]);
        updateText();
    }

    public function removeData(id:Int) {
        chartData.remove(chartData[id]);
        data.remove(data[id]);
        names.remove(names[id]);
        updateText();
    }

    public function init(strumTime:Float, events:Array<EventData>, position:FlxPoint) {
        setPosition(position.x,position.y);
        this.strumTime = strumTime;
        
        FlxArrayUtil.clearArray(data);
        FlxArrayUtil.clearArray(this.names);
        FlxArrayUtil.clearArray(this.chartData);

        for (i in events) pushData(i);
        loadSettings();
    }
}