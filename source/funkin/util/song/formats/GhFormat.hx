package funkin.util.song.formats;

class GhFormat {
    public var map:Array<String> = [];
    public function new(path:String) {
        map = CoolUtil.getFileContent(path).split('\n');
    }
    
    public static function convertSong(path:String, ?input:GhFormat):SwagSong {
        var ghMap:GhFormat = input ?? new GhFormat(path);
        var fnfMap:SwagSong = Song.getDefaultSong();

        final title = ghMap.getVar("Name");
        final bpmMap = ghMap.getBpmChanges();
        fnfMap.bpm = bpmMap.get(0);
        
        // Bpm changes crap
        var _sortedChanges:Array<Int> = [];
        for (i in bpmMap.keys()) {
            if (i <= 0) continue;
            _sortedChanges.push(i);
        }
        _sortedChanges.sort(function (a,b) return FlxSort.byValues(FlxSort.ASCENDING,  a, b));
        
        for (i in _sortedChanges) {
            var _sec:Int = Song.getTimeSection(fnfMap, i)+1;
            Song.checkAddSections(fnfMap, _sec);
            fnfMap.notes[_sec].changeBPM = true;
            fnfMap.notes[_sec].bpm = bpmMap.get(i);
        }

        for (i in ghMap.getNotes()) {
            fnfMap.notes[Song.getTimeSection(fnfMap, i[0])].sectionNotes.push(i);
        }

        fnfMap.song = title;
        
        return fnfMap;
    }

    public function getVar(varName:String) {
        for (i in map) {
            if (i.startsWith('  $varName')) {
                var retVar = i.split('$varName = ')[1].trim();
                return Std.string(retVar.replace('\r','').replace('\n','').replace('"', ''));
            }
        }
        return null;
    }

    public function getBpmChanges():Map<Int, Float> {
        var bpmChanges:Map<Int, Float> = [];
        for (i in map) {
            if (i.contains(" = B ")) {
                var _split = i.split(" = B ");
                var time = Std.parseInt(_split[0]);
                var bpm = Std.parseInt(_split[1])/1000;
                bpmChanges.set(time, bpm);
            }
        }
        return bpmChanges;
    }

    public function getNotes() {
        var notes:Array<Array<Float>> = [];
        var _bpm = getBpmChanges().get(0);
        var crochet:Float = (60 /_bpm) * 1000;
        var tickToMills = (60000 / (_bpm * Std.parseInt(getVar("Resolution"))));
        
        for (_ in 0...map.length) {
            if (map[_].startsWith("[ExpertSingle]")) {
                for (n in _+2...map.length) {
                    if (map[n] == "}") break;
                    if (map[n].contains("E") || map[n].contains("S")) continue;

                    final _note = map[n].trim().replace(" = N ", " ");
                    var note:Array<Float> = [];
                    for (i in _note.split(" ")) {
                        note.push(Std.parseInt(i));
                    }

                    note[0] *= tickToMills;
                    if (note[2] > 0) {
                        note[2] *= tickToMills;
                        note[2] -= crochet * 0.25;
                    } else {
                        note[2] = 0;
                    }
                    notes.push(note);
                }
                break;
            }
        }

        return notes;
    }
}