package funkin.util.song.formats;

import funkin.util.song.formats.BasicParser.ChartVar;
import funkin.util.song.formats.BasicParser.BasicSection;
import funkin.util.song.formats.BasicParser.BasicBpmChange;
import haxe.ds.Vector;

/*
    Custom made sm (stepmania) to fnf json format for mau engin
    TODO: Rewrite this bitch!!! (and make a general format for other converters)
*/

class SmFormat extends BasicParser {
    public static function convert(path:String, diff:String):SwagSong {
        return new SmFormat().convertSong(path, diff);
    }

    override function applyVars(variables:Map<String, String>, fnfMap:SwagSong) {
        fnfMap.song = variables.get("TITLE");
        fnfMap.offsets = [Std.int(Std.parseFloat(variables.get('OFFSET')) * -1000), 0];
    }

    override function parseBpmChanges(map:Array<String>, bpmChanges:Array<BasicBpmChange>) {
        for (i in variables.get("BPMS").split(",")) {
            final data = i.split("=");
            bpmChanges.push({
                time: Std.parseFloat(data[0]), // Calculated in beats
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

    var diffNotes:Map<String, Vector<BasicSection>> = [];

    override function parseNotes():Vector<BasicSection> {
        var baseNotes:Array<String> = [];
        for (name => variable in variables) {
            if (name.startsWith("NOTES")) {
                baseNotes.push(variable);
            }
        }

        for (chart in baseNotes) {
            var parts = chart.split(":");

            var diff:String = parts[2];
            var sections:Vector<BasicSection> = parseSm(parts[5].substr(1, parts[5].length));

            diffNotes.set(diff, sections);
        }
        
        return null;
    }

    function parseSm(notes:String):Vector<BasicSection> {
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
        var beatPosition:Float = 0.0;
        var crochet:Float = 0.0;

        var recalc = function (index:Int) {
            crochet = (60 / curBpm) * (1 / sections[index].length) * 1000;
        }

        for (i in 0...sections.length) {
            recalc(i);

            for (line in sections[i]) {
                var lineSplit = line.split("");
                for (n in 0...lineSplit.length) {
                    switch (lineSplit[n]) {
                        case '1':// Normal note
                            sectionsVector[i].notes.push([position, n, 0.0]);
                        case '2':// Hold head
                            //var susLengthInt = findSusLength(measureArray, [l,n]);
                            //var susLength = stepCrochet * stepsPerLine * susLengthInt;
                            //smSec.notes.push([strumTime,n,susLength]);
                        //case '4':// Roll head
                        //case '3': // Hold / Roll tail
                        //case 'M':// Mine
                        default:
                    }
                }
                
                position += crochet;
                beatPosition += 1 / sections[i].length;

                if (bpmChanges[0] != null) {
                    while (bpmChanges[0].time <= beatPosition) {
                        curBpm = bpmChanges[0].bpm;
                        bpmChanges.remove(bpmChanges[0]);
                        recalc(i);

                        sectionsVector[i].bpm = curBpm;
                    }
                }
            }
        }

        return Vector.fromArrayCopy(sectionsVector);
    }
}