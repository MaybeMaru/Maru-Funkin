package funkin.states.newchart;

import openfl.events.MouseEvent;
import flixel.addons.display.FlxGridOverlay;

@:access(flixel.input.mouse.FlxMouse)
class ChartGrid extends Group
{
    inline static var TILE:Int = 40;

    var notesGrid:FlxSpriteExt;
    var eventsGrid:FlxSpriteExt;

    public function new() {
        super();

        // Use the same bitmap for batch rendering on both grids
        var bitmap = FlxGridOverlay.createGrid(1, 1, 8, 16, true, 0xff7c7c7c, 0xff6e6e6e);

        notesGrid = new FlxSpriteExt(0, 0, bitmap);
        notesGrid.setScale(TILE);
        add(notesGrid);

        eventsGrid = new FlxSpriteExt(0, 0, bitmap);
        eventsGrid.setScale(TILE);
        add(eventsGrid);

        // Adjust events grid shit
        eventsGrid.frame.frame.x = 1;
        eventsGrid.frame.frame.width = 1;
        eventsGrid.frame = eventsGrid.frame;
        eventsGrid.width = TILE;

        notesGrid.screenCenter(X);
        eventsGrid.x = notesGrid.x - TILE - 10;

        FlxG.mouse._stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }

    // Save doing the mouse stuff on update
    function onMouseMove(e)
    {
        // TODO: add tile logic and all that bullshit
    }

    // Use inst time when possible to avoid needing to sync all the time lol
    inline function getTime():Float {
        return Conductor.playing ? Conductor.inst.time + Conductor.offset[0] + Conductor.latency : Conductor.songPosition;
    }

    inline function getTimeY():Float {
        return inline FlxMath.remapToRange(getTime(), 0, Conductor.sectionCrochet, 0, TILE * 16); // TODO: Change the 16 with the snap later
    }

    public var sectionObjects:Array<Array<FlxObject>> = [];

    var curSection(default, set):Int = 0;
    inline function set_curSection(value:Int):Int {
        return curSection = cast FlxMath.bound(value, 0, ChartEditor.SONG.notes.length - 1);
    }

    override function draw() {
        super.draw();

        // Render the 3 current visible sections, maybe make this higher depending on the snap?
        for (i in 0...3)
        {
            if (sectionObjects[curSection - 1 + i] != null)
            {
                sectionObjects[curSection - 1 + i].fastForEach((object, i) -> {
                    if (object != null) if (object.exists) if (object.visible)
                        object.draw();
                });
            }
        }
    }

    override function destroy() {
        super.destroy();
        FlxG.mouse._stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }
}