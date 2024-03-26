package funkin.util;

import flixel.math.FlxMatrix;
import openfl.geom.Matrix;
import flixel.util.typeLimit.OneOfTwo;
import flixel.system.FlxAssets.FlxSoundAsset;
#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif neko
import neko.vm.Gc;
#end

typedef CacheClearing =  {
	?tempCache:Bool,
	?staticCache:Bool,
	?shaders:Bool,
	?skins:Bool
}

enum abstract SoundType(Int) from Int to Int {
	var SOUND = 0;
	var MUSIC = 1;
}

class CoolUtil {
	public static var defaultDiffArray:Array<String> = 	['easy', 'normal', 'hard'];
	public static var directionArray:Array<String> = 	['LEFT','DOWN','UP','RIGHT'];
	public static var colorArray:Array<String> = 		['purple','blue','green','red'];
	public static var noteColorArray:Array<Int> = 		[0xffc24b99, 0xff00ffff, 0xff12fa05, 0xfff9393f];
	public static var debugMode:Bool = false;

	inline public static function init():Void {
		#if ZIPS_ALLOWED
		FunkThread.run(funkin.util.backend.SongZip.init);
		#end
		#if desktop
		ModdingUtil.reloadMods();
		#end
		SkinUtil.setCurSkin();
		NoteUtil.initTypes();
		EventUtil.initEvents();
	}

	// Static variables for quick calculations
	public static var point:FlxPoint = FlxPoint.get();
	public static var rect:FlxRect = FlxRect.get();
	public static var matrix:FlxMatrix = new FlxMatrix();
	public static var rectangle:Rectangle = new Rectangle();

	public inline static function resetMatrix():FlxMatrix {
		final mat = matrix;
		mat.a = 1;
		mat.b = 0;
		mat.c = 0;
		mat.d = 1;
		mat.tx = 0;
		mat.ty = 0;
		return mat;
	}

	public static inline function matrixScale(mat:FlxMatrix, sx:Float, sy:Float):Void
	{
		if (sx != 1) {
			mat.a = (mat.a * sx);
			mat.c = (mat.c * sx);
			mat.tx = (mat.tx * sx);
		}

		if (sy != 1) {
			mat.b = (mat.b * sy);
			mat.d = (mat.d * sy);
			mat.ty = (mat.ty * sy);
		}
	}

