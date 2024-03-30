package funkin.util.song;

import haxe.ds.Vector;

/*
 * Making these classes because working with all typedefs is a bit of a mess
 * Also it compiles and depends a lot on Dynamic objects which sucks for safe code
**/

abstract class Meta extends Song
{
    public var diffs:Array<String> = new Array<String>();

    override function fromJson(input:SongJSON):Song
    {
        
        return super.fromJson(input);
    }

    public function embed(song:Song)
    {
        if (!diffs.contains(song.diff))
            return;

        for (i in 0...2)
            song.offsets.set(i, offsets.get(i));

        sections.fastForEach((section, i) -> {
            while (song.sections[i] == null)
                song.sections.push(Section.make());
            
            section.notes.fastForEach((note, i) -> song.sections.unsafeGet(i).notes.push(note));
            section.events.fastForEach((event, i) -> song.sections.unsafeGet(i).events.push(event));
        });
    }
}

class Song
{
	public var sections:Array<Section>;

	public var BPM:Float;
	public var speed:Float;
	public var offsets:Vector<Int>;

    public var title:String;
    public var diff:String;
	public var stage:String;
	public var players:Vector<String>;

    public function new() {}

    inline static var CHART_VERSION:Int =  0;

    public function toJson():SongJSON
    {
        var output:SongJSON = {
            version: CHART_VERSION,

            song: title,
	        notes: [],
	        bpm: BPM,
            speed: speed,
            stage: stage,
	        offsets: offsets.toArray(),
	        players: players.toArray()
        }

        sections.fastForEach((section, i) -> output.notes.push(section.toJson()));

        return output;
    }

    public function fromJson(input:SongJSON)
    {
        title = input.song;
        stage = input.stage;
        BPM = input.bpm;
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

    // BACKWARDS COMPATIBILITY

    public var song(get, never):String;
    function get_song() return this.title;
}

class Section {
	public var notes:Array<SongNote>;
	public var events:Array<SongEvent>;

	public var mustHit:Bool;
	public var changeBPM:Bool;
	public var BPM:Float;

    public function new() {}

    public static function make():Section {
        var section = new Section();
        
        section.mustHit = true;
        section.changeBPM = false;
        section.BPM = 0;

        section.notes = new Array<SongNote>();
        section.events = new Array<SongEvent>();

        return section;
    }

    public function toJson():SectionJSON {
        return {
            sectionNotes: notes,
            sectionEvents: events,
            mustHitSection: mustHit,
            changeBPM: changeBPM,
            bpm: BPM
        }
    }

    public static function fromJson(input:SectionJSON):Section {
        var section = new Section();

        section.mustHit = input.mustHitSection;
        section.changeBPM = input.changeBPM;
        section.BPM = input.bpm;

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
	public static function fromArray(array:Array<Dynamic>):SongNote {
        return array;
    }
}

abstract SongEvent(Array<Dynamic>) from Array<Dynamic> to Array<Dynamic> {
	public static function fromArray(array:Array<Dynamic>):SongEvent {
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
	var notes:Array<SwagSection>;
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