package funkin.util.song;

import haxe.ds.Vector;

/*
 * Making these classes because working with all typedefs is a bit of a mess
 * Also it compiles and depends a lot on Dynamic objects which sucks for safe code
**/

abstract class Meta extends Song
{
    public var diffs:Array<String> = new Array<String>();

    public function fromMetaJson(input:MetaJSON):Song {
        diffs.splice(0, diffs.length);
        input.diffs.fastForEach((diff, i) -> diffs.push(diff));
        return fromJson(input);
    }

    /**Embed the meta variables into the song**/
    public function embed(song:Song)
    {
        if (!diffs.contains(song.diff))
            return;

        song.meta = this;

        for (i in 0...2)
            song.offsets.set(i, offsets.get(i));

        sections.fastForEach((section, i) -> {
            while (song.sections[i] == null)
                song.sections.push(Section.make());
            
            //section.notes.fastForEach((note, i) -> song.sections.unsafeGet(i).notes.push(note));
            section.events.fastForEach((event, i) -> song.sections.unsafeGet(i).events.push(event));
        });
    }
}

class Song implements IFlxDestroyable
{
	public var sections:Array<Section>;
    public var meta:Meta;

	public var bpm:Float;
	public var speed:Float;
	public var offsets:Vector<Int>;

    public var title:String;
    public var diff:String;
	public var stage:String;
	public var players:Vector<String>;

    public function new() {}

    public function destroy():Void {
        sections.fastForEach((section, i) -> sections.unsafeSet(i, FlxDestroyUtil.destroy(section)));
        sections = null;
        meta = null;
        offsets = null;
        players = null;
    }

    /**Map containing pre-calculated section times for the chart editor**/
    public var sectionTimes:Map<Int, Float> = new Map<Int, Float>();

    /**Returns the time the section index starts at**/
    public inline function getSectionTime(section:Int):Float {
        return sectionTimes.get(section);
    }

    /**Returns the index the section time starts at**/
    public inline function getTimeSection(time:Float):Int {
        for (i in 0...Lambda.count(sectionTimes)) {
            if (time >= sectionTimes.get(i))
                return i;
        }
        return 0;
    }
    
    /**Use this to reload the values of ``sectionTimes``**/
    public function reloadSectionTimes():Map<Int, Float>
    {
        sectionTimes.clear();

        var bpm = this.bpm;
        var time = 0.0;
        sections.fastForEach((section, i) -> {
            if (section.changeBPM)
                bpm = section.bpm;

            sectionTimes.set(i, time);
            time += Conductor.BEATS_PER_MEASURE * (60000 / bpm);
        });

        return sectionTimes;
    }

    /**Gets a section from an index and makes sure the sections length is big enough for the index**/
    public function getSection(index:Int):Section
    {
        while ((sections.length - 1) < index) {
            sections.push(Section.make());
        }
        return sections.unsafeGet(index);
    }

    /**Returns a song's notes as a sorted array**/
    public static function getSongNotes(diff:String, song:String):Array<SongNote> {
        return SongUtil.loadFromFile(diff, song).getNotes();
    }

    /**Returns the song's notes as a sorted array**/
    public function getNotes():Array<SongNote>
    {
        var notes:Array<SongNote> = [];
        sections.fastForEach((section, i) -> {
            section.notes.fastForEach((note, i) -> notes.push(note));
        });

        notes.sort(SongUtil.sortNotes);
        return notes;
    }

    inline static var CHART_VERSION:Int =  0;

    /**Outputs the song into the engine's chart JSON format**/
    public function toJson():SongJSON
    {
        var output:SongJSON = {
            version: CHART_VERSION,

            song: title,
	        notes: [],
	        bpm: bpm,
            speed: speed,
            stage: stage,
	        offsets: offsets.toArray(),
	        players: players.toArray()
        }

        sections.fastForEach((section, i) -> output.notes.push(section.toJson()));

        return output;
    }

    /**Creates a default song instance**/
    public static function getDefaultSong():Song
    {
        return new Song().fromJson(SongUtil.getDefaultSong());
    }

    /**Loads up a song instance from a json chart input**/
    public function fromJson(input:SongJSON):Song
    {
        title = input.song;
        stage = input.stage;
        bpm = input.bpm;
        speed = input.speed;

        sections = new Array<Section>();
        input.notes.fastForEach((section, i) -> {
            sections.push(Section.fromJson(section));
        });

        offsets = new Vector<Int>(2, 0);
        for (i in 0...2) offsets.set(i, input.offsets.unsafeGet(i));

        players = new Vector<String>(3, "bf");
        for (i in 0...3) players.set(i, input.players.unsafeGet(i));

        return this;
    }

    // FOR BACKWARDS COMPATIBILITY

    public var song(get, never):String;
    function get_song() return this.title;
}

class Section implements IFlxDestroyable
{
	public var notes:Array<SongNote>;
	public var events:Array<SongEvent>;

	public var mustHit:Bool;
	public var changeBPM:Bool;
	public var bpm:Float;

    public function new() {}

    public function destroy():Void {
        notes = null;
        events = null;
    }

    public static function make():Section {
        var section = new Section();
        
        section.mustHit = true;
        section.changeBPM = false;
        section.bpm = 0;

        section.notes = new Array<SongNote>();
        section.events = new Array<SongEvent>();

        return section;
    }

    public static function getDefaultSection():Section {
        return fromJson(SongUtil.getDefaultSection());
    }

    public function toJson():SectionJSON {
        return {
            sectionNotes: notes,
            sectionEvents: events,
            mustHitSection: mustHit,
            changeBPM: changeBPM,
            bpm: bpm
        }
    }

    public static function fromJson(input:SectionJSON):Section {
        var section = new Section();

        section.mustHit = input.mustHitSection;
        section.changeBPM = input.changeBPM;
        section.bpm = input.bpm;

        section.notes = new Array<SongNote>();
        input.sectionNotes.fastForEach((note, i) -> {
            section.notes.push(SongNote.fromArray(note));
        });

        section.events = new Array<SongEvent>();
        input.sectionEvents.fastForEach((event, i) -> {
            section.events.push(SongEvent.fromArray(event));
        });

        return section;
    }
}

abstract SongNote(Array<Dynamic>) from Array<Dynamic> to Array<Dynamic> {
	public static inline function fromArray(array:Array<Dynamic>):SongNote {
        return array;
    }
}

abstract SongEvent(Array<Dynamic>) from Array<Dynamic> to Array<Dynamic> {
	public static inline function fromArray(array:Array<Dynamic>):SongEvent {
        return array;
    }
}

/**-- JSON FORMAT SHIT --**/

typedef MetaJSON = {
	var diffs:Array<String>;
} & SongJSON

typedef SongJSON = {
    var version:Int;

	var song:String;
	var notes:Array<SectionJSON>;
	var bpm:Float;
	var speed:Float;
	var offsets:Array<Int>;
	var stage:String;
	var players:Array<String>;
}

typedef SectionJSON = {
    var ?sectionNotes:Array<Array<Dynamic>>;
	var ?sectionEvents:Array<Array<Dynamic>>;
	var ?mustHitSection:Bool;
	var ?bpm:Float;
	var ?changeBPM:Bool;
}