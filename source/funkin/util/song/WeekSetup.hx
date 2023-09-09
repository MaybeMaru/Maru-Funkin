package funkin.util.song;

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

class WeekSetup {
    public static var modWeekMap:Map<String,String>;
    public static var weekList:Array<WeekJson> = [];
    public static var weekNameList:Array<String> = [];
    public static var vanillaWeekNameList:Array<String> = [];
    public static var weekDataMap:Map<String,WeekJson>;
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

    inline public static function getWeekList():Array<WeekJson> {
        //Load week Jsons
        var weeks:Array<String> = JsonUtil.getJsonList('weeks',true,false,false);
        var global:Array<String> = JsonUtil.getJsonList('weeks',false,true,false);
        var mod:Array<String> = JsonUtil.getJsonList('weeks',false,false,false,true,true);
        vanillaWeekNameList = weeks.copy();

        //Vanilla weeks go first >:)
        weeks = weeks.concat(global);
        weeks = weeks.concat(mod.map(week -> Paths.getFileMod(week)[1]));

		modWeekMap = new Map<String,String>();
		for (week in mod) {
			var weekParts = Paths.getFileMod(week);
			modWeekMap.set(weekParts[1], weekParts[0]);
		}

		//Parse jsons
        weekList = [];
        weekNameList = weeks;
        weekDataMap = new Map<String,WeekJson>();
		for (week in weeks) {
			var getJson = CoolUtil.getFileContent(Paths.getPath('data/weeks/$week.json', TEXT, null, true));
            var parsedJson:WeekJson = checkWeek(Json.parse(getJson));
            weekList.push(parsedJson);
            weekDataMap.set(week, parsedJson);

            // Unlock the week
            if (!Highscore.getWeekUnlock(week) && parsedJson.startUnlocked) {
                Highscore.setWeekUnlock(week, true);
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

        return  JsonUtil.checkJsonDefaults(DEFAULT_WEEK, week);
    }

    public static function setupSong(weekName:String, songName:String, songDiff:String):Void {
        var modFolder:Null<String> = modWeekMap.get(weekName);
        if (modFolder == null) ModdingUtil.curModFolder = "";   // In base game
        else if (ModdingUtil.modFolders.contains(modFolder)) {  // In a mod
            trace('SELECTED MOD FOLDER $modFolder');
			ModdingUtil.curModFolder = modFolder;
        }
        PlayState.storyWeek = weekName;
        PlayState.curDifficulty = songDiff;
        PlayState.SONG = Song.loadFromFile(songDiff, songName);
		PlayState.inChartEditor = false;
        PlayState.seenCutscene = false;
        PlayState.clearCache = true;
        curWeekDiffs = weekDataMap.get(weekName).weekDiffs;
	}
}