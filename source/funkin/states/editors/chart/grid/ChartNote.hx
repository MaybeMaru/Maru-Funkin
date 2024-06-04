package funkin.states.editors.chart.grid;

import flixel.text.FlxBitmapText;

import funkin.states.editors.chart.ChartGridBase.GRID_SIZE;
import funkin.states.editors.chart.ChartGridBase.getGridOverlap;
import funkin.states.editors.chart.ChartGridBase.getGridCoords;

class ChartNote extends Note
{
    public function new() {
        super();
        scrollFactor.set(1,1);
        active = false;
    }

    public var chartData:Array<Dynamic>;
    public var typeText:FlxBitmapText;
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

class ChartSustain extends Sustain
{
    public function new() {
        super();
        scrollFactor.set(1,1);
        angle = 0;
        flipX = false;
        active = false;
    }

    public var chartData:Array<Dynamic>;
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
        
        if (parent != null) {
            setScale(parent.scale.x);
            setTiles(1,1);
            offset.x -= GRID_SIZE * .5 - repeatWidth * .5;
            offset.y -= GRID_SIZE * .5;
        }

        setPosition(position.x, position.y);
        repeatHeight = FlxMath.remapToRange(chartData[2], 0, Conductor.stepCrochet, 0, GRID_SIZE) + GRID_SIZE * .5;
    }
}