package funkin.states.editors.chart;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

@:access(openfl.geom.Rectangle)
class ChartGridBase<T:FlxObject> extends Group
{
    public var grid:FlxBackdrop;
    //public var gridShadow:FlxSprite;
    public var group:FlxTypedGroup<T>;
    
    public function new(columns:Int) {
        super();

        var gridPixels = FlxGridOverlay.createGrid(
            GRID_SIZE, GRID_SIZE,
            GRID_SIZE * columns, GRID_SIZE * Conductor.STEPS_PER_MEASURE,
            true, 0xff7c7c7c, 0xff6e6e6e
        );

        var rect = Rectangle.__pool.get();

        for (i in 0...Conductor.BEATS_PER_MEASURE) {
            rect.setTo(
                0,
                (gridPixels.height / Conductor.BEATS_PER_MEASURE * i) - 1,
                gridPixels.width,
                2
            );
            gridPixels.fillRect(rect, 0xff505050);
        }

        // Add grid
        grid = new FlxBackdrop(gridPixels, Y);
        grid.screenCenter(X);
        add(grid);

        group = new FlxTypedGroup<T>();
        add(group);

        /*gridShadow = new FlxSprite(grid.x, grid.y - grid.height);
        gridShadow.makeGraphic(cast grid.width, cast grid.height * 3, FlxColor.BLACK);
        gridShadow.alpha = 0.6;
        add(gridShadow);

        rect.setTo(
            0,
            gridShadow.height / 3,
            grid.width,
            grid.height
        );

        gridShadow.pixels.fillRect(rect, FlxColor.fromRGB(0,0,0,1));*/

        Rectangle.__pool.release(rect);
    }

    public var sectionMembers:Array<T> = [];
    public var sectionData(default, set):SwagSection;
    public var sectionIndex:Int = 0;
    public var sectionTime:Float = 0;

    public function set_sectionData(value:SwagSection):SwagSection {
        clearMembers(true);
        drawSectionData(value, false, sectionMembers);
        return sectionData = value;
    }

    public function drawSectionData(?section:SwagSection, clip:Bool = false, ?pushArray:Array<T>) {        
        if (section != null) {
            drawSectionClipping(
                section,
                clip ? ChartingState.getSecTime(sectionIndex - 1) + Conductor.sectionCrochet * 0.625 : 0,
                pushArray
            );
        }
    }

    public function drawSectionClipping(section:SwagSection, minTime:Float, ?pushArray:Array<T>) {}

    public function setData(sectionIndex:Int = 0) {
        this.sectionIndex = sectionIndex;
        sectionTime = ChartingState.getSecTime(sectionIndex);
        
        clearMembers(false);
        
        this.sectionData = ChartingState.SONG.notes[sectionIndex];
        drawSectionData(ChartingState.SONG.notes[sectionIndex-1], true);
        drawSectionData(ChartingState.SONG.notes[sectionIndex+1]);
    }

    public function clearObject(object:T) {
        object.kill();
    }

    public function clearMembers(onlySection:Bool = false) {
        var arrayClear = onlySection ? sectionMembers : group.members;
        arrayClear.fastForEach((object, i) -> clearObject(object));
        sectionMembers.clear();
    }

    // Get the current object attached to the data (if it exists)
    public function getDataObject(data:Array<Dynamic>):T {
        group.members.fastForEach((object, i) -> {
            if (object != null) {
                var isObject = equalObjectData(object, data);
                if (isObject != null)
                    return isObject;
            }
        });
        return null;
    }

    function equalObjectData(object:T, data:Array<Dynamic>):T {
        return object;
    }
    
    public function updateObject(object:Dynamic, ?data:Array<Dynamic>) {
        data ??= object.chartData;
        clearObject(object);
        drawObject(data);
    }

    public function drawObject(data:Array<Dynamic>):T {
        return null;
    }

    public inline static var GRID_SIZE:Int = 40;

    public static function getGridOverlap(x:Float, y:Float, obj:FlxObject):Bool {
		if (x > obj.x) if (x < obj.x + obj.width)
            if (y > obj.y) if (y < obj.y + (GRID_SIZE * Conductor.STEPS_PER_MEASURE))
                return true;

        return false;
	}

    public static function getGridCoords(x1:Float, y1:Float, x2:Float, y2:Float, snapY:Bool = true) {
        final tileX = x2 + Math.floor((x1 - x2) / GRID_SIZE) * GRID_SIZE;
        final tileY = snapY ? y2 + (Math.floor((y1 - y2) / GRID_SIZE) * GRID_SIZE) : y1;
        return CoolUtil.point.set(tileX, tileY);
    }
}