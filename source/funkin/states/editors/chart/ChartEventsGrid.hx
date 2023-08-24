package funkin.states.editors.chart;

import flixel.addons.display.FlxGridOverlay;

class ChartEventsGrid extends FlxTypedGroup<Dynamic> {
    public var grid:FlxSprite;
    public function new() {
        super();
        grid = FlxGridOverlay.create(ChartGrid.GRID_SIZE, ChartGrid.GRID_SIZE,  ChartGrid.GRID_SIZE, ChartGrid.GRID_SIZE * Conductor.STEPS_SECTION_LENGTH, true, 0xff6e6e6e,  0xff7c7c7c);
        grid.screenCenter();
        grid.x -= ChartGrid.GRID_SIZE * 5;
        add(grid);
    }
}