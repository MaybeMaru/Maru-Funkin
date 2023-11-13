package funkin.util.song;

import haxe.Json;
import flixel.util.FlxSort;

import funkin.util.song.formats.OsuFormat;
import funkin.util.song.formats.SmFormat;
import funkin.util.song.formats.QuaFormat;
import funkin.util.song.formats.GhFormat;
import funkin.util.song.formats.FunkinFormat;

typedef SwagSection = {
	var ?sectionNotes:Array<Array<Dynamic>>;
	var ?sectionEvents:Array<Array<Dynamic>>;
	var ?mustHitSection:Bool;
	var ?bpm:Float;
	var ?changeBPM:Bool;
}

typedef SwagSong = {
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var speed:Float;
	var offsets:Array<Int>;
	var stage:String;
	var players:Array<String>;
}

typedef SongMeta = {
	var events:Array<SwagSection>;
	var offsets:Array<Int>;
	var diffs:Array<String>;
	//var bpm:Float;
}

class Song {
	public static var DEFAULT_SONG:SwagSong = {
		song: 'Test',
		notes: [],
		bpm: 150,
		stage: 'stage',
		players: ['bf','dad','gf'],
		offsets: [0,0],
		speed: 1,
	}

	public static var DEFAULT_SECTION:SwagSection = {
		sectionNotes: [],
		sectionEvents: [],
		mustHitSection: true,
		bpm: 0,
		changeBPM: false
	}

	private static var CHART_FORMATS = [
		'json', 					// Vanilla FNF
		'osu', 						// Osu! Mania
		'sm', 'ssc', 				// Stepmania
		'qua', 						// Quaver
		'chart'						// Guitar Hero
	];

	public static function loadFromFile(diff:String, ?folder:String):SwagSong {
		folder = formatSongFolder(folder);
		for (format in CHART_FORMATS) {
			final chartPath:String = Paths.chart(folder, diff, format);
			var meta = getSongMeta(folder);
			if (meta != null) meta = meta.diffs.contains(diff) ? meta : null; // Only use if diff is included

			if (Paths.exists(chartPath, TEXT)) {
				switch (format) {
					case 'json':		return checkSong(parseJson(chartPath), meta);				// Funkin chart
					case 'osu':			return checkSong(OsuFormat.convertSong(chartPath), meta);	// Osu chart
					case 'sm' | 'ssc': 	return checkSong(SmFormat.convertSong(chartPath, diff), meta);	// Stepmania chart
					case 'qua': 		return checkSong(QuaFormat.convertSong(chartPath), meta);	// Quaver chart
					case 'chart':		return checkSong(GhFormat.convertSong(chartPath), meta);	// Guitar hero chart
				}
			}
		}
		trace('$folder-$diff CHART NOT FOUND');
		return loadFromFile('hard','tutorial');
	}

	inline public static function getSongMeta(song:String):Null<SongMeta> {
		var meta = CoolUtil.getFileContent(Paths.songMeta(song));
		return meta.length > 0 ? cast Json.parse(meta) : null;
	}

	//Check null values and remove unused format variables
	public static function checkSong(?song:SwagSong, ?meta:SongMeta):SwagSong {
		song = JsonUtil.checkJsonDefaults(getDefaultSong(), FunkinFormat.engineCheck(song));
		if (song.notes.length <= 0) song.notes.push(getDefaultSection());
		for (i in song.notes) {
			i = checkSection(i);
			if (i.sectionNotes.length > 100 && !CoolUtil.debugMode) return getDefaultSong(); // Fuck off
		}
		if (meta != null) { // Apply song metaData
			song.offsets = meta.offsets.copy();
			for (s in 0...meta.events.length) {
				if (!Reflect.hasField(meta.events[s], "sectionEvents")) continue;
				for (i in meta.events[s].sectionEvents.copy())
					song.notes[s].sectionEvents.push(i);
			}
		}
		return song;
	}

	public static function checkSection(?section:SwagSection):SwagSection {
		section = JsonUtil.checkJsonDefaults(getDefaultSection(), section);
		var foundNotes:Map<String, Bool> = [];
		var uniqueNotes:Array<Array<Dynamic>> = []; // Skip duplicate notes
		for (i in section.sectionNotes) {
			var key = '${Math.floor(i[0])}-${i[1]}-${i[3]}';
			if (!foundNotes.exists(key)) {
				foundNotes.set(key, true);
				uniqueNotes.push(i);
			}
		}
		section.sectionNotes = uniqueNotes;
		for (n in section.sectionNotes) {
			if (n[1] < 0) {
				section.sectionEvents.push([n[0], n[2], [n[3], n[4]]]);
				section.sectionNotes.remove(n);
			} else {
				if (n[1] > Conductor.STRUMS_LENGTH - 1) { // Convert extra key charts to 4 key
					if (n[3] == null) n.push("default-extra");
					else if (n[3] == 0) n[3] = "default-extra";
				}
				n[1] %= Conductor.STRUMS_LENGTH;
			}
		}
		foundNotes.clear();
		return section;
	}

