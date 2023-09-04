package funkin.util;

import textureAtlas.TextureAtlas;
import flixel.system.FlxAssets;
import flash.media.Sound;
import flixel.system.FlxAssets.FlxSoundAsset;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets as LimeAssets;
import openfl.Assets as OflAssets;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	public static var currentLevel:String;

	static public function setCurrentLevel(name:String) {
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, library:Null<String>, allMods:Bool = false, mods:Bool = true, ?level:String):String {
		#if desktop
		if (mods) {
			var modLib:String = '';
			if (library != null)
				modLib = '$library/';

			var _folder = ModdingUtil.curModFolder.length <= 0 ? '' : '${ModdingUtil.curModFolder}/';
			var modFolderPath = getModPath('$_folder$modLib$file');
			if (FileSystem.exists(modFolderPath))
				return modFolderPath;
			
			if (allMods) {
				for (modFolder in ModdingUtil.modFolders) {
					if (ModdingUtil.modFoldersMap.get(modFolder)) {
						var modFolderPath = getModPath('$modFolder/$modLib$file');
						if (FileSystem.exists(modFolderPath))
							return modFolderPath;
					}
				}
			}
			
			var modPath = getModPath('$modLib$file');
			if (FileSystem.exists(modPath))
				return modPath;
		}
		#end

		if (library != null && level != null) {
			var levelPath = getLibraryPathForce(file, library, level);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}
		else if (library != null) {
			var libraryPath = getLibraryPath(file, library);
			if (OpenFlAssets.exists(libraryPath, type))
				return libraryPath;
		}

		if (currentLevel != null) {
			var curLevelPath = getLibraryPathForce(file, 'weeks', currentLevel);
			if (OpenFlAssets.exists(curLevelPath, type))
				return curLevelPath;
		}

		var sharedPath = getLibraryPathForce(file, "shared");
		if (OpenFlAssets.exists(sharedPath, type))
			return sharedPath;

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload", ?level:String):String
	{
		return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library, level);
	}

	inline static function getLibraryPathForce(file:String, library:String, ?level:String):String
	{
		return (level != null) ? '$library:assets/$library/$level/$file' : '$library:assets/$library/$file';
	}

	inline static public function getModPath(file:String):String
	{
		return 'mods/$file';
	}

	inline static function getPreloadPath(file:String):String
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String):String
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String, checkMods:Bool = true):String
	{
		return getPath('data/$key.txt', TEXT, library, false, checkMods);
	}

	inline static public function xml(key:String, ?library:String):String
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String):String
	{
		return getPath('data/$key.json', TEXT, library);
	}
	
	inline static public function script(key:String, ?library:String):String
	{
		return getPath('data/$key.hx', TEXT, library);
	}

	inline static public function shader(key:String, ?library:String):String
	{
		return getPath('data/shaders/$key.frag', TEXT, library);
	}

	static public function sound(key:String, ?library:String, ?level:String):FlxSoundAsset
	{
		var soundPath:String = getPath('sounds/$key.$SOUND_EXT', SOUND, library, false, true, level);
		var soundFile:FlxSoundAsset = getSound(soundPath);
		return soundFile;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):FlxSoundAsset
	{
		return sound('$key${FlxG.random.int(min, max)}', library);
	}

	inline static public function music(key:String, ?library:String, forcePath:Bool = false):FlxSoundAsset
	{
		var musicPath:String = getPath('music/$key.$SOUND_EXT', MUSIC, library);
		var soundFile:FlxSoundAsset = getSound(musicPath);
		return forcePath ? musicPath : soundFile;
	}

	inline static public function voices(song:String, forcePath:Bool = false):FlxSoundAsset
	{
		var voicesPath:String = getPath('${Song.formatSongFolder(song)}/audio/Voices.$SOUND_EXT', MUSIC, 'songs');
		return forcePath ? voicesPath : getSound(voicesPath);
	}

	inline static public function inst(song:String, forcePath:Bool = false):FlxSoundAsset
	{
		var instPath:String = getPath('${Song.formatSongFolder(song)}/audio/Inst.$SOUND_EXT', MUSIC, 'songs');
		return forcePath ? instPath : getSound(instPath);
	}

	inline static public function chart(song:String, diff:String, ext:String = 'json'):String
	{
		return getPath('${Song.formatSongFolder(song)}/charts/${diff.toLowerCase()}.$ext', TEXT, 'songs');
	}

	inline static public function image(key:String, ?library:String, forcePath:Bool = false, allMods:Bool = false, gpu:Bool = true):FlxGraphicAsset
	{
		var imagePath:String = getPath('images/$key.png', IMAGE, library, allMods);
		return forcePath ? imagePath : getImage(imagePath, gpu);
	}

	inline static public function font(key:String, ?library:String):String
	{
		return getPath('fonts/$key.ttf', FONT, library);
	}

	inline static public function video(key:String, ?library:String):String
		{
			return getPath('videos/$key.mp4', BINARY, library);
		}

	inline static public function exists(file:String, type:AssetType):Bool {
		#if desktop return FileSystem.exists(removeAssetLib(file));
		#else		return OpenFlAssets.exists(file, type);			#end
	}

	inline static public function removeAssetLib(path:String):String {
		return #if desktop path.contains(':') ? path.split(':')[1] : #end path;
	}

	//	Returns [file Mod, file Name]
	inline static public function getFileMod(dir:String):Array<String> {
		var dirParts = dir.split('/');
		return [dirParts[1], dirParts[dirParts.length-1].split('.')[0]];
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, gpu:Bool = true):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key, library, false, false, gpu), CoolUtil.getFileContent(file('images/$key.xml', library)));
	}

	inline static public function getPackerAtlas(key:String, ?library:String, gpu:Bool = true):FlxAtlasFrames {
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library, false, false, gpu), CoolUtil.getFileContent(file('images/$key.txt', library)));
	}

	inline static public function getAsepriteAtlas(key:String, ?library:String, gpu:Bool = true):FlxAtlasFrames {
		return JsonUtil.getAsepritePacker(key, library, gpu);
	}

	inline static public function getTextureAtlas(key:String, ?library:String):FlxAtlasFrames {
		trace(file('images/$key/Animation.json', TEXT, library).replace("/Animation.json", ""));
		return TextureAtlas.fromAtlas(file('images/$key/Animation.json', TEXT, library).replace("/Animation.json", ""));
	}

	inline static public function getFileList(type:AssetType = IMAGE, fullPath:Bool = true, ?extension:String, ?folder:String):Array<String> {
		var fileList:Array<String> = [];
		for (file in OpenFlAssets.list(type)) {
			if (file.startsWith('assets/')) {
				if (extension == null || file.endsWith(extension)) {
					if (folder == null || file.contains(folder)) {
						file = fullPath ? file : file.split('/')[file.split('/').length-1].split('.')[0];
						fileList.push(file);
					}
				}
			}
		}
		fileList.sort(CoolUtil.sortAlphabetically);
		return fileList;
	}

	inline static public function getModFileList(folder:String, ?extension:String, fullPath:Bool = true, global:Bool = true, curFolder:Bool = true, allFolders:Bool = false):Array<String> {
		#if !desktop return [];
		#else
		var fileList:Array<String> = [];
		var pushFile = function(folderPath:String) {
			if (FileSystem.exists(folderPath)) {
				for (filePath in FileSystem.readDirectory(folderPath)) {
					if (filePath.endsWith(extension) || extension == null) {
						var leFile:String = '$folderPath/$filePath';
						leFile = fullPath ? leFile : leFile.split('/')[leFile.split('/').length-1].split('.')[0];
						fileList.push(leFile);
					}
				}
			}
		};
		if (global) pushFile(getModPath(folder));
		if (curFolder) pushFile(getModPath('${ModdingUtil.curModFolder}/$folder'));
		if (allFolders) {
			for (modFolder in ModdingUtil.modFolders) {
				if (ModdingUtil.modFoldersMap.get(modFolder))
					pushFile(getModPath('$modFolder/$folder'));
			}
		}
		fileList.sort(CoolUtil.sortAlphabetically);
		return fileList;
		#end
	}

	static public function getImage(path:String, gpu:Bool = true):FlxGraphicAsset {
		if (gpu) {
			if (Preloader.existsBitmap(path)) return Preloader.getBitmap(path);
			else if (exists(path, IMAGE)) {
				var bitmap:BitmapData = getBitmapData(path);
				return Preloader.addFromBitmap(bitmap, path);
			}
		} else return getGraphic(path, true);
		return path;
	}

	/*
		Used to get bitmaps without using gpu loading
		Gpu loading is faster but breaks bitmap functions
	*/
	public static var cachedGraphics:Map<String, FlxGraphic> = [];
	
	inline public static function clearBitmapCache() {
		for (key in cachedGraphics.keys()) {
			removeGraphicByKey(key);
		}
		/*for (key in Preloader.bitmapCache.keys()) {
			if (key.contains("mods")) Preloader.removeByKey(key);
		}*/
		FlxG.bitmap.clearCache();
	}

	inline public static function removeGraphicByKey(key:String) {
		if (!existsGraphic(key)) return;
		var obj = cachedGraphics.get(key);
		cachedGraphics.remove(key);
		destroyGraphic(obj);
	}

	inline public static function destroyGraphic(?graphic:FlxGraphic) {
		if (graphic == null) return;
		graphic.persist = false;
		graphic.destroyOnNoUse = true;
		graphic.destroy();
	}

	static public function existsGraphic(key:String) {
		return cachedGraphics.exists(key);
	}

	static public function addGraphic(width:Int, height:Int, color:FlxColor, ?key:String) {
		if (existsGraphic(key)) return cachedGraphics.get(key);
		var bitmap = new BitmapData(width, height, true, color);
		var graphic = @:privateAccess {new FlxGraphic(key, bitmap, true); }
		graphic.destroyOnNoUse = false;
		cachedGraphics.set(key, graphic);
		return graphic;
	}

	static public function addGraphicFromBitmap(bitmap:BitmapData, key:String, cache:Bool = false) {
		var graphic = FlxGraphic.fromBitmapData(bitmap);
		graphic.persist = cache;
		if (cache) cachedGraphics.set(key, graphic);
		return graphic;
	}

	static public function getRawBitmap(key:String) {
		#if desktop	
		var fixPath = removeAssetLib(key);
		if (!fixPath.startsWith('assets'))
			return BitmapData.fromFile(fixPath);
		#end
		return OpenFlAssets.getBitmapData(key, false);
	}

	static public function getGraphic(key:String, cache:Bool = false) {
		if (existsGraphic(key)) return cachedGraphics.get(key);
		return addGraphicFromBitmap(getRawBitmap(key), key, cache);
	}

	static public function getBitmapData(key:String, cache:Bool = false):BitmapData {
		return getGraphic(key, cache).bitmap;
	}

	public static var cachedSounds:Map<String, Sound> = [];
	public static var excludeSounds:Array<String> = [];
	inline public static function clearSoundCache(forced:Bool = false) {
		for (key in cachedSounds.keys()) {
			if (key.contains(Conductor._loadedSong) && !forced) continue;
			else												Conductor._loadedSong = "";
			cachedSounds.get(key).close();
			LimeAssets.cache.clear(key);
			OflAssets.cache.removeSound(key);
			cachedSounds.remove(key);
		}
	}

	static public function getSound(key:String):FlxSoundAsset {
		if (cachedSounds.exists(key)) return cachedSounds.get(key);
		#if desktop
		var fixPath = removeAssetLib(key);
		if (!fixPath.startsWith('assets')) {
			var sound = Sound.fromFile(fixPath);
			cachedSounds.set(key, sound);
			return sound;
		}
		#end
		if (exists(key, MUSIC)) {
			var sound = OpenFlAssets.getSound(key);
			cachedSounds.set(key, sound);
			return sound;
		}
		return key;
	}

	inline static public function getPackerType(key:String, ?library:String):PackerType {
		if 		(exists(file('images/$key.xml', library), TEXT))				return SPARROW;
		else if (exists(file('images/$key.txt', library), TEXT))				return SHEETPACKER;
		else if (exists(file('images/$key.json', library), TEXT))				return JSON;
		else if (exists(file('images/$key/Animation.json', library), TEXT))		return ATLAS;
		else																	return IMAGE;
	}
}

enum PackerType {
	IMAGE;
	SPARROW;
	SHEETPACKER;
	JSON;
	ATLAS;
}