	inline public static function openUrl(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
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

	inline public static function numberArray(max:Int, min:Int = 0):Array<Int> {
		return [for (i in min...max) i];
	}

	inline public static function clearCache(?cacheClear:CacheClearing, softClear:Bool = false) {
		cacheClear = JsonUtil.checkJsonDefaults({
			tempCache: true,
			staticCache: false,
			shaders: true,
			skins: true
		}, cacheClear);

		if (cacheClear.shaders) Shader.clearShaders();
		if (cacheClear.skins) NoteUtil.clearSkinsData();

		if (cacheClear.tempCache) AssetManager.clearTempCache(false);
		if (cacheClear.staticCache) AssetManager.clearTempCache(false);

		gc(true);
	}
	
	inline public static function gc(major:Bool = false) {
		#if (cpp || hl || neko)
			#if hl
				Gc.blocking(true);
				Gc.major();
				Gc.blocking(false);
			#else
				Gc.run(major);
				#if cpp
					if (major)
						Gc.compact();
				#end
			#end
		#end
	}

	inline public static function setGlobalManager(active:Bool = true) @:privateAccess {
		FlxTimer.globalManager._timers.fastForEach((timer, i) -> {
			if (!timer.finished)
				timer.active = active;
		});

		FlxTween.globalManager._tweens.fastForEach((tween, i) -> {
			if (!tween.finished)
				tween.active = active;
		});
	}

	inline static function soundFromAsset(asset:FlxSoundAsset, kill:Bool = false):FlxSound {
		var sound:FlxSound = FlxG.sound.list.recycle(FlxSound).loadEmbedded(asset);
		sound.onComplete = !kill ? null : function () {
			sound.volume = 0;
			sound.kill();
		}
		return sound;
	}

	inline public static function getSound(key:String, lib:SoundType = SOUND, kill:Bool = false):FlxSound {
		return soundFromAsset(switch(lib) {
			case SOUND: Paths.sound(key);
			case MUSIC: Paths.music(key);
		}, kill);
	}

	inline public static function playSound(asset:FlxSoundAsset, volume:Float = 1, ?pitch:Float) {
		final sound:FlxSound = ((asset is String) ? getSound(cast(asset, String), SOUND, true) : soundFromAsset(asset, true));
		sound.volume = volume;
		sound.pitch = pitch ?? FlxG.timeScale;
		sound.play();

		return sound;
	}

	public static var resumeSoundsList:Array<FlxSound> = [];
	inline public static function pauseSounds() {
		resumeSoundsList.splice(0, resumeSoundsList.length);
		FlxG.sound.list.members.fastForEach((sound, i) -> {
			if (sound.playing)
				resumeSoundsList.push(sound);

			sound.pause();
		});
	}

	inline public static function resumeSounds() {
		resumeSoundsList.fastForEach((sound, i) -> {
			sound.play();
		});

		resumeSoundsList.splice(0, resumeSoundsList.length);
	}

	public static inline var PI:Float = 3.14159265358979323846;
	public static inline var DOUBLE_PI:Float = PI * 2;
	public static inline var TO_RADS:Float = PI / 180;
	public static inline var TO_DEGREES:Float = 180 / PI;

	public static inline function sin(radians:Float) {
		return #if FAST_MATH FlxMath.fastSin(radians); #else Math.sin(radians); #end
	}

	public static inline function cos(radians:Float) {
		return #if FAST_MATH FlxMath.fastCos(radians); #else Math.cos(radians); #end
	}

	public static inline function sinAngle(angle:Float) {
		return sin(angle * TO_RADS);
	}

	public static inline function cosAngle(angle:Float) {
		return cos(angle * TO_RADS);
	}

	public static inline function positionInCenter(object:FlxObject, object2:FlxObject, setToPosition:Bool = false) {
		object.x = (object2.width - object.width) * .5;
		object.y = (object2.height - object.height) * .5;
		if (setToPosition) {
			object.x += object2.x;
			object.y += object2.y;
		}
	}

	public static inline function positionWithTrig(object:FlxObject, x:Float = 0.0, y:Float = 0.0, cos:Float = 1.0, sin:Float = 0.0) {
		object.x = (x * cos) + (y * -sin);
        object.y = (x * sin) + (y * cos);
	}

	public static inline function translateWithTrig(object:FlxObject, x:Float = 0.0, y:Float = 0.0, cos:Float = 1.0, sin:Float = 0.0) {
		object.x += (x * cos) + (y * -sin);
        object.y += (x * sin) + (y * cos);
	}

	public static inline function offsetWithTrig(object:FlxObject, x:Float = 0.0, y:Float = 0.0, cos:Float = 1.0, sin:Float = 0.0) {
		translateWithTrig(object, -x, -y, cos, sin);
	}

	public static inline function translateWithAngle(object:FlxObject, x:Float = 0.0, y:Float = 0.0, angle:Float = 0.0) {
		var rads:Float = angle * TO_RADS;
		translateWithTrig(object, x, y, sin(rads), cos(rads));
	}

	public static inline function offsetWithAngle(object:FlxObject, x:Float = 0.0, y:Float = 0.0, angle:Float = 0.0) {
		translateWithAngle(object, -x, -y, angle);
	}

	/*
		lil shortcut to play music
		itll also change the conductor bpm to the music's data text file thing
	*/
	public static function playMusic(music:String, volume:Float = 1, looped:Bool = true):Void {
		FlxG.sound.playMusic(Paths.music(music), volume, looped);

		var musicDataPath:String = Paths.getPath('music/$music-data.txt', MUSIC, null);
		if (Paths.exists(musicDataPath, TEXT)) {
			Conductor.bpm = Std.parseFloat(getFileContent(musicDataPath));
		}
	}

	inline public static function stopMusic() {
		if (FlxG.sound.music != null) FlxG.sound.music.stop();
	}

	inline public static function formatStringUpper(string:String) {
		return string.charAt(0).toUpperCase() + string.substr(1);
	}

	inline public static function destroyMusic() {
		stopMusic();
		FlxG.sound.music = null;
	}

	public static inline var baseLerp = 1 / 60;
	inline public static function getLerp(ratio:Float):Float {
		return FlxG.elapsed / baseLerp * ratio;
	}

	inline public static function coolLerp(a:Float, b:Float, ratio:Float):Float {
		return FlxMath.lerp(a, b, getLerp(ratio));
	}

	public static inline function sortByStrumTime(a:Dynamic, b:Dynamic) {
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
            if (!result.contains(i))
                result.push(i);
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

	inline public static function getTopCam():FlxCamera {
		return FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	inline public static function switchState(newState:FlxState, skipTransOpen:Bool = false, ?skipTransClose:Bool) {
		Transition.setSkip(skipTransOpen, skipTransClose);
		Main.transition.startTrans(newState);
		__pauseState();
	}

	inline public static function resetState(skipTransOpen:Bool = false, ?skipTransClose:Bool) {
		Transition.setSkip(skipTransOpen, skipTransClose);
		Main.transition.startTrans(null, FlxG.resetState);
		__pauseState();
	}

	inline public static function cacheImage(image:FlxGraphicAsset, ?library:String, ?camera:FlxCamera):FlxGraphicAsset {
		if (image == null) return null;
		
		if (image is String)
			image = Paths.image(image, library);

		if ((camera != null) && (image is FlxGraphic))
			camera.startQuadBatch(image, false, false, null, false, null);

		return image;
	}

	@:noCompletion
	inline private static function __pauseState() {
		FlxG.state.openSubState(new FlxSubState());
		if (FlxG.state is MusicBeatState) {
			cast(FlxG.state, MusicBeatState).startTransition();
		}
	}

	/*
     *	RATING UTIL
     */

    public static final judgeOffsets:Array<Int> = [127, 106, 43];
    public static final returnJudgements:Array<String> = ['shit', 'bad', 'good'];

    public static function getNoteJudgement(noteDiff:Float):String {
		var i = 0;
		var l = judgeOffsets.length;
		while (i < l) {
			if (checkDiff(noteDiff, judgeOffsets[i]))
                return returnJudgements[i];
			i++;
		}
		return "sick";
    }

    inline public static function checkDiff(noteDiff:Float, safeOffset:Int):Bool {
        var safeZoneOffset = Conductor.safeZoneOffset;
        var millisecondDiff = getMillisecondDiff(safeOffset);
        return (noteDiff > safeZoneOffset * millisecondDiff || noteDiff < safeZoneOffset * -millisecondDiff);
    }

    inline public static function getMillisecondDiff(milliseconds:Int):Float {
        return (milliseconds * Conductor.safeZoneOffsetMult);
    }

    inline public static function getNoteDiff(daNote:Note):Float {
        return Math.abs(daNote.strumTime - Conductor.songPosition);
    }
}