package funkin.util.song.formats;

/*
    Custom made sm (stepmania) to fnf json format for mau engin
    DOES NOT CONVERT ZIP PACK FILES YET, ONLY .SM CHART FILES!!!!!!
*/

class SmFormat {
    inline public static function convertSong(path:String):SwagSong {
        var smMap:Array<String> = CoolUtil.getFileContent(path).split('\n');
        var fnfMap:SwagSong = Song.getDefaultSong();

        var title = getMapVar(smMap, 'TITLE');
        var offset = Std.int(getMapVar(smMap, 'OFFSET')*1000);
        var bpm = Std.parseFloat(getMapVar(smMap, 'BPMS').split('=')[1]);
        var notes = getMapNotes(smMap, bpm);

        var sections:Array<SwagSection> = [];
        for (i in 0...Lambda.count(notes)) {
            var newSec:SwagSection = Song.getDefaultSection();
            if (notes.get(i) != null) {
                newSec.sectionNotes = notes.get(i);
            }
            sections.push(newSec);
        }

        fnfMap.song = title;
        fnfMap.notes = sections;
        fnfMap.bpm = bpm;
        fnfMap.offsets = [offset,0];
        return fnfMap;
    }

    private static function getMapVar(map:Array<String>, mapVar:String):Dynamic {
        for (line in map) {
            if (line.startsWith('#$mapVar')) {
                var retVar:String = line.split('#$mapVar:')[1].trim();
                retVar = (retVar.endsWith(';')) ? retVar.substring(0, retVar.length - 1) : retVar;
                return Std.string(retVar.replace('\r','').replace('\n',''));
            }
        }
        return null;
    }

    inline private static function getMapNotes(map:Array<String>, bpm:Float):Map<Int,Array<Dynamic>> {
        var crochet:Float = ((60 / bpm) * 1000); 	// beats in milliseconds
        var stepCrochet:Float = crochet / 4; 		// steps in milliseconds
        var sectionCrochet:Float = crochet * 4; 	// sections in milliseconds
        
        var returnMap:Map<Int,Array<Dynamic>> = new Map<Int,Array<Dynamic>>();
        var noteMeasures:Map<Int,Array<String>> = new Map<Int,Array<String>>();
        for (l in 0...map.length) {
            if (map[l].contains('// measure 1') || map[l].contains('// measure 0')) {
                var lastMeasure:Int = 0;
                for (i in (l+1)...map.length-2) {
                    var noteLine = '${map[i]}'.trim();
                    if (noteLine.length > 0 && noteLine != ';') {
                        if (noteLine.startsWith(',')) {
                            lastMeasure = Std.parseInt(noteLine.split('// measure ')[1]) + (map[l].contains('// measure 1') ? -1 : 0);
                        } else {
                            var lastMeasureData:Array<String> = noteMeasures.get(lastMeasure) != null ? noteMeasures.get(lastMeasure) : [];
                            lastMeasureData.push(noteLine);
                            noteMeasures.set(lastMeasure, lastMeasureData);
                        }
                    }
                }
                break;
            }
        }

        for (i in 0...Lambda.count(noteMeasures)) { //Measures
            if (noteMeasures.get(i) != null) {
                var measureArray:Array<String> = noteMeasures.get(i);
                var measureTime = sectionCrochet * i;
                var secArray = (returnMap.get(i) != null) ? returnMap.get(i) : [];

                var beatsPerLine = 4/measureArray.length;
                var stepsPerLine = 16/measureArray.length;

                for (l in 0...measureArray.length) { //Lines
                    var strumTime = measureTime + (stepCrochet * l * stepsPerLine);
                    
                    var line = measureArray[l].split('');
                    for (n in 0...line.length) {    //Notes
                        var noteData = n;

                        switch (line[n]) {
                            //case '0'://No note
                            case '1'://Normal note
                                secArray.push([strumTime,noteData,0]);
                            case '2'://Hold head
                                var susLengthInt = findSusLength(measureArray, [l,noteData]);
                                var susLength = stepCrochet * stepsPerLine * susLengthInt;
                                secArray.push([strumTime,noteData,susLength]);
                            //case '3'://Hold/Roll tail
                            //case '4'://Roll head
                            //case 'M'://Mine
                            default:
                        }
                    }
                }
                returnMap.set(i, secArray);
            }
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

/*
                ~Maru going insane episode 5436~

    The whole length of a measure corresponds ALWAYS to 4 beats
    So by taking that information a heres the corresponding sizes
    4 lines     --> 1 beat per line         --> 4 steps per line
    8 lines     --> 0.5 beat per line       --> 2 steps per line
    12 lines    --> 0.33 beat per line      --> 1.33 steps per line
    16 lines    --> 0.25 beats per line     --> 1 step per line
    32 lines    --> 0.125 beats per line    --> 0.5 steps per line
    48 lines    --> 0.0833 beat per line    --> 0.33 steps per line
    64 lines    --> 0.0625 beats per line   --> 0.25 steps per line
    192 lines   --> 0.0208 beats per line   --> 0.0833 steps per line

    00000000 -> beat 0 -> step 0
    00000000 -> beat 1 -> step 4
    00000000 -> beat 2 -> step 8
    00000000 -> beat 3 -> step 12

    That should be all i think, idk if thats how it actually works but im running with that lol
*/