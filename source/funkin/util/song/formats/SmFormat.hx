package funkin.util.song.formats;

/*
    Custom made sm (stepmania) to fnf json format for mau engin
    DOES NOT CONVERT ZIP PACK FILES YET, ONLY .SM CHART FILES!!!!!!
*/

typedef BpmChanges = Array<{measure:Int, bpm:Float}>;
typedef SmSection = {notes:Array<Array<Dynamic>>, changeBpm:Bool, bpm:Float};

class SmFormat {
    public static function convertSong(path:String, diff:String):SwagSong {
        var smMap:Array<String> = CoolUtil.getFileContent(path).split('\n');
        var fnfMap:SwagSong = Song.getDefaultSong();

        var title = getMapVar(smMap, 'TITLE');
        var offset = Std.int(Std.parseFloat(getMapVar(smMap, 'OFFSET'))*1000);
        var bpm = 0.0;
        
        var bpmChanges:BpmChanges = [];
        for (i in getMapVar(smMap, 'BPMS').split(",")) {
            final data = i.split("=");
            bpmChanges.push({
                measure: Std.int(Std.parseFloat(data[0]) * 0.25),
                bpm:  Std.parseFloat(data[1])
            });
        }
        bpm = bpmChanges[0].bpm;
        
        var notes = getMapNotes(smMap, bpmChanges, diff);
        var sections:Array<SwagSection> = [];
        for (i in 0...Lambda.count(notes)) {
            final newSec:SwagSection = Song.getDefaultSection();
            final data = notes.get(i);
            if (notes.get(i) != null) {
                newSec.sectionNotes = data.notes;
                newSec.changeBPM = data.changeBpm;
                newSec.bpm = data.bpm;
            }
            sections.push(newSec);
        }

        fnfMap.song = title;
        fnfMap.notes = sections;
        fnfMap.bpm = bpm;
        trace(offset);
        fnfMap.offsets = [offset,0];
        return fnfMap;
    }

    private static function getMapVar(map:Array<String>, mapVar:String):String {
        for (l in 0...map.length) {
            final line = map[l];
            if (line.startsWith('#$mapVar')) {
                var retVar:String = line.split('#$mapVar:')[1].trim().replace('\r','').replace('\n','');
                if (!retVar.endsWith(";")) {
                    var i:Int = l + 1;
                    while (!map[i].endsWith(";") && !map[i].startsWith(";")) {
                        retVar += map[i].trim().replace('\r','').replace('\n','');
                        i++;
                    }
                }

                retVar = (retVar.endsWith(';')) ? retVar.substring(0, retVar.length - 1) : retVar;
                return retVar;
            }
        }
        return null;
    }

    static inline function cleanStr(s:String):String
        return Std.string(s).trim().replace('\r','').replace('\n','');

    private static function getMapNotes(map:Array<String>, bpmChanges:BpmChanges, diff:String):Map<Int, SmSection> {
        var bpm = bpmChanges[0].bpm;
        bpmChanges.remove(bpmChanges[0]);
        
        var crochet:Float = ((60 / bpm) * 1000); 	// beats in milliseconds
        var stepCrochet:Float = crochet / 4; 		// steps in milliseconds
        var sectionCrochet:Float = crochet * 4; 	// sections in milliseconds
        
        var returnMap:Map<Int, SmSection> = [];
        var noteMeasures:Map<Int,Array<String>> = [];

        // Get the line measures actually start
        var notesLine:Int = 0;
        var _diff:String = null;
        for (l in 0...map.length) {
            if (map[l].startsWith("#NOTES:")) {
                for (i in l...map.length) {
                    if (map[i].trim().toLowerCase().startsWith(diff)) // Find diff
                        _diff = diff;

                    if (cleanStr(map[i]).length == 4) {
                        if (_diff == diff) { // STARTED NOTES, WOW!! (cries)
                            notesLine = i;
                            break;
                        }
                    }
                }
                break;
            }
        }

        var measure:Int = 0;
        for (l in notesLine...map.length) {
            var noteLine = map[l].trim();
            if (noteLine.length <= 0) continue;
            if (noteLine == ';') break;
            if (noteLine.startsWith(",")) { // new measure
                measure++;
            } else { // Push notes to measure
                var lastMeasureData:Array<String> = noteMeasures.get(measure) ?? [];
                lastMeasureData.push(noteLine);
                noteMeasures.set(measure, lastMeasureData);
            }
        }

        var strumTime:Float = 0;
        for (i in 0...Lambda.count(noteMeasures)) { // Measures            
            if (noteMeasures.get(i) == null) continue;
            final measureArray:Array<String> = noteMeasures.get(i);
            final stepsPerLine = 16 / measureArray.length;

            final smSec:SmSection = {
                notes: [],
                changeBpm: false,
                bpm: 0
            }

            for (l in 0...measureArray.length) { // Lines
                final measurePerc = i + (l + 1) / measureArray.length;

                var lastChange = null;
                for (change in bpmChanges) {
                    if (change.measure <= measurePerc) {
                        lastChange = change;
                        bpmChanges.remove(change);
                    }
                }

                if (lastChange != null) {
                    crochet = ((60 / lastChange.bpm) * 1000);
                    stepCrochet = crochet / 4;
                    sectionCrochet = crochet * 4;

                    smSec.changeBpm = true;
                    smSec.bpm = lastChange.bpm;
                }


                strumTime += stepCrochet * stepsPerLine;
                final line = measureArray[l].split('');
                for (n in 0...line.length) {    // Notes
                    switch (line[n]) {
                        case '1':// Normal note
                            smSec.notes.push([strumTime,n,0]);
                        case '2':// Hold head
                            var susLengthInt = findSusLength(measureArray, [l,n]);
                            var susLength = stepCrochet * stepsPerLine * susLengthInt;
                            smSec.notes.push([strumTime,n,susLength]);
                        //case '4':// Roll head
                        //case 'M':// Mine
                        default:
                    }
                }
            }

            returnMap.set(i, smSec);
        }

        return returnMap;
    }

    inline private static function findSusLength(measure:Array<String>, startSus:Array<Int>):Int {
        var steps:Int = 0;
        for (i in startSus[0]...measure.length) {
            if (measure[i].split('')[startSus[1]] == '3') {
                break;
            }
            steps++;
        }
        return steps;
    }
}