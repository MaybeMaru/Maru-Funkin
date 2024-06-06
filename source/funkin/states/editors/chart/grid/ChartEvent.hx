package funkin.states.editors.chart.grid;

import flixel.text.FlxBitmapText;

import funkin.states.editors.chart.ChartGridBase.GRID_SIZE;
import funkin.states.editors.chart.ChartGridBase.getGridOverlap;
import funkin.states.editors.chart.ChartGridBase.getGridCoords;

class ChartEvent extends SpriteGroup
{
    public var data:Array<Event> = [];
    public var chartData:Array<Array<Dynamic>> = [];
    public var names:Array<String> = [];
    
    public var sprite:FlxSpriteExt;
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

        scrollFactor.set(1,1);
        data.push(new Event()); // Dummy event
    }

    public var text(default, set):FlxBitmapText;
    function set_text(value) {
        if (value != null) {
            value.alignment = RIGHT;
        }
        return text = value;
    }

    override function kill() {
        super.kill();
        if (text != null) {
            text.kill();
            text = null;
        }
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

    public function strigifyArray(array:Array<Dynamic>) {
        var value:String = "[";
        array.fastForEach((item, i) -> {
            value += Std.string(item);
            if (i < array.length - 1) value += ", ";
        });
        return value + "]";
    }

    public function updateText() {
        var dataText:String = "";
        
        data.fastForEach((event, i) -> {
            dataText += strigifyArray(event.values) + ' - ' + event.name;
            if (i < data.length - 1) {
                dataText += "\n";
            }
        });

        text.text = dataText;
        packSprite.visible = chartData.length > 1;

        text.offset.set(
            text.width - GRID_SIZE * 0.75,
            (text.height * 0.75 - GRID_SIZE) * 0.5
        );
    }
    
    public function pushData(eventData:Array<Dynamic>) {
        chartData.push(eventData);
        eventData[0] = strumTime;
        if (data[chartData.length - 1] == null) data.push(new Event(strumTime, eventData[1] ?? "NULL", eventData[2]));
        else                                    data[chartData.length - 1].set(strumTime, eventData[1] ?? "NULL", eventData[2]);
        names.push(eventData[1]);
        updateText();
    }

    public function removeData(index:Int) {
        chartData.removeAt(index);
        data.removeAt(index);
        names.removeAt(index);
        updateText();
    }

    public function init(strumTime:Float, events:Array<Array<Dynamic>>, pos:FlxPoint)
    {
        this.strumTime = strumTime;
        x = pos.x;
        y = pos.y;

        if (text == null) {
            text = ChartingState.instance.recycleText();
            text.setPosition(x, y);
        }
        
        data.clear();
        names.clear();
        chartData.clear();

        events.fastForEach((event, i) -> pushData(event));
        loadSettings();
    }
}