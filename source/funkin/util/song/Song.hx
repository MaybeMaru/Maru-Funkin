package funkin.util.song;

import moonchart.backend.Optimizer;
import haxe.Json;
import flixel.util.FlxSort;

import moonchart.backend.FormatDetector;
import moonchart.formats.fnf.FNFMaru;
import moonchart.formats.fnf.legacy.FNFLegacy;

typedef SongJson = FNFMaruJsonFormat;
typedef SongMeta = FNFMaruMetaFormat;
typedef SectionJson = FNFMaruSection;
typedef NoteJson = FNFLegacyNote;
typedef EventJson = FNFMaruEvent;

class Song
{
	public static function loadFromFile(diff:String, folder:String):SongJson
	{
		folder = formatSongFolder(folder);

		var formats:Array<String> = [];

		@:privateAccess
		for (format => data in FormatDetector.formatMap)
		{
			if (formats.indexOf(data.extension) == -1)
				formats.push(data.extension);
		}

		formats.fastForEach((format, i) ->
		{
			var chartPath:String = Paths.chart(folder, diff, format);

			if (Paths.exists(chartPath, TEXT)) {

				var format = FormatDetector.findFormat([chartPath]);
				var maru:FNFMaru = new FNFMaru();

				switch (format)
				{
					case FNF_MARU:
						maru.fromFile(chartPath);
					case _:
						var chart = FormatDetector.createFormatInstance(format);
						chart.fromFile(chartPath);
						maru.fromFormat(chart);
				}

				trace("LOADED CHART FROM FORMAT: " + format);
				return maru.data.song;
			}
		});		
		
		// Couldnt even find tutorial safe fail
		if (folder == "tutorial") if (diff == "hard")
		{
			throw 'Failed loading chart.';
			return null;
		}
		
		trace('$folder-$diff CHART NOT FOUND');
		return loadFromFile('hard', 'tutorial');
	}

	public static function getSongMeta(song:String):Null<SongMeta> {
		var meta = CoolUtil.getFileContent(Paths.songMeta(song));
		return meta.length > 0 ? cast Json.parse(meta) : null;
	}

	public static function getSectionTime(song:SongJson, section:Int = 0):Float {
		var crochet:Float = (60000 / song.bpm);
        var time:Float = 0;

		checkAddSections(song, section);

		var i:Int = 0;
		while (i < section) {
			if (song.notes[i].changeBPM) {
				crochet = (60000 / song.notes[i].bpm);
			}

			time += Conductor.BEATS_PER_MEASURE * crochet;
			i++;
		}
        
		return time;
	}

	public static function checkAddSections(song:SongJson, index:Int, i:Int = 0):Void
	{
		final notes:Array<SectionJson> = song.notes;
		
		while (notes.length < index + 1)
			notes.push(getDefaultSection());

		while (i < index) {
			if (notes[i] == null)  notes.unsafeSet(i, getDefaultSection());
			i++;
		}
	}

	public static function getTimeSection(song:SongJson, time:Float):Int
	{
		var section:Int = 0;
		var startTime:Float = 0;
		var endTime:Float = getSectionTime(song, 1);

		while (!(time >= startTime && time < endTime))
		{
			section++;
			startTime = endTime;
			endTime = getSectionTime(song, section+1);
		}

		return section;
	}

	//Removes unused variables for smaller size
	public static function optimizeJson(input:SongJson):SongJson
	{
		var song:SongJson = JsonUtil.copyJson(input);

		song.notes.fastForEach((section, i) ->
		{
			Optimizer.removeDefaultValues(section,
			{
				bpm: 0,
                changeBPM: false,
                mustHitSection: true,
                sectionNotes: [],
                sectionEvents: []
			});

			if (section.sectionNotes != null)
			{
				section.sectionNotes.fastForEach((note, i) ->
				{
					Optimizer.removeDefaultValues(note, {type: "default"});
				});

				section.sectionNotes.sort(sortNotes);
			}
		});

		while (true)
		{
			var lastSection = song.notes[song.notes.length - 1];
			
			if (lastSection == null || Reflect.fields(lastSection).length > 0)
				break;

			song.notes.pop();
		}

		return song;
	}

	/*
		Use this function to get the sorted notes from a song as an array
		Used for pico in Stress, but you can use it on other cool stuff
	*/
	public static function getSongNotes(diff:String, song:String):Array<NoteJson>
	{
		final notes:Array<NoteJson> = [];
		
		loadFromFile(diff, song).notes.fastForEach((s, i) -> {
			if (s.sectionNotes != null) {
				s.sectionNotes.fastForEach((n, i) -> {
					notes.push(n);
				});
			}
		});

		notes.sort(sortNotes);
		return notes;
	}

	private static inline function sortNotes(note1:NoteJson, note2:NoteJson):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, note1.time, note2.time);
	}

	public static function formatSongFolder(songName:String):String {
		var folder:String = "";
		songName.split("").fastForEach((char, i) -> {
			switch (char) {
				case "." | "?" | "*" | '"' | "'":
				case " " | ":":				folder = (folder + "-");
				default:					folder = (folder + char.toLowerCase());
			}
		});
		return folder;
	}

	inline public static function getDefaultSong():SongJson {
		return {
			song: 'Test',
			notes: [],
			bpm: 150,
			stage: 'stage',
			players: ['bf','dad','gf'],
			offsets: [0,0],
			speed: 1,
		};
	}

	inline public static function getDefaultSection():SectionJson {
		return {
			sectionNotes: [],
			sectionEvents: [],
			mustHitSection: true,
			bpm: 0,
			changeBPM: false
		};
	}
}