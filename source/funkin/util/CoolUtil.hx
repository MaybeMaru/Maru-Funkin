package funkin.util;

import openfl.system.System;

typedef CacheClearing =  {
	?bitmap:Bool,
	?sustains:Bool,
	?sounds:Bool,
	?shaders:Bool
}

class CoolUtil {
	public static var defaultDiffArray:Array<String> = 	['easy', 'normal', 'hard'];
	public static var directionArray:Array<String> = 	['LEFT','DOWN','UP','RIGHT'];
	public static var colorArray:Array<String> = 		['purple','blue','green','red'];
	public static var noteColorArray:Array<Int> = 		[0xffc24b99, 0xff00ffff, 0xff12fa05, 0xfff9393f];
	public static var debugMode:Bool = false;

	inline public static function init():Void {
		SkinUtil.setCurSkin();
		NoteUtil.initTypes();
		EventUtil.initEvents();
		#if desktop
		ModdingUtil.reloadModFolders();
		#end
	}

	inline public static function coolTextFile(path:String):Array<String> {
		return [for (i in getFileContent(path).trim().split('\n')) i.trim()];
	}

	inline public static function getFileContent(path:String):String {
		#if desktop
		path = Paths.removeAssetLib(path);
		if (FileSystem.exists(path))
			return File.getContent(path);
		#end
		if (OpenFlAssets.exists(path, TEXT))
			return Assets.getText(path);
		return "";
	}

	inline public static function numberArray(max:Int, ?min:Int = 0):Array<Int> {
		return [for (i in min...max) i];
	}

	static var DEFAULT_CACHE_CLEARING:CacheClearing = {
		bitmap: true,
		sustains: true,
		sounds: true,
		shaders: true
	}

	inline public static function clearCache(?cacheClear:CacheClearing, softClear:Bool = false) {
		cacheClear = JsonUtil.checkJsonDefaults(DEFAULT_CACHE_CLEARING, cacheClear);
		if (cacheClear.bitmap) Paths.clearBitmapCache();
		if (cacheClear.sustains) NoteUtil.clearSustainCache();
		if (cacheClear.sounds) Paths.clearSoundCache(!softClear);
		if (cacheClear.shaders) Shader.clearShaders();
		System.gc();
	}

	inline public static function getSound(key:String):FlxSound {
		var newSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound(key));
		FlxG.sound.list.add(newSound);
		return newSound;
	}

	inline public static function playSound(key:String, volume:Float = 1, ?pitch:Float) {
		var sound = getSound(key);
		sound.volume = volume;
		sound.pitch = (pitch == null ? FlxG.timeScale : pitch);
		sound.play();
		return sound;
	}

	public static var resumeSoundsList:Array<FlxSound> = [];
	inline public static function pauseSounds() {
		resumeSoundsList = [];
		for (sound in FlxG.sound.list) {
			if (sound.playing) resumeSoundsList.push(sound);
			sound.pause();
		}
	}

	inline public static function resumeSounds() {
		for (sound in resumeSoundsList) sound.play();
		resumeSoundsList = [];
	}

	/*
		lil shortcut to play music
		itll also change the conductor bpm to the music's data text file thing
	*/
	inline public static function playMusic(music:String, volume:Float = 1, looped:Bool = true):Void {
		FlxG.sound.playMusic(Paths.music(music), volume, looped);

		var musicDataPath:String = Paths.getPath('music/$music-data.txt', MUSIC, null);
		if (Paths.exists(musicDataPath, TEXT)) {
			Conductor.bpm = Std.parseFloat(getFileContent(musicDataPath));
		}
	}

	inline public static function getLerp(ratio:Float):Float {
		return 	FlxG.elapsed / (1 / 60) * ratio;
	}

	inline public static function coolLerp(a:Float, b:Float, ratio:Float):Float {
		return FlxMath.lerp(a,b,getLerp(ratio));
	}

	public static function sortByStrumTime(a:Dynamic, b:Dynamic) {
		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	public static function sortAlphabetically(a:String, b:String):Int {
        a = a.toUpperCase();
        b = b.toUpperCase();
        if 		(a < b) return -1;
        else if (a > b) return 1;
        return 0;
    }

	public static function customSort(input:Array<String>, customOrder:Array<String>):Array<String> {
		var result:Array<String> = [];
		for (i in customOrder) {
			if (input.contains(i)) {
				result.push(i);
				input.remove(i);
			}
		}

		input.sort(sortAlphabetically);
		return result.concat(input);
	}

	public static function removeDuplicates(input:Array<String>):Array<String> {
        var result:Array<String> = [];
        for (i in input) {
            if (!result.contains(i)) {
                result.push(i);
            }
        }
        return result;
    }
	
	inline public static function formatClass(daClass:Dynamic, formatDir:Bool = true):String {
		var className = Type.getClassName(Type.getClass(daClass));
		var classFolders:Array<String> = className.split('.');
		return classFolders.join(formatDir ? '/' : '.');
	}

	inline public static function formatInt(text:Dynamic, zeroLength:Int = 5):String {
		var result:String = Std.string(text);
		var lengthDiff:Int = zeroLength - result.length;
		if (lengthDiff <= 0)		return result;
		for (i in 0...lengthDiff)	result = '0$result';
		return result;
	}

	inline public static function hexToColor(hex:String):FlxColor {
		var rgb = [];
        if(hex.startsWith('0x')) {
            hex = hex.substr(2);
        }
        while(hex.length > 0) {
            rgb.push(Std.parseInt('0x${hex.substr(0,2)}'));
            hex = hex.substr(2);
        }
        return FlxColor.fromRGB(rgb[1],rgb[2],rgb[3],rgb[0]);
    }

	inline public static function getTopCam():FlxCamera {
		return FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	/*
     *	RATING UTIL
    */

    public static var judgeOffsets:Array<Int> =         [127, 106, 43];
    public static var returnJudgements:Array<String> =  ['shit', 'bad', 'good'];

    public static function getNoteJudgement(noteDiff:Float):String {
        for (i in 0...judgeOffsets.length) {
            if (checkDiff(noteDiff, judgeOffsets[i]))
                return returnJudgements[i];
        }
        return 'sick';
    }

    inline public static function checkDiff(noteDiff:Float, safeOffset:Int):Bool {
        var safeZoneOffset = Conductor.safeZoneOffset;
        var millisecondDiff = getMillisecondDiff(safeOffset);
        return (noteDiff > safeZoneOffset * millisecondDiff || noteDiff < safeZoneOffset * -millisecondDiff);
    }

    inline public static function getMillisecondDiff(milliseconds:Int):Float {
        return (milliseconds / Conductor.safeZoneOffset);
    }

    inline public static function getNoteDiff(daNote:Note):Float {
        return Math.abs(daNote.strumTime - Conductor.songPosition);
    }

	inline public static function switchState(newState:FlxState) {
		if (MusicBeatState.instance == null) {
			FlxG.switchState(newState);
			return;
		}
		MusicBeatState.instance.switchState(newState);
	}

	inline public static function resetState() {
		if (MusicBeatState.instance == null) {
			FlxG.resetState();
			return;
		}
		MusicBeatState.instance.resetState();
	}
}