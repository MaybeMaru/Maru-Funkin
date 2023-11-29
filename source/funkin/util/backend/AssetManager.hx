package funkin.util.backend;

import flixel.util.typeLimit.OneOfTwo;
import flixel.system.FlxAssets.FlxSoundAsset;
import openfl.display.BitmapData;
import flash.media.Sound;
import lime.utils.Assets as LimeAssets;
import openfl.Assets as OflAssets;

typedef AssetGraphic = OneOfTwo<FlxGraphic, String>;

// Just moving this from Paths for organization sake
class AssetManager {	
	public static final cachedGraphics:Map<String, FlxGraphic> = [];
	public static final cachedSounds:Map<String, Sound> = [];

	private static inline function __toGraphic(__graphic:AssetGraphic):Null<FlxGraphic> {
		if (__graphic is FlxGraphic) return __graphic;
		else						 return (existsGraphic(__graphic) ? getGraphic(__graphic) : null);
	}
    
	static public function getImage(path:String, gpu:Bool = true):FlxGraphicAsset {
		if (gpu) {
			if (Preloader.existsGraphic(path)) return Preloader.getGraphic(path);
			else if (Paths.exists(path, IMAGE)) {
				final bitmap:BitmapData = getBitmapData(path);
				return Preloader.addFromBitmap(bitmap, path);
			}
		} else return getGraphic(path, true);
		return path;
	}

	inline public static function clearBitmapCache() {
		for (key in cachedGraphics.keys()) {
			removeGraphicByKey(key);
		}
		#if !hl
		if (Preferences.getPref('clear-gpu')) {
			for (key in Preloader.cachedTextures.keys()) {
				if (key.startsWith('mods/'))
					Preloader.removeByKey(key, true);
			}
		}
		#end
		FlxG.bitmap.clearCache();
	}

	public static inline function removeGraphicByKey(key:String) {
		if (existsGraphic(key)) {
			final obj = cachedGraphics.get(key);
			cachedGraphics.remove(key);
			destroyGraphic(obj);
		}
	}

	public static inline function destroyGraphic(?graphic:FlxGraphic) {
		if (graphic != null) {
			graphic.persist = false;
			graphic.destroyOnNoUse = true;
			disposeBitmap(graphic.bitmap);
			graphic.bitmap = null;
			graphic.destroy();
		}
	}

	inline public static function disposeBitmap(bitmap:BitmapData) {
		bitmap.dispose();
		bitmap.disposeImage();
	}

	inline static public function existsGraphic(key:String) {
		return cachedGraphics.exists(key);
	}

	static public function addGraphic(width:Int, height:Int, color:FlxColor, ?key:String) {
		if (existsGraphic(key)) return cachedGraphics.get(key);
		final bitmap = new BitmapData(width, height, true, color);
		final graphic = @:privateAccess {new FlxGraphic(key, bitmap, true); }
		graphic.destroyOnNoUse = false;
		cachedGraphics.set(key, graphic);
		return graphic;
	}

	static public function addGraphicFromBitmap(bitmap:BitmapData, key:String, cache:Bool = false) {
		final graphic = FlxGraphic.fromBitmapData(bitmap);
		graphic.persist = cache;
		if (cache) cachedGraphics.set(key, graphic);
		return graphic;
	}
	
	static inline public function getRawBitmap(key:String) {
		#if desktop	
		final fixPath = Paths.removeAssetLib(key);
		if (!fixPath.startsWith('assets'))
			return BitmapData.fromFile(fixPath);
		#end
		return OpenFlAssets.getBitmapData(key, false);
	}

	static public function getGraphic(key:String, cache:Bool = false) {
		if (existsGraphic(key)) return cachedGraphics.get(key);
		return addGraphicFromBitmap(getRawBitmap(key), key, cache);
	}

	inline static public function getBitmapData(key:String, cache:Bool = false):BitmapData {
		return getGraphic(key, cache).bitmap;
	}

	static public function uploadGraphicGPU(key:String) {
		if (!existsGraphic(key)) return null;
		final graphic = getGraphic(key);
		final gpuGraphic = Preloader.uploadTexture(graphic.bitmap, key);
		removeGraphicByKey(key);
		cachedGraphics.set(key, gpuGraphic);
		return gpuGraphic;
	}

	public static function clearSoundCache(forced:Bool = false) {
		for (key in cachedSounds.keys()) {
			if (key.contains(Conductor._loadedSong) && !forced) continue;
			else												Conductor._loadedSong = "";
			removeSoundByKey(key);
		}
	}

	static public inline function removeSoundByKey(key:String) {
		if (!cachedSounds.exists(key)) return;
		cachedSounds.get(key).close();
		LimeAssets.cache.clear(key);
		OflAssets.cache.removeSound(key);
		cachedSounds.remove(key);
	}

	static public function getSound(key:String):FlxSoundAsset {
		if (cachedSounds.exists(key)) return cachedSounds.get(key);
		#if desktop
		final fixPath = Paths.removeAssetLib(key);
		if (!fixPath.startsWith('assets')) {
			final sound = Sound.fromFile(fixPath);
			cachedSounds.set(key, sound);
			return sound;
		}
		#end
		if (Paths.exists(key, MUSIC)) {
			final sound = OpenFlAssets.getSound(key);
			cachedSounds.set(key, sound);
			return sound;
		}
		return key;
	}
}