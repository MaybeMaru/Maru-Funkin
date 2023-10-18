package funkin.util.song;

import flixel.util.FlxArrayUtil;

/*
    Setup mod folders
    For weeks and song loading shit
*/

typedef SongList = {
	var songs:Array<String>;
	var songIcons:Array<String>;
    var songColors:Array<String>;
}

typedef WeekJson = {
	var songList:SongList;
	var weekDiffs:Array<String>;
	
    var weekImage:String;
	var weekName:String;
	var weekColor:String;
    var storyCharacters:Array<String>;

	var startUnlocked:Bool;
	var unlockWeek:String;
	var hideStory:Bool;
	var hideFreeplay:Bool;
}

typedef WeekData = {
    var data:WeekJson;
    var modFolder:String;
    var name:String;
}

class WeekSetup {
    public static var weekList:Array<WeekData> = [];
    public static var vanillaWeekList:Array<WeekData> = [];
    public static var weekMap:Map<String, WeekData> = [];

    public static var curWeekDiffs:Array<String> = ['easy','normal','hard'];

    public static var DEFAULT_WEEK(default, never):WeekJson = {
        songList: {
            songs:["Tutorial"],
            songIcons: ["gf"],
            songColors: null,
        },
        weekDiffs: CoolUtil.defaultDiffArray,

        weekImage: "tutorial",
        weekName: "Tutorial",
        weekColor: "0xffffffff",
        storyCharacters: ["dad", "bf", "gf"],

        startUnlocked: true,
        unlockWeek: "",
        hideStory: false,
        hideFreeplay: false,
	}

    public static function getWeekList() {//:Array<WeekJson> {
        var weeks:Array<String> = [];

        // Get week json lists
        var vanillaWeeks:Array<String> = JsonUtil.getJsonList('weeks',true,false,false);
        var global:Array<String> = JsonUtil.getJsonList('weeks',false,true,false);
        var mod:Array<String> = JsonUtil.getJsonList('weeks',false,false,false,true,true);
        
        //Vanilla weeks go first >:)
        weeks = weeks.concat(vanillaWeeks).concat(global);
        weeks = weeks.concat(mod.map(week -> Paths.getFileMod(week)[1]));
        weeks = CoolUtil.removeDuplicates(weeks);

        FlxArrayUtil.clearArray(weekList);
        FlxArrayUtil.clearArray(vanillaWeekList);
        weekMap.clear();

        var modMap:Map<String, String> = [];
        for (i in mod) {
			final pathParts = Paths.getFileMod(i);
			modMap.set(pathParts[1], pathParts[0]);
		}

        for (i in weeks) {
            var getJson = CoolUtil.getFileContent(Paths.getPath('data/weeks/$i.json', TEXT, null, true));
            var parsedJson:WeekJson = checkWeek(Json.parse(getJson));

            var _data:WeekData = {
                data: parsedJson,
                modFolder: modMap.get(i),
                name: i
            }

            weekList.push(_data);
            if (vanillaWeeks.contains(i)) {
                vanillaWeekList.push(_data);
            }
            weekMap.set(i, _data);

            // Unlock the week
            if (!Highscore.getWeekUnlock(i) && parsedJson.startUnlocked) {
                Highscore.setWeekUnlock(i, true);
            }
        }

        return weekList;
    }

    // Check for deprecated week values (pain)
    static function checkWeek(week:WeekJson) {
        if (week == null) return JsonUtil.copyJson(DEFAULT_WEEK);

        if (!Reflect.hasField(week, "storyCharacters"))
            week.storyCharacters = ["dad","bf","gf"];
        
        for (field in Reflect.fields(cast week)) {
            var fieldValue = Reflect.getProperty(week, field);
            if (fieldValue == null) continue;
            switch (field) {
                case "storyDad":   week.storyCharacters[0] = fieldValue;
                case "storyBf":    week.storyCharacters[1] = fieldValue;
                case "storyGf":    week.storyCharacters[2] = fieldValue;
            }
        }

        if (week.songList.songColors == null)
            week.songList.songColors = [week.weekColor];

        if (Reflect.hasField(week.songList, "songIcon"))
            week.songList.songIcons = Reflect.field(week.songList, "songIcon");

        return JsonUtil.checkJsonDefaults(DEFAULT_WEEK, week);
    }

    public static inline function getWeekDiffs(week:String) {
		return getData(week)?.data?.weekDiffs ?? CoolUtil.defaultDiffArray.copy();
	}

    public static inline function getData(week:String):WeekData {
        return weekMap.get(week);
    }

    public static function setupSong(weekName:String, songName:String, songDiff:String):Void {
        final _modFolder = weekMap.get(weekName)?.modFolder ?? null;
        if (_modFolder == null) { // Base game
            ModdingUtil.curModFolder = "";
        }
        else if (ModdingUtil.modsMap.exists(_modFolder)) { // Mods
            trace("Selected Mod folder " + _modFolder);
            ModdingUtil.curModFolder = _modFolder;
        }

        PlayState.storyWeek = weekName;
        PlayState.curDifficulty = songDiff;
        PlayState.SONG = Song.loadFromFile(songDiff, songName);
		PlayState.inChartEditor = PlayState.seenCutscene = false;
        PlayState.clearCache = true;
        curWeekDiffs = getWeekDiffs(weekName);
	}
}