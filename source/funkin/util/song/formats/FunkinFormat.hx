package funkin.util.song.formats;

import openfl.display.BitmapData;
import flixel.util.FlxStringUtil;

/*
    Kinda made only to not have all engine converter stuff in Song.hx
*/

class FunkinFormat {
    //Fixes charts from other engines
	public static function engineCheck(?song:SwagSong):SwagSong {
		if (song == null) return null;

		//Get special engine variables ready if missing
		var specialFields:Array<Array<Dynamic>> = [
			['players', ['bf','dad','gf']]
		];
		for (field in specialFields) {
			if (!Reflect.hasField(song, field[0])) {
				Reflect.setField(song, field[0], field[1]);
			}
		}

		for (field in Reflect.fields(song)) {
			switch (field) {
				case 'gfVersion' | 'gf' | 'player3' | 'player2' | 'player1':
					var playerIndex:Int = 0;
					switch(field) {
						case 'player1': playerIndex = 0;
						case 'player2': playerIndex = 1;
						default:		playerIndex = 2;
					}
					var players:Array<String> = Reflect.field(song, 'players');
					players[playerIndex] = Reflect.field(song, field);
					Reflect.setField(song, 'players', players);
					Reflect.deleteField(song, field);
				case 'events':
					song = convertPsychChart(song);	
					Reflect.deleteField(song, field);
			}
		}
		return song;
	}
	
	public static function convertPsychChart(song:SwagSong):SwagSong {
		var psychEvents:Array<Dynamic> = Reflect.field(song, 'events');
		if (psychEvents == null || psychEvents.length <= 0) return song;

		var events:Array<Array<Dynamic>> = [];
		for (e in psychEvents) {
			var eventTime = e[0];
			var _events:Array<Array<Dynamic>> = e[1];
			for (i in _events) events.push([eventTime, i[0], [i[1], i[2]]]);
		}

		for (i in events) {
			var eventSec = Song.getTimeSection(song, i[0]);
			Song.checkAddSections(song, eventSec);
			song.notes[eventSec] = Song.checkSection(song.notes[eventSec]);
			song.notes[eventSec].sectionEvents.push(i);
		}

		return song;
	}

	/*
		Just thought it would be pretty funny lol
	*/

	/* Ill finish this shit later
	public static function convertLudumDareChart(metaFolder:String):SwagSong {
		var metaJson = cast Json.parse(CoolUtil.getFileContent(metaFolder)); // Get song meta
		var fnfMap:SwagSong = Song.getDefaultSong();
		fnfMap.bpm = metaJson.bpm;
		fnfMap.song = metaJson.song;
		
		var folder:String = metaFolder.split('/meta.json')[0];
		var stepCrochet:Float = 60 / fnfMap.bpm / 4 * 1000;
		var curSec:Int = 0;
		for (i in 1...metaJson.sections+1) {
			var secPath = '$folder/section_$i.png';
			var secNotes = convertCsvSection(cast Paths.getGraphic(secPath, false).bitmap);
			
			for (s in 0...2) {
				var secData = Song.getDefaultSection();
				secData.sectionNotes = extractCsvNotes(secNotes, stepCrochet, curSec);
				secData.mustHitSection = s == 1;
				fnfMap.notes.push(secData); // Push 2 sections
				curSec++;
			}
		}

		return fnfMap;
	}

	static function convertCsvSection(image:BitmapData):Array<Int> {
		var regex:EReg = new EReg("[ \t]*((\r\n)|\r|\n)[ \t]*", "g");
		var csvData = FlxStringUtil.bitmapToCSV(image);

		var lines:Array<String> = regex.split(csvData);
		var rows:Array<String> = lines.filter(function(line) return line != "");
		csvData.replace("\n", ',');

		var heightInTiles = rows.length;
		var widthInTiles = 0;
		var row:Int = 0;

		var dopeArray:Array<Int> = [];
		while (row < heightInTiles) {
			var rowString = rows[row];
			if (rowString.endsWith(","))
				rowString = rowString.substr(0, rowString.length - 1);
			var columns = rowString.split(",");
	
			if (columns.length == 0) {
				heightInTiles--;
				continue;
			}
			if (widthInTiles == 0)
				widthInTiles = columns.length;
	
			var column = 0;
			var pushedInColumn:Bool = false;
			while (column < widthInTiles) {
				var columnString = columns[column];
				var curTile = Std.parseInt(columnString);
	
				if (curTile == 1) {
					if (column < 4)
						dopeArray.push(column + 1);
					else {
						var tempCol = (column + 1) * -1;
						tempCol += 4;
						dopeArray.push(tempCol);
					}
	
					pushedInColumn = true;
				}
	
				column++;
			}
	
			if (!pushedInColumn)
				dopeArray.push(0);
	
			row++;
		}

		return dopeArray;
	}

	static function extractCsvNotes(data:Array<Int>, stepCrochet:Float = 0, secID:Int = 0):Array<Array<Float>> {
        var secStart:Float = stepCrochet * 16 * secID;
		var timeOffset:Float = 3;

		var notes:Array<Array<Float>> = [];
        var noteLane:Int = 0;
        var noteStep:Int = -1;
        var susLength:Int = 0;

		var noteCount:Int = 0;
		for (i in data) {
			if (i > 0) noteCount++;
		}

		trace(noteCount);

		//trace(data.length);
        
        for (step in data) {
            if (step > 0) {
                if (noteLane != 0) {
                    notes.push([noteStep * stepCrochet * timeOffset + secStart, noteLane-1, susLength * stepCrochet]);
                    susLength = 0;
                }
                noteStep++;
                noteLane = step;
            } else if (step < 0) susLength++;
        }

        if (noteLane != 0)
            notes.push([noteStep * stepCrochet * timeOffset + secStart, noteLane-1, susLength * stepCrochet]);
        
        return notes;
    }*/
}