	public static function getSectionTime(song:SwagSong, section:Int = 0):Float {
		var BPM:Float = song.bpm;
        var time:Float = 0;
        for (i in 0...section) {
			checkAddSections(song, i);
			if (song.notes[i].changeBPM) BPM = song.notes[i].bpm;
			time += Conductor.BEATS_PER_MEASURE * (60000 / BPM);
        }
        return time;
	}

	inline public static function checkAddSections(song:SwagSong, index:Int) {
		while(song.notes[index] == null) song.notes.push(getDefaultSection());
	}

	public static function getTimeSection(song:SwagSong, time:Float):Int {
		var section:Int = 0;
		var startTime:Float = 0;
		var endTime:Float = getSectionTime(song, 1);
		while (!(time >= startTime && time < endTime)) {
			section++;
			startTime = Reflect.copy(endTime);
			endTime = getSectionTime(song, section+1);
		}
		return section;
	}

	//Removes unused variables for smaller size
	public static function optimizeJson(input:SwagSong, metaClear:Bool = false):SwagSong {
		var song:SwagSong = JsonUtil.copyJson(input);
		for (sec in song.notes) {
			if (!sec.changeBPM) {
				Reflect.deleteField(sec, 'changeBPM');
				Reflect.deleteField(sec, 'bpm');
			}
			if (sec.sectionNotes.length <= 0) {
				Reflect.deleteField(sec, 'sectionNotes');
			} else {
				for (note in sec.sectionNotes) {
					if (note[3] == null) continue;
					if (note[3] == "default") note = note.pop(); 
				}
				sec.sectionNotes.sort(sortNotes);
			}
			if (sec.sectionEvents.length <= 0 || metaClear) {
				Reflect.deleteField(sec, 'sectionEvents');
			}
			if (sec.mustHitSection) {
				Reflect.deleteField(sec, 'mustHitSection');
			}
		}
		if (song.notes.length > 1) {
			while (true) {
				var lastSec = song.notes[song.notes.length-1];
				if (lastSec == null) break;
				if (Reflect.fields(lastSec).length <= 0) 	song.notes.pop();
				else 										break;
			}
		}
		if (metaClear) {
			Reflect.deleteField(song, 'offsets');
			//Reflect.deleteField(song, 'bpm');
		}
		
		return song;
	}

	inline public static function parseJson(chartPath:String, ?rawJson:String):SwagSong {
		if (rawJson == null) {
			rawJson = CoolUtil.getFileContent(chartPath).trim();
			while (!rawJson.endsWith("}"))	rawJson = rawJson.substr(0, rawJson.length - 1);
		}
		final swagShit:SwagSong = Json.parse(rawJson).song;
		return swagShit;
	}

	/*
		Use this function to get the sorted notes from a song as an array
		Used for pico in Stress, but you can use it on other cool stuff
	*/
	inline public static function getSongNotes(diff:String, song:String):Array<Dynamic> {
		var sections:Array<SwagSection> = loadFromFile(diff, song).notes;
		return sortSections(sections);
	}

	public static function sortSections(sections:Array<SwagSection>):Array<Array<Dynamic>> {
		var returnNotes:Array<Array<Dynamic>> = [];
		for (s in 0...sections.length) {
			if (sections[s].sectionNotes != null) {
				for (n in 0...sections[s].sectionNotes.length) {
					returnNotes.push(sections[s].sectionNotes[n]);
				}
			}
		}
		returnNotes.sort(sortNotes);
		return returnNotes;
	}

	private static function sortNotes(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int {
		return FlxSort.byValues(FlxSort.ASCENDING,  Obj1[0], Obj2[0]);
	}

	public static function formatSongFolder(songName:String):String {
		var returnSong:String = "";
		var songParts:Array<String> = songName.split("");
		for (letter in songParts) {
			var formatLetter:String = letter.toLowerCase();
			switch (formatLetter) {
				case "." | "?": formatLetter = '';
				case " " | ":":	formatLetter = '-';
			}
			returnSong += formatLetter;
		}
		return returnSong;
	}

	//Returns a copied default variable, so you dont accidentally change the defaults in runtime while using them
	inline public static function getDefaultSong():SwagSong {
		return JsonUtil.copyJson(DEFAULT_SONG);
	}

	inline public static function getDefaultSection():SwagSection {
		return JsonUtil.copyJson(DEFAULT_SECTION);
	}
}