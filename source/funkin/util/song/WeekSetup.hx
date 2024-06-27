package funkin.util.song;

import funkin.states.LoadingState;

/*
    Setup mod folders
    For weeks and song loading shit
*/

typedef SongList = {
	var songs:Array<String>;
	var songIcons:Array<String>;
    var songColors:Array<String>;
    var songDiffs:Array<Array<String>>;
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

class WeekSetup
{
    public static var weekList:Array<WeekData> = [];
    public static var vanillaWeekList:Array<WeekData> = [];
    public static var weekMap:Map<String, WeekData> = [];

    public static var curWeekDiffs:Array<String> = ['easy','normal','hard'];

    public static final DEFAULT_WEEK:WeekJson = {
        songList: {
            songs:["Tutorial"],
            songIcons: ["gf"],
            songColors: null,
            songDiffs: null
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

    public static function getWeekList():Array<WeekData>
    {
        var weeks:Array<String> = [];

        // Get week json lists
        final vanillaWeeks:Array<String> = JsonUtil.getJsonList('weeks',true,false,false);
        final globalWeeks:Array<String> = JsonUtil.getJsonList('weeks',false,true,false);
        final modWeeks:Array<String> = JsonUtil.getJsonList('weeks',false,false,false,true,true);

        var hideVanilla:Bool = false;
        for (mod in ModdingUtil.modsList) {
            if (mod.hideBaseGame && ModdingUtil.getModActive(mod.folder)) {
                hideVanilla = true;
                break;
            }
        }

        // Make sure theres no mods from innactive weeks
        for (week in modWeeks) {
            final mod = Paths.getFileMod(week)[0];
            if (!ModdingUtil.existsModFolder(mod) || !ModdingUtil.getModActive(mod))
                modWeeks.remove(week);
        }
        
        //Vanilla weeks go first >:)
        if (!hideVanilla) weeks = weeks.concat(vanillaWeeks);
        weeks = weeks.concat(globalWeeks);
        weeks = weeks.concat(modWeeks.map(week -> Paths.getFileMod(week)[1]));
        weeks = CoolUtil.removeDuplicates(weeks);

        weekList.clear();
        vanillaWeekList.clear();
        weekMap.clear();

        final modMap:Map<String, String> = [];
        for (i in modWeeks) {
			final pathParts = Paths.getFileMod(i);
			modMap.set(pathParts[1], pathParts[0]);
		}

        for (i in weeks) {
            final getJson = CoolUtil.getFileContent(Paths.getPath('data/weeks/$i.json', TEXT, null, true));
            if (getJson.length <= 0) continue; // dont add empty weeks
            
            final weekJson:WeekJson = checkWeek(Json.parse(getJson));
            
            if (weekJson.songList.songColors == null || weekJson.songList.songColors.length <= 0)
                weekJson.songList.songColors = [weekJson.weekColor];
    
            if (weekJson.songList.songDiffs == null || weekJson.songList.songDiffs.length <= 0)
                weekJson.songList.songDiffs = [weekJson.weekDiffs];

            final _data:WeekData = {
                data: weekJson,
                modFolder: modMap.get(i),
                name: i
            }

            weekList.push(_data);
            if (vanillaWeeks.contains(i)) {
                vanillaWeekList.push(_data);
            }
            weekMap.set(i, _data);

            // Unlock the week
            if (!Highscore.getWeekUnlock(i) && weekJson.startUnlocked) {
                Highscore.setWeekUnlock(i, true);
            }
        }

        return weekList;
    }

    // Check for deprecated week values (pain)
    static function checkWeek(week:WeekJson) {
        if (week == null)
            return JsonUtil.copyJson(DEFAULT_WEEK);

        if (!Reflect.hasField(week, "storyCharacters"))
            week.storyCharacters = ["dad","bf","gf"];
        
        final fields = Reflect.fields(week);
        for (i in 0...fields.length) {
            final field:String = fields[i];
            final fieldValue:Dynamic = Reflect.getProperty(week, field);
            if (fieldValue == null)
                continue;
            
            switch (field) {
                case "storyDad":   week.storyCharacters[0] = fieldValue;
                case "storyBf":    week.storyCharacters[1] = fieldValue;
                case "storyGf":    week.storyCharacters[2] = fieldValue;
            }
        }

        if (Reflect.hasField(week.songList, "songIcon"))
            week.songList.songIcons = Reflect.field(week.songList, "songIcon");

        return JsonUtil.checkJson(DEFAULT_WEEK, week);
    }

    public static inline function getWeekDiffs(week:String) {
		return getData(week)?.data?.weekDiffs ?? CoolUtil.defaultDiffArray.copy();
	}

    public static inline function getData(week:String):WeekData {
        return weekMap.get(week);
    }

    public static function setupSong(weekName:String, songName:String, songDiff:String, storyMode:Bool):Void {
        final _modFolder = weekMap.get(weekName)?.modFolder;
        if (_modFolder == null) { // Base game
            ModdingUtil.curModFolder = "";
        }
        else if (ModdingUtil.modsMap.exists(_modFolder)) { // Mods
            trace("Selected Mod folder " + _modFolder);
            ModdingUtil.curModFolder = _modFolder;
        }

        PlayState.storyWeek = weekName;
        PlayState.isStoryMode = storyMode;
        PlayState.curDifficulty = songDiff;
        PlayState.SONG = Song.loadFromFile(songDiff, songName);
		PlayState.inChartEditor = PlayState.seenCutscene = false;
        PlayState.clearCache = true;
        curWeekDiffs = getWeekDiffs(weekName);
	}

    public static function loadSong(weekName:String, songName:String, songDiff:String, storyMode:Bool = false, skipTrans:Bool = false, ?target:Class<MusicBeatState>):Void
    {
        setupSong(weekName, songName, songDiff, storyMode);
        loadTarget(target, skipTrans);
    }

    public static function loadTarget(?target:Class<MusicBeatState>, skipTrans:Bool = false)
    {
        target ??= PlayState;
        
        var instance:MusicBeatState = Type.createInstance(target, []);
        if (target == PlayState)    loadPlayState(cast(instance, PlayState), skipTrans);
        else                        CoolUtil.switchState(instance, skipTrans);
    }

    public static function loadPlayState(instance:PlayState, skipTrans:Bool = false, clearCache:Bool = true):Void
    {
        var loadScreen:LoadingState = new LoadingState();

        loadScreen.onStart = () -> {
            if (clearCache) {
                PlayState.clearCache = false;
                CoolUtil.clearCache();
            }
        }

        loadScreen.onComplete = () -> {
            Paths.currentLevel = PlayState.storyWeek;
            CoolUtil.switchState(instance, true, skipTrans);
        }

        final song = PlayState.SONG;
        loadScreen.setupPlay(Stage.getJson(song.stage), song.players.copy(), song.song);

        Conductor.stop();

        if (FlxG.sound.music != null) {
            FlxG.sound.music.fadeOut(0.333);
        }

        CoolUtil.switchState(loadScreen, skipTrans, true);
    }
}