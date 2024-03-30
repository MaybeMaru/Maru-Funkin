package funkin.util.song;

import funkin.util.song.Song.SectionJSON;
import funkin.util.song.Song.Meta;
import funkin.util.song.Song.SectionJSON;
import haxe.Json;
import flixel.util.FlxSort;

import funkin.util.song.formats.OsuFormat;
import funkin.util.song.formats.SmFormat;
import funkin.util.song.formats.QuaFormat;
import funkin.util.song.formats.GhFormat;
import funkin.util.song.formats.FunkinFormat;

class SongUtil
{
	private static final CHART_FORMATS:Array<String> = [
		'json', 					// Vanilla FNF
		'osu', 						// Osu! Mania
		'sm', 'ssc', 				// Stepmania
		'qua', 						// Quaver
		'chart'						// Guitar Hero
	];

	public static function loadFromFile(diff:String, song:String):Song
	{
		song = formatSongFolder(song);
		
		CHART_FORMATS.fastForEach((format, i) -> {
			var path:String = Paths.chart(song, diff, format);
			var meta = getSongMeta(song);
			if (meta != null) meta = meta.diffs.contains(diff) ? meta : null; // Only use if diff is included

			if (Paths.exists(path, TEXT)) {
				switch (format) {
					case 'json':		return createSong(parseJson(path), meta);				// Funkin chart
					case 'osu':			return createSong(OsuFormat.convertSong(path), meta);	// Osu chart
					case 'sm' | 'ssc': 	return createSong(SmFormat.convert(path, diff), meta);	// Stepmania chart
					case 'qua': 		return createSong(QuaFormat.convertSong(path), meta);	// Quaver chart
					case 'chart':		return createSong(GhFormat.convertSong(path), meta);	// Guitar hero chart
				}
			}
		});

		trace('$song-$diff CHART NOT FOUND');
		
		// Couldnt even find tutorial safe fail
		if (song == "tutorial") if (diff == "hard")
		{
			trace("Failed to load any chart");
			return Song.getDefaultSong();
		}
		
		return loadFromFile('hard', 'tutorial');
	}

	public static function getSongMeta(song:String):Meta
	{
		var json:String = CoolUtil.getFileContent(Paths.songMeta(song));
		if (json.length > 0)
			return new Meta().fromMetaJson(Json.parse(json));

		return null;
	}

	public static function createSong(input:SongJSON, meta:Meta):Song
	{
		// Null check the song json input
		var updateChart:Bool = ((input.version != null) ? (input.version != Song.CHART_VERSION) : true);
		input = JsonUtil.checkJson(getDefaultSong(), updateChart ? FunkinFormat.engineCheck(input) : input, false);
		
		// Null check all sections
		input.notes.fastForEach((section, i) -> {
			checkSection(section, updateChart);
			if (section.sectionNotes.length > 100) if (!CoolUtil.debugMode) // Fuck ur d&b crap
				return Song.getDefaultSong();
		});
		
		// Create the song class
		var song = new Song().fromJson(input);
		if (song.sections.length <= 0)
			song.sections.push(Section.make());

		// Embed the meta into the song
		if (meta != null)
		{
			meta.embed(song);
		}	

		// Prepare this if its gonna be used for PlayState
		song.reloadSectionTimes();

		return song;
	}

	public static function checkSection(input:SectionJSON, cleanup:Bool)
	{
		input = JsonUtil.checkJson(getDefaultSection(), input, false);

		input.sectionNotes.fastForEach((n, i) -> {
			// Convert extra key charts to 4 key
			if (n[1] > Conductor.STRUMS_LENGTH - 1)
			{
				if (n[3] == null) n.push("default-extra");
				else if (n[3] == 0) n.unsafeSet(3, "default-extra");
				n.unsafeSet(1, n[1] % Conductor.STRUMS_LENGTH);
			}
		});

		if (cleanup)
		{
			var foundNotes:Map<String, Bool> = [];
			var uniqueNotes:Array<SongNote> = [];

			input.sectionNotes.fastForEach((n, i) -> {
				var key = Math.floor(n[0]) + "-" + n[1] + "-" + n[3];
				if (!foundNotes.exists(key))
				{
					foundNotes.set(key, true);
					uniqueNotes.push(n);
				}
			});

			foundNotes.clear();
			input.sectionNotes = uniqueNotes;
		}

		return input;
	}

	//Removes unused variables for smaller size
	public static function optimizeJson(input:SongJSON, metaClear:Bool = false):SongJSON
	{
		var song:SongJSON = JsonUtil.copyJson(input);
		song.notes.fastForEach((sec, i) -> {
			if (!sec.changeBPM) {
				Reflect.deleteField(sec, 'changeBPM');
				Reflect.deleteField(sec, 'bpm');
			}

			if (sec.sectionNotes.length <= 0) {
				Reflect.deleteField(sec, 'sectionNotes');
			}
			else
			{
				sec.sectionNotes.fastForEach((note, i) -> {
					final type:String = note[3];
					if (type != null) {
						if (type == "default")
							note.pop(); 
					}
				});
				sec.sectionNotes.sort(sortNotes);
			}

			if (sec.sectionEvents.length <= 0 || metaClear)
				Reflect.deleteField(sec, 'sectionEvents');

			if (sec.mustHitSection)
				Reflect.deleteField(sec, 'mustHitSection');
		});

		if (song.notes.length > 1)
		{
			while (true) {
				final lastSec = song.notes[song.notes.length - 1];
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

	public static function sortNotes(a:SongNote, b:SongNote) {
		return FlxSort.byValues(FlxSort.ASCENDING, a[0], b[0]);
	}

	public static function parseJson(path:String = "", rawJson:String = ""):SongJSON
	{
		if (rawJson.length <= 0) {
			rawJson = CoolUtil.getFileContent(path).trim();
			while (!rawJson.endsWith("}"))
				rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return cast Json.parse(rawJson).song;
	}

	public static function formatSongFolder(songName:String):String {
		var folder:String = "";
		songName.split("").fastForEach((char, i) -> {
			switch (char) {
				case "." | "?" | "*" | '"':
				case " " | ":":				folder = (folder + "-");
				default:					folder = (folder + char.toLowerCase());
			}
		});
		return folder;
	}

	inline public static function getDefaultSong():SongJSON {
		return {
			version: Song.CHART_VERSION,

			song: 'Test',
			notes: [],
			bpm: 150,
			stage: 'stage',
			players: ['bf','dad','gf'],
			offsets: [0,0],
			speed: 1,
		};
	}

	inline public static function getDefaultSection():SectionJSON {
		return {
			sectionNotes: [],
			sectionEvents: [],
			mustHitSection: true,
			bpm: 0,
			changeBPM: false
		};
	}
}