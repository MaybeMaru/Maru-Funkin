package funkin.states.editors.chart;

import flixel.addons.display.FlxGridOverlay;

class ChartEventsGrid extends FlxTypedGroup<Dynamic> {
    
    public var grid:FlxSprite;
    public var eventsGroup:FlxTypedGroup<ChartEvent>;

    public function new() {
        super();
        grid = FlxGridOverlay.create(ChartGrid.GRID_SIZE, ChartGrid.GRID_SIZE,  ChartGrid.GRID_SIZE, ChartGrid.GRID_SIZE * Conductor.STEPS_SECTION_LENGTH, true, 0xff6e6e6e,  0xff7c7c7c);
        grid.screenCenter();
        grid.x -= ChartGrid.GRID_SIZE * 5;
        add(grid);

        eventsGroup = new FlxTypedGroup<ChartEvent>();
        add(eventsGroup);
    }

    public var sectionIndex:Int = 0;
    public var sectionTime:Float = 0;
    public var sectionData(default, set):SwagSection;
    public function set_sectionData(value:SwagSection):SwagSection {
        clearSection();
        for (i in value.sectionEvents) {
            drawEvent(i);
        }
        return sectionData = value;
    }

    public function setData(sectionData:SwagSection, sectionIndex:Int = 0) {
        this.sectionIndex = sectionIndex;
        sectionTime = ChartingState.getSecTime(sectionIndex);
        this.sectionData = sectionData;
    }

    public function clearSection() {
        for (i in eventsGroup) {
            clearEvent(i);
        }
    }

    public function clearEvent(event:ChartEvent) {
        event.kill();
    }

    public function drawEvent(event:Array<Dynamic>):ChartEvent {
        //trace(event);
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

class ChartEvent extends FlxSpriteExt {
    public var data:Event;
    
    public function new() {
        super();
        loadImage("options/blankEvent");
        //scale.set(10,10);
        //setGraphicSize(ChartGrid.GRID_SIZE, ChartGrid.GRID_SIZE);
        //updateHitbox();
        scrollFactor.set(1,1);
        data = new Event();
    }

    public function init(strumTime:Float, name:String, values:Array<Dynamic>, position:FlxPoint) {
        setPosition(position.x,position.y);
        data.strumTime = strumTime;
        data.name = name;
        data.values = values;
    }
}