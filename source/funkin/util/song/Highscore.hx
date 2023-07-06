package funkin.util.song;
import flixel.util.FlxSave;

class Highscore {
	private static var scoreSaveFile:FlxSave;
	public static var songScores:Map<String, Int>;
	public static var weekUnlocks:Map<String, Bool>;

	public static function saveSongScore(song:String, diff:String, score:Int = 0):Void {
		var daSong:String = formatSave(song,diff);
		if (songScores.exists(daSong)) {
			if (songScores.get(daSong) < score) {
				setScore(daSong, score);
				return;
			}
		}
		setScore(daSong, score);
	}

	public static function saveWeekScore(week:String, diff:String, score:Int = 0):Void {
		var daWeek:String = formatSave('week-$week',diff);
		if (songScores.exists(daWeek)) {
			if (songScores.get(daWeek) < score) {
				setScore(daWeek, score);
				return;
			}
		}
		setScore(daWeek, score);
	}

	inline public static function getSongScore(song:String, diff:String):Int {
		var daSong:String = formatSave(song,diff);
		if (!songScores.exists(daSong)) {
			setScore(daSong, 0);
		}
		return songScores.get(daSong);
	}

	inline public static function getWeekScore(week:String, diff:String):Int {
		var daWeek:String = formatSave('week-$week',diff);
		if (!songScores.exists(daWeek)) {
			setScore(daWeek, 0);
		}
		return songScores.get(daWeek);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSave() BEFORE TOSSING IN SONG VARIABLE
	 */
	inline public static function setScore(song:String, score:Int):Void {
		songScores.set(song,score);
		save();
	}

	inline public static function load():Void {
		scoreSaveFile = new FlxSave();
        scoreSaveFile.bind('funkinScore');
		songScores = new Map<String, Int>();
		weekUnlocks = new Map<String, Bool>();

        if (scoreSaveFile.data.songScores != null) {
			songScores = scoreSaveFile.data.songScores;
		}
        if (scoreSaveFile.data.weekUnlocks != null) {
			weekUnlocks = scoreSaveFile.data.weekUnlocks;
		}
	}

	public static function save():Void {
        scoreSaveFile.data.songScores = new Map<String, Int>();
        scoreSaveFile.data.songScores = songScores;
		scoreSaveFile.data.weekUnlocks = new Map<String, Bool>();
        scoreSaveFile.data.weekUnlocks = weekUnlocks;
        scoreSaveFile.flush();
    }

	inline public static function formatSave(input:String, diff:String) {
		return '${Song.formatSongFolder(input)}-$diff';
	}

	/**
	 *	STORY MODE WEEK PROGRESSION
	 */
	inline public static function getWeekUnlock(week:String):Bool {
		if (!weekUnlocks.exists(week)) {
			setWeekUnlock(week, true);
		}
		return weekUnlocks.get(week);
	}
	
	inline public static function setWeekUnlock(week:String, unlocked:Bool = true):Void {
		weekUnlocks.set(week, unlocked);
		save();
	}

	inline public static function getAccuracyRating(acc:Float):String {
		return acc == 100 ? 'swag' :
			   acc >= 90 ? 	'sick' :
			   acc >= 70 ? 	'good' :
			   acc >= 40 ? 	'bad' :
			   acc >= 25 ? 	'shit' :
			   acc >= 0 ? 	'miss' :
			   '?';
	}
}