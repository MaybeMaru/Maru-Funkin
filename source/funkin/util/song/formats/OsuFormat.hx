package funkin.util.song.formats;

/*
    Custom made osu to fnf json format for mau engin
    DOES NOT CONVERT .OSZ FILES YET, ONLY .OSU CHART FILES!!!!!!
*/

class OsuFormat {
    public var map:Array<String> = [];
    public function new(path:String) {
        map = CoolUtil.getFileContent(path).split('\n');
    }
    
    inline public static function convertSong(path:String, ?input:OsuFormat):SongJSON {
        var osuMap:OsuFormat = input ?? new OsuFormat(path);
        var fnfMap:SongJSON = Song.getDefaultSong();

        //  Check if its not an osu!mania map
        final mode = Std.parseInt(osuMap.getVar('Mode'));
        if (mode != 3)
            return fnfMap;

        var title = osuMap.getVar('Title');
        var version = osuMap.getVar('Version');
        var timingPoints = osuMap.getTimingPoints();
        var offset = timingPoints[0];
        var bpm = FlxMath.roundDecimal(60000 / timingPoints[1], 1);
        var speed = Std.parseFloat(osuMap.getVar('OverallDifficulty'));
        var hitObjects =  osuMap.getHitObjects();

        var sections:Array<SwagSection> = [];
        for (i in 0...Lambda.count(hitObjects)) {
            var newSec:SwagSection = Song.getDefaultSection();
            if (hitObjects.get(i) != null)
                newSec.sectionNotes = hitObjects.get(i);
            sections.push(newSec);
        }

        fnfMap.song = title;
        fnfMap.notes = sections;
        fnfMap.bpm = bpm;
        fnfMap.offsets = [0,0];//[-offset,0];
        fnfMap.speed = FlxMath.roundDecimal(speed/2.5, 1);
        return fnfMap;
    }

    public function getVar(mapVar:String):Null<String> {
        for (line in map) {
            if (line.startsWith(mapVar)) {
                var retVar:String = line.split('$mapVar:')[1].trim();
                return retVar.replace('\r','').replace('\n','');
            }
        }
        return null;
    }

    public function getTimingPoints():Array<Dynamic> {
        for (i in 0...map.length) {
            if (map[i].startsWith('[TimingPoints]')) {
                var returnArray:Array<Dynamic> = [];
                for (tm in map[i+1].split(','))
                    returnArray.push(Std.parseFloat(tm));
                return returnArray;
            }
        }
        return [];
    }

    public function getHitObjects():Map<Int,Array<Array<Dynamic>>> {
        var returnMap:Map<Int,Array<Array<Dynamic>>> = new Map<Int,Array<Array<Dynamic>>>();
        var mapCircleSize = Std.parseInt(getVar('CircleSize'));
        var bpmMills = getTimingPoints()[1];

        for (l in 0...map.length) {
            if (map[l].startsWith('[HitObjects]')) {
                for (i in l...map.length-1) {
                    if (!(map[i].length > 0 && map[i].contains(','))) continue; // Not a hit object, skip
                    var hitObject:Array<Dynamic> = [];
                    var hitData = map[i].split(',');
                    for (n in 0...hitData.length) {
                        if (hitData[n].contains(':')) {
                             hitData[n] = hitData[n].split(':')[0];
                        }
                        hitObject.push(Std.parseInt(hitData[n]));
                    }
                    var strumTime = hitObject[2];
                    var noteData = Math.floor(hitObject[0] * mapCircleSize / 512);
                    var susLength = (hitObject[5] > 0) ? (hitObject[5] - strumTime) : 0;
                    var noteSec = Std.int(strumTime/(bpmMills*4));
                    var noteSecArray = (returnMap.get(noteSec) != null) ? returnMap.get(noteSec) : [];
                    noteSecArray.push([strumTime,noteData,susLength]);
                    returnMap.set(noteSec, noteSecArray);
                }
                break;
            }
        }
        return returnMap;
    }
}