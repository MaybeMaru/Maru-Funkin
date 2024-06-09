package funkin.util.song.formats;

typedef BasicBpmChange = {
    time:Float,
    bpm:Float
}

typedef ChartVar = {
    name:String,
    value:String
}

typedef BasicSection = {
    notes:Array<Array<Dynamic>>,
    bpm:Float // set to -1 if no changes
}

class BasicParser {
    var variables:Map<String, String> = [];
    var bpmChanges:Array<BasicBpmChange> = [];
    
    var map:Array<String> = [];
    var fnfMap:SongJson;

    public function new() {}
    
    public function convertSong(path:String, diff:String):SongJson {
        map = CoolUtil.getFileContent(path).split('\n');
        fnfMap = Song.getDefaultSong();

        __initVars();
        applyVars(variables, fnfMap);
        parseBpmChanges(map, bpmChanges);

        final split = path.split("/");
        fnfMap.song = split[split.length - 3];
        fnfMap.bpm = bpmChanges[0]?.bpm ?? 100.0;
        
        final sections = parseNotes(diff);
        if (sections != null) {
            for (section in sections) {
                final newSec:SectionJson = Song.getDefaultSection();
                newSec.sectionNotes = section.notes;
                newSec.changeBPM = section.bpm != -1;
                newSec.bpm = section.bpm;
                
                fnfMap.notes.push(newSec);
            }
        }

        return fnfMap;
    }

    function parseBpmChanges(map:Array<String>, bpmChanges:Array<BasicBpmChange>):Void {}

    function applyVars(variables:Map<String, String>, fnfMap:SongJson):Void {}
    
    function parseNotes(diff:String):Array<BasicSection> {
        return null;
    }

    var doop:Int = 0;

    @:noCompletion
    function __initVars():Void {
        for (i in 0...map.length) {
            final _var = __resolveVar(map[i], i);
            if (_var != null) {
                variables.set(variables.exists(_var.name) ? _var.name + (doop++) :  _var.name, _var.value);
            }
        }
    }

    @:noCompletion
    function __resolveVar(line:String, index:Int):ChartVar {
        return null;
    }
}