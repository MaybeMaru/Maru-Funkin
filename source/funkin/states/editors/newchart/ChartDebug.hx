package funkin.states.editors.newchart;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

typedef ChartBpm = {
    var time:Float;
    var bpm:Float;
}

typedef ChartSong = {
    notes:Array<NoteJson>,
    events:Array<EventJson>,
    bpms:Array<ChartBpm>
}

class ChartDebug extends MusicBeatState
{
    public var songFile:ChartSong;

    var downscroll:Bool = true;
    var grid:Grid;

    override function create()
    {
        super.create();
        
        grid = new Grid();
        add(grid);

        loadSong("bopeebo", "hard");
    }

    // TODO: draw this based on each bpm change till the end of the song rather than per note

    /*function addNote(data:NoteJson):Void
    {
        var note = grid.notes.recycle(ChartNote);
        grid.notes.add(note);

        var time:Float = data.time;
        var lane:Int = data.lane;

        note.y = getTimeY(time);
        note.x = grid.notesGrid.x + (lane * Grid.tileSize);
        note.load(data, getLastCrochet(time));
    }

    function addEvent(data:EventJson):Void
    {
        var event = grid.events.recycle();
        grid.events.add(event);
    }

    function getLastCrochet(time:Float):Float
    {
        var lastChange:ChartBpm = null;
        songFile.bpms.fastForEach((change, i) ->
        {
            if (change.time > time)
                break;

            lastChange = change;
        });

        return (60 / lastChange.bpm) * 1000;
    }

    // Runs a function for each bpm change of a song before a time and returns the last crochet
    function forEachChange(time:Float, call:(ChartBpm, Float)->Void):Float
    {
        var bpms = songFile.bpms;
        var crochet:Float = 0;

        var i = 1;
        var l = bpms.length;

        while (i < l) {
            var change = bpms[i];
            if (change.time > time)
                break;
            
            crochet = (60 / change.bpm) * 1000;
            call(change, crochet);

            i++;
        }

        return crochet;
    }

    function getTimeY(time:Float):Float
    {
        var yResult:Float = 0;

        forEachChange(time, (change, crochet) -> {
            yResult += FlxMath.remapToRange(
                time - change.time,
                0, 4 * crochet,
                0, 16 * Grid.tileSize
            );
        });

        if (downscroll) {
            yResult *= -1;
            yResult += Grid.tileSize * 16;
        }

        return yResult;
    }*/

    /** Redraw all notes and events from the song **/
    function reload():Void
    {
        grid.notes.killMembers();
        grid.events.killMembers();

        //songFile.notes.fastForEach((note, i) -> addNote(note));
        //songFile.events.fastForEach((event, i) -> addEvent(event));
    }

    function loadSong(name:String, difficulty:String)
    {
        var file = Song.checkSong(Song.loadFromFile(difficulty, name));
        Conductor.loadSong(name);
        
        songFile = {
            notes: [],
            events: [],
            bpms: [{time: 0, bpm: file.bpm}]
        }
        
        file.notes.fastForEach((section, i) -> {
            section.sectionNotes.fastForEach((note, i) -> songFile.notes.push(note));
            section.sectionEvents.fastForEach((event, i) -> songFile.events.push(event));
        });

        reload();
    }
}

class Grid extends Group
{
    inline public static var tileSize:Int = 40;

    public var notesGrid:FlxBackdrop;
    public var eventsGrid:FlxBackdrop;

    public var notes:TypedGroup<ChartNote>;
    public var events:TypedGroup<ChartEvent>;

    public function new() {
        super();

        notesGrid = new FlxBackdrop(makeGrid(8), Y);
        notesGrid.screenCenter(X);
        add(notesGrid);
        
        eventsGrid = new FlxBackdrop(makeGrid(1), Y);
        eventsGrid.x = (notesGrid.x + notesGrid.width) + (tileSize / 2);
        add(eventsGrid);

        notes = new TypedGroup<ChartNote>();
        add(notes);

        events = new TypedGroup<ChartEvent>();
        add(events);
    }

    function makeGrid(lanes:Int) {
        return FlxGridOverlay.createGrid(
            tileSize, tileSize,
            tileSize * lanes, tileSize * 18,
            true, 0xff7c7c7c, 0xff6e6e6e
        );
    }
}

class GridItem extends SpriteGroup
{
    
}

class ChartNote extends GridItem
{
    var note:Note;
    var sustain:Sustain;

    public function new() {
        super(0,0,2);

        note = new Note();
        sustain = new Sustain();

        add(sustain);
        add(note);

        note.setGraphicSize(Grid.tileSize);
        note.updateHitbox();

        sustain.setScale(note.scale.x, true);
    }

    public function load(data:NoteJson, crochet:Float)
    {
        note.noteData = sustain.noteData = data.lane;
        note.updateAnim();

        //sustain.repeatHeight = 
    }
}

class ChartEvent extends GridItem
{

}