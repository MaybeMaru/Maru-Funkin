package funkin.util.song.formats;

/*
    Custom made qua (quaver) to fnf json format for mau engin
    DOES NOT CONVERT .QP FILES YET, ONLY .QUA CHART FILES!!!!!!
*/

class QuaFormat {
    public var map:Array<String> = [];
    public function new(path:String) {
        map = CoolUtil.getFileContent(path).split('\n');
    }
    
    public static function convertSong(path:String, ?input:QuaFormat):SongJson {
        var quaMap:QuaFormat = input ?? new QuaFormat(path);
        var fnfMap:SongJson = Song.getDefaultSong();

        // Check if map is above 4 keys
        if (quaMap.getVar('Mode') != 'Keys4') {
            return fnfMap;
        }

        var title = quaMap.getVar('Title');
        var bpm = FlxMath.roundDecimal(quaMap.getVar('Bpm'), 1);
        var speed = quaMap.getVar('InitialScrollVelocity');
        var hitObjects = quaMap.getHitObjects();

        var sections:Array<SectionJson> = [];
        for (i in 0...Lambda.count(hitObjects)) {
            var newSec:SectionJson = Song.getDefaultSection();
            if (hitObjects.get(i) != null)
                newSec.sectionNotes = hitObjects.get(i);
            sections.push(newSec);
        }

        fnfMap.song = title;
        fnfMap.notes = sections;
        fnfMap.bpm = bpm;
        fnfMap.offsets = [0,0];//[-offset,0];
        fnfMap.speed = FlxMath.roundDecimal(speed, 1);

        return fnfMap;
    }

    public function getVar(mapVar:String):Dynamic {
        for (line in map) {
            if (line.startsWith('$mapVar: ') || line.startsWith('- $mapVar: ') || line.startsWith('  $mapVar:')) {
                var retVar:String = line.split('$mapVar: ')[1].trim();
                return Std.string(retVar.replace('\r','').replace('\n',''));
            }
        }
        return null;
    }

    public function getHitObjects():Map<Int,Array<Array<Dynamic>>> {
        var returnMap:Map<Int,Array<Array<Dynamic>>> = new Map<Int,Array<Array<Dynamic>>>();
        var crochet:Float = (60 / getVar('Bpm')) * 1000;

        for (l in 0...map.length) {
            if (map[l].startsWith('- StartTime: ')) {
                var strumTime = Std.parseInt(map[l].split('- StartTime: ')[1].trim());
                var noteData = Std.parseInt(map[l + 1].split('  Lane: ')[1].trim()) - 1;
                if (noteData >= 0) {
                    var susLength = 0.0;
                    if (map[l + 2].startsWith('  EndTime: ')) { // Get sus length if variable exists
                        susLength = Std.parseInt(map[l + 2].split('  EndTime: ')[1].trim()) - strumTime;
                        susLength -= crochet / 4;
                    }
    
                    var noteSec = Std.int(strumTime/(crochet*4));
                    var noteSecArray = (returnMap.get(noteSec) != null) ? returnMap.get(noteSec) : [];
                    noteSecArray.push([strumTime,noteData,susLength]);
                    returnMap.set(noteSec, noteSecArray);
                }
            }
        }

        return returnMap;
    }
}