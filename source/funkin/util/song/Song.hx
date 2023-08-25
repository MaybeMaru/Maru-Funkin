package funkin.util.song;

import funkin.util.song.formats.QuaFormat;
import haxe.Json;
import flixel.util.FlxSort;

import funkin.util.song.formats.OsuFormat;
import funkin.util.song.formats.SmFormat;

typedef SwagSection = {
	var sectionNotes:Array<Dynamic>;
	var sectionEvents:Array<Dynamic>;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
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
		'json',
		'osu',
		'sm', 'ssc',
		'qua'
	];

	public static function loadFromFile(diff:String, ?folder:String):SwagSong {
		folder = formatSongFolder(folder);
		for (format in CHART_FORMATS) {
			var chartPath:String = Paths.chart(folder, diff, format);
			if (Paths.exists(chartPath, TEXT)) {
				switch (format) {
					case 'json':			return checkSong(parseJson(chartPath));					// Funkin chart
					case 'osu':				return checkSong(OsuFormat.convertSong(chartPath));		// Osu chart
					case 'sm' | 'ssc':		return checkSong(SmFormat.convertSong(chartPath));		// Stepmania chart
					case 'qua': 			return checkSong(QuaFormat.convertSong(chartPath));		// Quaver chart
				}
			}
		}
		trace('$folder-$diff CHART NOT FOUND');
		return loadFromFile('hard','tutorial');
	}

	//Check null values and remove unused format variables
	inline public static function checkSong(?song:SwagSong):SwagSong {
		song = JsonUtil.checkJsonDefaults(getDefaultSong(), engineCheck(song));
		for (i in 0...song.notes.length) {
			song.notes[i] = checkSection(song.notes[i]);
		}
		return song;
	}

	inline public static function checkSection(?section:SwagSection):SwagSection {
		return JsonUtil.checkJsonDefaults(getDefaultSection(), section);
	}

	//Fixes charts from other engines
	inline public static function engineCheck(?song:SwagSong):SwagSong {
		if (song == null) {
			return null;
		}

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
			}
		}
		return song;
	}

	inline public static function convertPsychChart(song:SwagSong) {
		for (s in song.notes) {
			for (n in s.sectionNotes) {
				if (n[1] < 0) s.sectionEvents.push([n[0], n[2], [n[3], n[4]]]);
			}
		}
		//if (Reflect.field(song, 'events') == null) return;
		var psychEvents:Array<Dynamic> = Reflect.field(song, 'events');
		var events:Array<Array<Dynamic>> = [];
		for (e in psychEvents) {
			var eventTime = e[0];
			var _events:Array<Array<Dynamic>> = e[1];
			for (i in _events) {
				events.push([eventTime, i[0], [i[1], i[2]]]);
			}
		}

		for (i in events) {
			var eventSec = getTimeSection(song, i[0]);
			song.notes[eventSec].sectionEvents.push(i);
		}
		return song;
	}

	inline public static function getSectionTime(song:SwagSong, section:Int = 0):Float {
		var BPM:Float = song.bpm;
        var time:Float = 0;
        for (i in 0...section) {
            if (song.notes[i].changeBPM) BPM = song.notes[i].bpm;
			time += Conductor.BEATS_LENGTH * (1000 * 60 / BPM);
        }
        return time;
	}

	inline public static function getTimeSection(song:SwagSong, time:Float):Int {
		var lastSec:Int = 0;
		var lastTime:Float = 0;
		while (lastTime < time) {
			lastTime = getSectionTime(song, lastSec);
			lastSec++;
		}
		return lastSec;
	}

	//Removes unused variables for smaller size
	inline public static function optimizeJson(input:SwagSong):SwagSong {
		var song:SwagSong = JsonUtil.copyJson(input);
		for (sec in song.notes) {
			if (!sec.changeBPM) {
				Reflect.deleteField(sec, 'changeBPM');
				Reflect.deleteField(sec, 'bpm');
			}
			if (sec.sectionNotes.length <= 0) { // THIS CAUSED SOME BIG BUGS LOL, WOULD BE NICE BUT I DONT WANNA FIX ALL THIS SHIT
				Reflect.deleteField(sec, 'sectionNotes');
			} else {
				for (n in 0...sec.sectionNotes.length) {
					var note:Array<Dynamic> = sec.sectionNotes[n];
					if (note[3] != null) {
						if (note[3] == 'default' || note[3] == 0 || note[3] == '') {
							note = [note[0],note[1],note[2]];
						}
					}
				}
			}
			if (sec.sectionEvents.length <= 0) {
				Reflect.deleteField(sec, 'sectionEvents');
			}
			if (sec.mustHitSection) {
				Reflect.deleteField(sec, 'mustHitSection');
			}
		}
		return song;
	}

	inline public static function parseJson(chartPath:String, ?rawJson:String):SwagSong {
		if (rawJson == null) {
			rawJson = CoolUtil.getFileContent(chartPath).trim();
			while (!rawJson.endsWith("}"))	rawJson = rawJson.substr(0, rawJson.length - 1);
		}
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		return swagShit;
	}

	/*
		Use this function to get the sorted notes from a song as an array
		Used for pico in Stress, but you can use it on other cool stuff
	*/
	public static function getSongNotes(diff:String, song:String):Array<Dynamic> {
		var sections:Array<SwagSection> = loadFromFile(diff, song).notes;
		return sortSections(sections);
	}

	public static function sortSections(sections:Array<SwagSection>):Array<Dynamic> {
		var returnNotes:Array<Dynamic> = [];
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

	inline public static function formatSongFolder(songName:String):String {
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