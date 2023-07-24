package funkin.util.song;

/*
    Setup mod folders
    For weeks and song loading shit
*/
class WeekSetup {
    public static var modWeekMap:Map<String,String>;
    public static var weekList:Array<WeekJson> = [];
    public static var weekNameList:Array<String> = [];
    public static var weekDataMap:Map<String,WeekJson>;
    public static var curWeekDiffs:Array<String> = ['easy','normal','hard'];

    inline public static function getWeekList():Array<WeekJson> {
        //Load week Jsons
        var weeks:Array<String> = JsonUtil.getJsonList('weeks',true,false,false);
        var global:Array<String> = JsonUtil.getJsonList('weeks',false,true,false);
        var mod:Array<String> = JsonUtil.getJsonList('weeks',false,false,false,true,true);

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
			var parsedJson:WeekJson = Json.parse(getJson);
            if (parsedJson.weekDiffs == null || parsedJson.weekDiffs.length == 0) {
                parsedJson.weekDiffs = CoolUtil.defaultDiffArray;
            }
            weekList.push(parsedJson);
            weekDataMap.set(week, parsedJson);
		}
        return weekList;
    }

    public static function setupSong(weekName:String, songName:String, songDiff:String):Void {
        var modFolder:Null<String> = modWeekMap.get(weekName);
        if (ModdingUtil.modFolders.contains(modFolder) && modFolder != null) {
            trace('SELECTED MOD FOLDER $modFolder');
			ModdingUtil.curModFolder = modFolder;
        }

        PlayState.storyWeek = weekName;
        PlayState.curDifficulty = songDiff;
        PlayState.SONG = Song.loadFromFile(songDiff, songName);
		PlayState.inChartEditor = false;
        curWeekDiffs = weekDataMap.get(weekName).weekDiffs;
	}
}