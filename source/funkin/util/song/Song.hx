package funkin.util.song;

import moonchart.backend.Optimizer;
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
	public static function existsChart(diff:String, title:String):Bool
	{
		title = FNFMaru.formatTitle(title);

		try
		{
			FormatDetector.findInFolder(Paths.chartFolder(title), title, diff);
			return true;
		}
		catch (e)
		{
			return false;
		}

		return false;
	}

	public static function loadFromFile(diff:String, title:String):SongJson
	{
		title = FNFMaru.formatTitle(title);
		
		var folder:String = "";
		var foundFormat:DetectedFormatFiles = null;

		try // Try finding in the current mod folder
		{
			folder = Paths.chartFolder(title, true);
			foundFormat = FormatDetector.findInFolder(folder, title, diff);
		}
		catch (e)
		{
			try // If that failed then force it to be on assets
			{
				folder = Paths.chartFolder(title, false);
				foundFormat = FormatDetector.findInFolder(folder, title, diff);
			}
			catch (e)
			{
				if (title == "tutorial" && diff == "hard") // Couldnt even find tutorial
				{
					throw 'Failed loading chart: ' + Std.string(e);
					return null;
				}
				else // Fail safe to tutorial
				{
					trace('$folder/$title-$diff CHART NOT FOUND');
					return loadFromFile('hard', 'tutorial');
				}
			}
		}

		var format = foundFormat.format;
		var files = foundFormat.files;
		var maru:FNFMaru = new FNFMaru();

		// Lets double check that (for backwards compat)
		if (format == FNF_MARU)
		{
			var jsonFormats = FormatDetector.getList().filter((f) -> return FormatDetector.getFormatData(f).extension == "json");
			format = FormatDetector.findFromContents(CoolUtil.getFileContent(files[0]), {possibleFormats: jsonFormats});
		}

		switch (format)
		{
			case FNF_MARU:
				maru.fromFile(files[0], files[1]);
			case _:
				var chart = FormatDetector.createFormatInstance(format);
				chart.fromFile(files[0], files[1]);
				maru.fromFormat(chart);
		}

		trace('\nLOADED CHART SUCCESSFULLY.\nFROM FORMAT: $format\nFROM FILES: $files');
		return maru.data.song;
	}

	//public static function getSongMeta(song:String):Null<SongMeta> {
		//var meta = CoolUtil.getFileContent(Paths.songMeta(song));
		//return meta.length > 0 ? cast Json.parse(meta) : null;
	//	return null;
	//}

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
			if (s.sectionNotes != null) if (s.sectionNotes.length > 0) {
				s.sectionNotes.fastForEach((n, i) -> {
					notes.push(n);
				});
			}
		});

		notes.sort(sortNotes);
		return notes;
	}

	private static inline function sortNotes(note1:NoteJson, note2:NoteJson):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, note1.time, note2.time);
	}

	public static inline function formatSongFolder(title:String):String
	{
		return FNFMaru.formatTitle(title);
	}

	inline public static function getDefaultSong():SongJson
	{
		return
		{
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