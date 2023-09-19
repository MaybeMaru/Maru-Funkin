package funkin.states.editors.chart;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class ChartEventsGrid extends FlxTypedGroup<Dynamic> {
    public var grid:FlxBackdrop;
    public var gridShadow:FlxSprite;

    public var eventsGroup:FlxTypedGroup<ChartEvent>;

    public function new() {
        super();
        var _gridBitmap:FlxSprite= FlxGridOverlay.create(ChartGrid.GRID_SIZE, ChartGrid.GRID_SIZE,  ChartGrid.GRID_SIZE, ChartGrid.GRID_SIZE * Conductor.STEPS_PER_MEASURE, true, 0xff6e6e6e,  0xff7c7c7c);
        for (i in 0...Conductor.BEATS_PER_MEASURE) _gridBitmap.pixels.fillRect(new Rectangle(0, ((_gridBitmap.height/Conductor.BEATS_PER_MEASURE) * i) - 1, _gridBitmap.width, 2), 0xff505050);
        
        grid = new FlxBackdrop(_gridBitmap.pixels, Y);
        grid.screenCenter(X);
        grid.x -= ChartGrid.GRID_SIZE * 5;
        add(grid);

        eventsGroup = new FlxTypedGroup<ChartEvent>();
        add(eventsGroup);

        gridShadow = new FlxSprite(grid.x,grid.y-grid.height);
        gridShadow.makeGraphic(cast grid.width, cast grid.height*3, FlxColor.BLACK);
        gridShadow.pixels.fillRect(new Rectangle(0, gridShadow.height / 3, grid.width, grid.height), FlxColor.fromRGB(0,0,0,1));
        gridShadow.alpha = 0.6;
        add(gridShadow);
    }

    public var sectionIndex:Int = 0;
    public var sectionTime:Float = 0;
    public var sectionData(default, set):SwagSection;
    public function set_sectionData(value:SwagSection):SwagSection {
        clearSection();
        drawSectionData(value);
        return sectionData = value;
    }

    public function drawSectionData(value:SwagSection, cutHalf:Bool = false) {
        if (value == null) return;
        if (value.sectionEvents.length <= 0) return;
        if (!cutHalf) {
            for (i in value.sectionEvents)
                drawEvent(i);
        } else {
            var secEvents = value.sectionEvents.copy();
            secEvents.sort(function(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]));
            for (i in Std.int(secEvents.length*0.5)...secEvents.length)
                drawEvent(secEvents[i]);
        }
    }

    public function setData(sectionIndex:Int = 0) {
        this.sectionIndex = sectionIndex;
        sectionTime = ChartingState.getSecTime(sectionIndex);
        this.sectionData = ChartingState.SONG.notes[sectionIndex];

        drawSectionData(ChartingState.SONG.notes[sectionIndex-1], true);
        drawSectionData(ChartingState.SONG.notes[sectionIndex+1]);
    }

    public function clearSection() {
        for (i in eventsGroup)
            clearEvent(i);
    }

    public function getEventData(event:ChartEvent):Array<Dynamic> {
        for (i in sectionData.sectionEvents) {
            if (Math.floor(event.data.strumTime) == Math.floor(i[0])) {
                return i;
            }
        }
        return null;
    }

    public function getEventObject(event:Array<Dynamic>):ChartEvent {
        for (i in eventsGroup) {
            if (Math.floor(event[0]) == Math.floor(i.data.strumTime)) {
                return i;
            }
        }
        return null;
    }

    public function clearEvent(event:ChartEvent) {
        event.kill();
    }

    public function drawEvent(event:Array<Dynamic>):ChartEvent {
        var strumTime:Float = event[0];
        var eventName:String = event[1];
        var eventValues:Array<Dynamic> = event[2];
        var gridY = grid.y + Math.floor(ChartingState.getTimeY(strumTime - sectionTime));

        var _event:ChartEvent = eventsGroup.recycle(ChartEvent);
        _event.init(strumTime, eventName, eventValues, new FlxPoint(grid.x, gridY));

        eventsGroup.add(_event);
        return _event;
    }
}

class ChartEvent extends FlxTypedSpriteGroup<Dynamic> {
    public var data:Event;
    public var sprite:FlxSpriteExt;
    public var text:FunkinText;

    var img:String = "blankEvent";
    
    public function new() {
        super();
        sprite = new FlxSpriteExt();
        loadImage(img);
        add(sprite);
        
        text = new FunkinText(0,0,"",15);
        text.offset.y = -ChartGrid.GRID_SIZE * 0.5 + text.height * 0.5;
        add(text);

        scrollFactor.set(1,1);
        data = new Event();
    }

    public function loadSettings() {
        var eventData = EventUtil.getEventData(data.name);
        if (img != eventData.image) {
            loadImage(eventData.image);
        }
    }

    public function loadImage(image:String) {
        sprite.loadImage("events/" + image);
        sprite.setGraphicSize(ChartGrid.GRID_SIZE, ChartGrid.GRID_SIZE);
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
        text.text = arrayString(data.values) + " - " + data.name;
        text.offset.x = text.width;
    }

    public function init(strumTime:Float, name:String, values:Array<Dynamic>, position:FlxPoint) {
        setPosition(position.x,position.y);
        data.strumTime = strumTime;
        data.name = name;
        data.values = values;
        updateText();
        loadSettings();
    }
}