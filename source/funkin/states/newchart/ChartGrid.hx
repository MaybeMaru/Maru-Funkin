package funkin.states.newchart;

import flixel.addons.display.FlxBackdrop;
import openfl.events.MouseEvent;
import flixel.addons.display.FlxGridOverlay;

@:access(flixel.input.mouse.FlxMouse)
class ChartGrid extends Group
{
    inline static var TILE:Int = 40;

    var downscroll:Bool = false;

    var notesGrid:FlxBackdrop;
    var eventsGrid:FlxBackdrop;
    var content:ChartGridContent;

    var beats:FlxBackdrop;

    var strumline:ChartStrumLine;

    public function new() {
        super();

        // Use the same bitmap for batch rendering on both grids
        var bitmap = FlxGridOverlay.createGrid(1, 1, 8, 16, true, 0xff7c7c7c, 0xff6e6e6e);

        notesGrid = new FlxBackdrop(bitmap, Y);
        notesGrid.scale.set(TILE, TILE);
        notesGrid.updateHitbox();
        add(notesGrid);

        eventsGrid = new FlxBackdrop(bitmap, Y);
        eventsGrid.scale.set(TILE, TILE);
        eventsGrid.updateHitbox();
        add(eventsGrid);

        // Adjust events grid shit
        eventsGrid.frame.frame.x = 1;
        eventsGrid.frame.frame.width = 1;
        eventsGrid.frame = eventsGrid.frame;
        eventsGrid.width = TILE;

        notesGrid.screenCenter(X);
        eventsGrid.x = notesGrid.x - TILE - 10;

        beats = new FlxBackdrop(null, Y);
        beats.setPosition(notesGrid.x, notesGrid.y);
        beats.makeGraphic(1, 1, 0xff565456);
        beats.antialiasing = false;
        beats.scale.set(notesGrid.width, 2);
        beats.updateHitbox();
        add(beats);

        var separator = new FlxSpriteExt().makeRect(2, FlxG.height, FlxColor.BLACK);
        separator.antialiasing = false;
        separator.scrollFactor.set();
        separator.screenCenter(X);
        add(separator);

        strumline = new ChartStrumLine(notesGrid.x);
        add(strumline);

        content = new ChartGridContent();
        add(content);

        prepareBpmChanges();
        prepareObjects();

        setSnap(4);
        updatePosition();

        FlxG.mouse._stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }

    override function update(elapsed:Float)
    {
        if (Conductor.playing)
        {
            updatePosition();
        }
        else
        {
            var mult:Int = FlxG.keys.pressed.SHIFT ? 4 : 1;

            if (FlxG.keys.justPressed.A) curSection += (downscroll ? mult : -mult);
            if (FlxG.keys.justPressed.D) curSection += (downscroll ? -mult : mult);

            if (FlxG.keys.pressed.W) move((downscroll ? elapsed : -elapsed) * mult);
            if (FlxG.keys.pressed.S) move((downscroll ? -elapsed : elapsed) * mult);
        }
    }

    function move(elapsed:Float):Void
    {
        Conductor.songPosition = boundTime(Conductor.songPosition + elapsed * 1000);

        if (Conductor.songPosition >= sectionTimes[curSection + 1])
        {
            if ((curSection + 1) != (sectionTimes.length - 1))
                curSection++;
        }
        else if (Conductor.songPosition < sectionTimes[curSection])
        {
            curSection--;
            Conductor.songPosition = sectionTimes[curSection + 1] - 1; // Adjust time
        }
        
        updatePosition();
    }

    function updatePosition() {
        strumline.y = getCurrentTimeY();
        FlxG.camera.scroll.y = strumline.y - (downscroll ? 480 : 240);
    }

    function setSnap(snap:Int = 4)
    {
        beats.spacing.y = ((snap / 2) * TILE) - 1;
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

    // TODO: Change the 16 with the snap later
    inline function getTimeY(time:Float):Float {
        var range:Float = inline FlxMath.remapToRange(time, 0, Conductor.sectionCrochet, 0, TILE * 16);
        return downscroll ? -(range + TILE)  : range;
    }

    // Get the conductor songPosition time Y
    inline function getCurrentTimeY():Float {
        return getTimeY(boundTime(getTime()));
    }

    // Bound a time value to the inst length
    inline function boundTime(time:Float) {
        return FlxMath.bound(time, 0, Conductor.inst.length - Conductor.offset[0] - Conductor.latency);
    }

    // TODO:
    // Merge prepareObjects and prepareBPM since the notes gotta change position depending on the bpm
    // Maybe generate notes first and make another function to position them at runtime?
    // Make a beats seperator class to accomodate for that too

    function prepareObjects() {
        ChartEditor.SONG.notes.fastForEach((section, i) ->
        {
            var array:Array<FlxBasic> = [];

            section.sectionNotes.fastForEach((note, i) -> {
                var note = makeNote(note[0], note[1], note[2]);
                array.push(note);
            });

            content.sectionNotes.push(array);
        });
    }

    public var sectionTimes:Array<Float> = [];

    function prepareBpmChanges() {
        sectionTimes.splice(0, sectionTimes.length);

        var time:Float = 0.0;
        var bpm = ChartEditor.SONG.bpm;

        ChartEditor.SONG.notes.fastForEach((section, i) -> {
            sectionTimes.push(time);
            
            if (section.changeBPM)
                bpm = section.bpm;
            
            time += 4 * (60000 / bpm);
        });

        sectionTimes.push(time);
    }

    function makeNote(strumTime:Float, noteData:Int, ?susLength:Float) {
        var note = new ChartNote(noteData, susLength ?? 0, downscroll);
        note.setPos(
            notesGrid.x + (TILE * noteData), 
            getTimeY(strumTime)
        );
        return note;
    }

    var curSection(default, set):Int = 0;
    inline function set_curSection(value:Int):Int
    {
        value = cast FlxMath.bound(value, 0, ChartEditor.SONG.notes.length - 1);

        Conductor.songPosition = sectionTimes[value] ?? sectionTimes[sectionTimes.length - 1];
        updatePosition();

        return content.renderSection = curSection = value;
    }

    override function destroy() {
        super.destroy();
        FlxG.mouse._stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }
}