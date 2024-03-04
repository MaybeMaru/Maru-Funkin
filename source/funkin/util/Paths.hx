package funkin.util;

import openfl.media.Sound;
import haxe.io.Path;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if desktop
import sys.FileSystem;
#end

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	public static var currentLevel(default, set):String = "";

	public static function set_currentLevel(value:String)
		return currentLevel = value.toLowerCase();

	public static function getPath(file:String, type:AssetType, ?library:String, allMods:Bool = false, mods:Bool = true, ?level:String):String {
		final hasLevel = currentLevel.length > 0;
		
		#if desktop
		if (mods) {
			final modFile:String = ((library?.length ?? 0) != 0 ? '$library/' : '') + file;
			final modFolder:String = ModdingUtil.curModFolder != null ? ModdingUtil.curModFolder + "/" : "";
			
			final modFolderPath:String = getModPath(modFolder + modFile);
			if (exists(modFolderPath, type))
				return modFolderPath;

			if (hasLevel) {
				final levelPath = getLibraryPathForce(modFile, 'weeks', currentLevel, 'mods/$modFolder');
				if (exists(levelPath, type))
					return levelPath;
			}
			
			if (allMods) {
				for (i in ModdingUtil.activeMods.keys()) {
					final modPath:String = getModPath(i + "/" + modFile);
					if (ModdingUtil.activeMods.get(i) && exists(modPath, type))
						return modPath;
				}
			}

			for (i in ModdingUtil.globalMods) {
				final modPath:String = getModPath(i.folder + "/" + modFile);
				if (exists(modPath, type))
					return modPath;
			}
			
			final modPath = getModPath(modFile);
			if (exists(modPath, type))
				return modPath;
		}
		#end

		if (library != null) {
			if (level != null) {
				final levelPath = getLibraryPathForce(file, library, level);
				if (exists(levelPath, type))
					return levelPath;
			} else {
				final libraryPath = getLibraryPath(file, library);
				if (exists(libraryPath, type))
					return libraryPath;
			}
		}

		if (hasLevel) {
			final curLevelPath = getLibraryPathForce(file, 'weeks', currentLevel);
			if (exists(curLevelPath, type))
				return curLevelPath;
		}

		final sharedPath = getLibraryPathForce(file, "shared");
		if (exists(sharedPath, type))
			return sharedPath;

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload", ?level:String, root:String = "assets"):String
	{
		return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library, level, root);
	}

	inline static function getLibraryPathForce(file:String, library:String, ?level:String, root:String = "assets"):String
	{
		return (level != null) ? '$library:$root/$library/$level/$file' : '$library:$root/$library/$file';
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

	/*
	 * SOUNDS
	**/

	inline static public function soundExt(key:String, folder:String, ?library:String, ?level:String):String {
		return getPath('$folder/$key.$SOUND_EXT', SOUND, library, false, true, level);
	}

	inline static public function soundFolder(key:String, ?library:String, ?level:String):String {
		return soundExt(key, "sounds", library, level);
	}

	inline static public function sound(key:String, ?library:String, ?level:String):Sound {
		var soundPath = soundFolder(key, library, level);
		return AssetManager.cacheSoundPath(soundPath);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):Sound {
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function musicFolder(key:String, ?library:String, ?level:String):String {
		return soundExt(key, "music", library, level);
	}

	inline static public function music(key:String, ?library:String, ?level:String):Sound {
		var musicPath = musicFolder(key, library, level);
		return AssetManager.cacheSoundPath(musicPath);
	}

	/*
	 * SONGS
	**/

	inline static public function songAudioAssetPath(song:String, asset:String, ?globalAsset:Bool):String {
		return getPath('${Song.formatSongFolder(song)}/audio/$asset.$SOUND_EXT', MUSIC, 'songs', globalAsset);
	}

	inline static public function voicesPath(song:String, ?globalAsset:Bool):String {
		return songAudioAssetPath(song, "Voices", globalAsset);
	}

	inline static public function voices(song:String, ?globalAsset:Bool):Sound {
		var voicesPath:String = voicesPath(song, globalAsset);
		return AssetManager.cacheSoundPath(voicesPath);
	}

	inline static public function instPath(song:String, ?globalAsset:Bool):String {
		return songAudioAssetPath(song, "Inst", globalAsset);
	}

	inline static public function inst(song:String, ?globalAsset:Bool):Sound {
		var instPath:String = instPath(song, globalAsset);
		return AssetManager.cacheSoundPath(instPath);
	}

	inline static public function chart(song:String, diff:String, ext:String = 'json'):String {
		if (!ext.startsWith('/'))
			ext = '.$ext';

		return getPath('${Song.formatSongFolder(song)}/charts/${diff.toLowerCase()}$ext', TEXT, 'songs');
	}

	inline static public function songMeta(song:String) {
		return getPath('${Song.formatSongFolder(song)}/charts/songMeta.json', TEXT, 'songs');
	}

	/*
	 * GRAPHICS
	**/

	inline static public function png(key:String, ?library:String, ?globalAsset:Bool):String {
		return getPath('images/$key.png', IMAGE, library, globalAsset ?? false);
	}

	inline static public function image(key:String, ?library:String, ?globalAsset:Bool, ?useTexture:Bool, ?lodLevel:LodLevel):LodGraphic {
		var pngPath = png(key, library, globalAsset);
		return AssetManager.cacheGraphicPath(pngPath, false, useTexture, lodLevel);
	}

	inline static public function font(key:String, ?library:String):String {
		return getPath('fonts/$key.ttf', FONT, library);
	}

	inline static public function video(key:String, ?library:String):String {
		return getPath('videos/$key.mp4', BINARY, library);
	}

	inline static public function exists(file:String, type:AssetType):Bool {
		#if desktop
		return FileSystem.exists(removeAssetLib(file));
		#else
		return OpenFlAssets.exists(file, type);
		#end
	}

	inline static public function removeAssetLib(path:String):String {
		return #if desktop path.contains(':') ? path.split(':')[1] : #end path;
	}

	//	Returns [file Mod, file Name]
	inline static public function getFileMod(dir:String):Array<String> {
		var dirParts = dir.split('/');
		return [dirParts[1], dirParts[dirParts.length-1].split('.')[0]];
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, ?useTexture:Bool, ?lodLevel:LodLevel):FlxAtlasFrames {
		var image = image(key, library, false, useTexture, lodLevel);
		var xml = CoolUtil.getFileContent(file('images/$key.xml', library));
		
		return __checkLodFrames(FlxAtlasFrames.fromSparrow(image, xml));
	}

	inline static public function getSpriteSheetAtlas(key:String, ?library:String, ?useTexture:Bool, ?lodLevel:LodLevel):FlxAtlasFrames {
		var image = image(key, library, false, useTexture, lodLevel);
		var txt = CoolUtil.getFileContent(file('images/$key.txt', library));

		return __checkLodFrames(FlxAtlasFrames.fromSpriteSheetPacker(image, txt));
	}

	inline static public function getAsepriteAtlas(key:String, ?library:String, ?useTexture:Bool, ?lodLevel:LodLevel):FlxAtlasFrames {
		var image = image(key, library, false, useTexture, lodLevel);
		var json = CoolUtil.getFileContent(file('images/$key.json', library));
		
		return __checkLodFrames(JsonUtil.getAsepritePacker(image, json));
	}

	//inline static public function getAnimateAtlas(key:String, ?library:String):FlxAtlasFrames {
	//	return null;
	//}

	@:noCompletion
	inline private static function __checkLodFrames(frames:FlxAtlasFrames):FlxAtlasFrames {
		var parent:LodGraphic = cast(frames.parent, LodGraphic);
		if (parent.lodLevel == 0 || parent.parsedChildren)
			return frames;

		var lodScale = parent.lodScale;
		for (frame in frames.frames) {
			var rect = frame.frame;
			rect.x /= lodScale;
            rect.y /= lodScale;
            rect.width /= lodScale;
            rect.height /= lodScale;

			var offset = frame.offset;
			offset.x /= lodScale;
			offset.y /= lodScale;
		}

		parent.parsedChildren = true;

		return frames;
	}

	static public function getFileList(type:AssetType = IMAGE, fullPath:Bool = true, ?extension:String, ?folder:String):Array<String> {
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

	static public function getModFileList(folder:String, ?extension:String, fullPath:Bool = true, global:Bool = true, curFolder:Bool = true, allFolders:Bool = false):Array<String> {
		#if !desktop return [];
		#else
		var fileList:Array<String> = [];
		var pushFile = function(folderPath:String) {
			if (FileSystem.exists(folderPath)) {
				var fileSort = CoolUtil.getFileContent('$folderPath/listSort.txt').split(",");
				for (i in 0...fileSort.length) {
					var sortPrefix = fullPath ? '$folderPath/' : '';
					var sortSuffix = extension == null || !fullPath ? "" : '.$extension';
					fileSort[i] = '$sortPrefix${fileSort[i]}$sortSuffix';
				}

				var curFolderList = [];
				var dirRead = FileSystem.readDirectory(folderPath);
				dirRead.sort(CoolUtil.sortAlphabetically);
				for (i in dirRead) {
					if (i.endsWith(extension) || extension == null)
						curFolderList.push(fullPath ? '$folderPath/$i' : Path.withoutExtension(i));
				}

				fileList = fileList.concat(CoolUtil.customSort(curFolderList, fileSort));
			}
		};
		if (global) pushFile(getModPath(folder));
		if (curFolder) pushFile(getModPath('${ModdingUtil.curModFolder}/$folder'));
		if (allFolders) {
			for (i in ModdingUtil.activeMods.keys()) {
				if (ModdingUtil.activeMods.get(i))
					pushFile(getModPath('$i/$folder'));
			}
		}
		
		return fileList;
		#end
	}

	inline static public function getPackerType(key:String, ?library:String):PackerType {
		if 		(exists(file('images/$key.xml', library), TEXT))				return SPARROW;
		else if (exists(file('images/$key.txt', library), TEXT))				return SHEETPACKER;
		else if (exists(file('images/$key.json', library), TEXT))				return JSON;
		else if (exists(file('images/$key/Animation.json', library), TEXT))		return ATLAS;
		else																	return IMAGE;
	}

	inline static public function getAssetPath(key:String, type:AssetType = IMAGE):String {
		return switch (type) {
			case SOUND: soundFolder(key);
			default: 	png(key);
		}
	}
}

enum abstract PackerType(Int) from Int to Int {
	var IMAGE = 0;
	var SPARROW = 1;
	var SHEETPACKER = 2;
	var JSON = 3;
	var ATLAS = 4;
}