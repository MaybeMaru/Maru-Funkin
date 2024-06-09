package funkin.util.song.formats;

import funkin.util.song.formats.BasicParser.ChartVar;
import funkin.util.song.formats.BasicParser.BasicSection;
import funkin.util.song.formats.BasicParser.BasicBpmChange;

/**
 * Custom made sm (stepmania) to fnf json format for mau engin
 * @author maybemaru
 */

class SmFormat extends BasicParser {
    public static function convert(path:String, diff:String):SongJson {
        return new SmFormat().convertSong(path, diff);
    }

    override function applyVars(variables:Map<String, String>, fnfMap:SongJson) {
        fnfMap.offsets = [Std.int(Std.parseFloat(variables.get('OFFSET')) * -1000), 0];
        fnfMap.speed = 2.5;
    }

    override function parseBpmChanges(map:Array<String>, bpmChanges:Array<BasicBpmChange>) {
        for (i in variables.get("BPMS").split(",")) {
            final data = i.split("=");
            bpmChanges.push({
                time: Std.parseFloat(data[0]) * 0.25, // Calculated in measures
                bpm: Std.parseFloat(data[1])
            });
        }
    }

    override function __resolveVar(line:String, index:Int):ChartVar {
        if (line.trim().startsWith("#")) {
            var varName:String = line.split(":")[0];   
            varName = varName.substring(1, varName.length); 

            var retVar:String = line.split('$varName:')[1].trim().replace('\r','').replace('\n','');
            if (!retVar.endsWith(";")) {
                index++;
                while (!map[index].endsWith(";") && !map[index].startsWith(";")) {
                    var lineValue = map[index].trim().replace('\r','').replace('\n','');
                    if (!lineValue.contains("// measure"))  retVar += lineValue; // I have no idea why this exists, only makes parsing harder
                    else retVar += ",";

                    if (lineValue.length == 4) {
                        retVar += "-";
                    }
                    
                    index++;

                    if (index > map.length) {
                        throw("Couldnt get variable for " + varName);
                        break;
                    }
                }
            }

            return {
                name: varName,
                value: (retVar.endsWith(';')) ? retVar.substring(0, retVar.length - 1) : retVar
            }
        }

        return null;
    }

    var foundDiffs:Array<String> = [];

    override function parseNotes(diff:String):Array<BasicSection> {
        var baseNotes:Array<String> = [];
        for (name => variable in variables) {
            if (name.startsWith("NOTES")) {
                baseNotes.push(variable);
            }
        }

        for (chart in baseNotes) {
            var parts = chart.split(":");
            var chartDiff:String = parts[2].toLowerCase();
            foundDiffs.push(chartDiff);
            
            if (diff == chartDiff) {
                return parseSm(parts[5].substr(0, parts[5].length - 1));
            }
        }
        
        throw("Couldn't find StepMania chart for difficulty " + diff + "\nFound difficulties " + foundDiffs.toString());
        return null;
    }

    function parseSm(notes:String):Array<BasicSection> {
        // For ease of use, diving it
        var sections:Array<Array<String>> = [];
        for (sec in notes.split(",")) {
            sections.push(sec.split("-"));
        }

        var sectionsVector:Array<BasicSection> = [];
        for (i in 0...sections.length) {
            sectionsVector.push({
                notes: [],
                bpm: -1
            });
        }

        var curBpm:Float = bpmChanges[0].bpm;
        bpmChanges.remove(bpmChanges[0]);

        var position:Float = 0.0;
        var measurePosition:Float = -1.0;
        
        var crochet:Float = 0.0;
        
        var recalc = function (index:Int) {
            crochet = (60 / curBpm) * (4 / sections[index].length) * 1000;
        }

        for (i in 0...sections.length) {
            recalc(i);

            for (l in 0...sections[i].length) {
                //Check for bpm changes
                if (bpmChanges[0] != null) {
                    while (bpmChanges[0].time <= measurePosition) {
                        curBpm = bpmChanges[0].bpm;
                        sectionsVector[i].bpm = curBpm;
                        recalc(i);

                        bpmChanges.remove(bpmChanges[0]);
                        if (bpmChanges[0] == null) break;
                    }
                }
                
                // Add line notes
                var lineSplit = sections[i][l].split("");
                for (n in 0...lineSplit.length) {
                    switch (lineSplit[n]) {
                        case '1':// Normal note
                            sectionsVector[i].notes.push([position, n, 0.0]);
                        case '2':// Hold head
                            sectionsVector[i].notes.push([position, n, resolveSustain(sections[i], l, n, crochet)]);
                        case '4':// Roll head
                            sectionsVector[i].notes.push([position, n, resolveSustain(sections[i], l, n, crochet), "roll"]);
                        case 'M':// Mine
                            sectionsVector[i].notes.push([position, n, 0.0, "mine"]);
                        default:
                    }
                }
                
                // Move conductor
                position += crochet;
                measurePosition += 1 / sections[i].length;
            }
        }

        return sectionsVector;
    }

    function resolveSustain(measure:Array<String>, line:Int, index:Int, crochet:Float):Float {
        var length:Int = 1;
        for (i in line...measure.length) {
            if (measure[i].split("")[index] == "3") return length * crochet;
            length++;
        }
        return 0.0;
    }
}