package funkin.util;

import moonchart.formats.fnf.FNFMaru;
import openfl.media.Sound;
import haxe.io.Path;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if sys
import sys.FileSystem;
#end

class Paths
{
	inline public static var SOUND_EXT = "ogg";
	public static var currentLevel(default, set):String = "";

	public static inline function set_currentLevel(value:String)
		return currentLevel = value.toLowerCase();

	public static function getPath(file:String, type:AssetType, ?library:String, allMods:Bool = false, mods:Bool = true, ?level:String):String
	{
		final hasLevel = currentLevel.length > 0;
		
		#if MODS_ALLOWED
		if (mods) {
			var modFolder:String = ModdingUtil.curModFolder != null ? ModdingUtil.curModFolder + "/" : "";

			var modFile:String = file;
			if (library != null) if (library.length > 0)
				modFile = '$library/$modFile';
			
			final modFolderPath:String = getModPath(modFolder + modFile);
			if (exists(modFolderPath, type))
				return modFolderPath;

			if (hasLevel) {
				final levelPath = getLibraryPathForce(modFile, 'weeks', currentLevel, 'mods/$modFolder');
				if (exists(levelPath, type))
					return levelPath;
			}
			
			if (allMods) {
				ModdingUtil.modsList.fastForEach((mod, i) -> {
					final folder:String = mod.folder;
					final modPath:String = getModPath('$folder/$modFile');
					if (ModdingUtil.activeMods.get(folder)) if (exists(modPath, type))
						return modPath;
				});
			}
			
			ModdingUtil.globalMods.fastForEach((mod, i) -> {
				final modPath:String = getModPath(mod.folder + "/" + modFile);
				if (exists(modPath, type))
					return modPath;
			});
			
			final modPath = getModPath(modFile);
			if (exists(modPath, type))
				return modPath;
		}
		#end

		if (library != null)
		{
			if (level != null)
			{
				final levelPath = getLibraryPathForce(file, library, level);
				if (exists(levelPath, type))
					return levelPath;
			}
			else
			{
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

		return getAssetsPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload", ?level:String, root:String = "assets"):String
	{
		return (library == "preload" || library == "default") ? getAssetsPath(file) : getLibraryPathForce(file, library, level, root);
	}

	inline static public function getLibraryPathForce(file:String, library:String, ?level:String, root:String = "assets"):String
	{
		return (level != null) ? '$root/$library/$level/$file' : '$root/$library/$file';
	}

	inline static public function getModPath(file:String):String
	{
		return 'mods/$file';
	}

	inline static function getAssetsPath(file:String):String
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

	inline static public function music(key:String, ?library:String, ?level:String, ?stream:Bool):Sound {
		var musicPath = musicFolder(key, library, level);
		return AssetManager.cacheSoundPath(musicPath, false, null, stream);
	}

	/*
	 * SONGS
	**/

	inline static public function songAudioAssetPath(song:String, asset:String, ?globalAsset:Bool):String {
		var songKey = FNFMaru.formatTitle(song) + '/audio/$asset';

		var diffPath = getPath('$songKey-${PlayState.curDifficulty}.$SOUND_EXT', MUSIC, 'songs', globalAsset);
		if (exists(diffPath, MUSIC)) return diffPath;
		
		return getPath('$songKey.$SOUND_EXT', MUSIC, 'songs', globalAsset);
	}

	inline static public function voicesPath(song:String, ?globalAsset:Bool):String {
		return songAudioAssetPath(song, "Voices", globalAsset);
	}

	inline static public function voices(song:String, ?globalAsset:Bool, ?stream:Bool):Sound {
		var voicesPath:String = voicesPath(song, globalAsset);
		return AssetManager.cacheSoundPath(voicesPath, false, null, stream);
	}

	inline static public function instPath(song:String, ?globalAsset:Bool):String {
		return songAudioAssetPath(song, "Inst", globalAsset);
	}

	inline static public function inst(song:String, ?globalAsset:Bool, ?stream:Bool):Sound {
		var instPath:String = instPath(song, globalAsset);
		return AssetManager.cacheSoundPath(instPath, false, null, stream);
	}

	inline static public function chartFolder(title:String, ?allowMods:Bool):String
	{
		return getPath(title + "/charts", BINARY, "songs", false, allowMods);
	}

	/*inline static public function chart(song:String, diff:String, ext:String = 'json'):String {
		if (!ext.startsWith('/'))
			ext = '.$ext';

		return getPath(Song.formatSongFolder(song) + '/charts/${diff.toLowerCase()}$ext', TEXT, 'songs');
	}

	inline static public function songMeta(song:String) {
		return getPath(Song.formatSongFolder(song) + '/charts/songMeta.json', TEXT, 'songs');
	}*/

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
		#if sys
		return FileSystem.exists(file);
		#else
		return OpenFlAssets.exists(file, type);
		#end
	}

	public static inline function getPathMod(path:String):String {
		return path.split('/')[1];
	}

	public static inline function getPathFile(path:String):String {
		return path.split('/').pop().split('.')[0];
	}

	// Gotta do this to make sure FlxAtlasFrames doesnt lose his shit when the graphic is smaller than the data
	@:noCompletion
	public static function getFrames(image:LodGraphic, getter:()->FlxAtlasFrames) {
		image.setSize(image.lodWidth, image.lodHeight);
		var frames = getter();
		image.setSize(image.bitmap.width, image.bitmap.height);
		return frames;
	}

	static public function getSparrowAtlas(key:String, ?library:String, ?useTexture:Bool, ?lodLevel:LodLevel):FlxAtlasFrames
	{
		var image = image(key, library, false, useTexture, lodLevel);
		var frames = FlxAtlasFrames.findFrame(image);
		if (frames != null)
			return frames;
		
		var xml = CoolUtil.getFileContent(file('images/$key.xml', library));
		return __checkLodFrames(getFrames(image, () -> return FlxAtlasFrames.fromSparrow(image, xml)));
	}

	static public function getSpriteSheetAtlas(key:String, ?library:String, ?useTexture:Bool, ?lodLevel:LodLevel):FlxAtlasFrames
	{
		var image = image(key, library, false, useTexture, lodLevel);
		var frames = FlxAtlasFrames.findFrame(image);
		if (frames != null)
			return frames;

		var txt = CoolUtil.getFileContent(file('images/$key.txt', library));
		return __checkLodFrames(getFrames(image, () -> return FlxAtlasFrames.fromSpriteSheetPacker(image, txt)));
	}

	static public function getAsepriteAtlas(key:String, ?library:String, ?useTexture:Bool, ?lodLevel:LodLevel):FlxAtlasFrames
	{
		var image = image(key, library, false, useTexture, lodLevel);
		var frames = FlxAtlasFrames.findFrame(image);
		if (frames != null)
			return frames;

		var json = CoolUtil.getFileContent(file('images/$key.json', library));
		return __checkLodFrames(getFrames(image, () -> return JsonUtil.getAsepritePacker(image, json)));
	}

	@:noCompletion
	public static function __checkLodFrames(frames:FlxAtlasFrames):FlxAtlasFrames {
		var parent:LodGraphic = cast(frames.parent, LodGraphic);
		if (parent.lodLevel == 0 || parent.parsedChildren)
			return frames;

		var lodScale = parent.lodScale;
		frames.frames.fastForEach((frame, i) -> {
			var rect = frame.frame;
			rect.x = rect.x / lodScale;
			rect.y = rect.y / lodScale;
			rect.width = rect.width / lodScale;
			rect.height = rect.height / lodScale;
			
			var offset = frame.offset;
			offset.x /= lodScale;
			offset.y /= lodScale;
		});

		parent.parsedChildren = true;

		return frames;
	}

	public static function quickFileList(folder:String, extension:String, fullPath:Bool)
	{
		var assetType:AssetType = switch (extension) {
			case "png": IMAGE;
			case "ogg": MUSIC;
			case _: TEXT;
		}

		var assetFiles = getFileList(assetType, fullPath, extension, folder);
		var modFiles = getModFileList(folder, extension, fullPath);

		var list = assetFiles.concat(modFiles);
		return CoolUtil.removeDuplicates(list);
	}

	public static function findSort(dir:String):Array<String>
	{
		if (dir.endsWith("/"))
			dir = dir.substring(0, dir.length - 1);

		var folder = dir.split("/").pop();

		for (i in ['listSort', '$folder-sort']) {
			var sort = CoolUtil.getFileContent('$dir/$i.txt');
			if (sort.length > 0)
				return sort.split(",");
		}

		// Folder has no sorts :p
		return [];
	}

	public static function setupSort(folder:String, ?extension:String, fullPath:Bool = true)
	{
		var sort:Array<String> = findSort(folder);
		sort.fastForEach((file, i) -> {
			var prefix = fullPath ? '$folder/' : '';
			var suffix = ((extension == null) || !fullPath) ? "" : '.$extension';
			sort.unsafeSet(i, prefix + file + suffix);
		});
		return sort;
	}

	static public function getFileList(type:AssetType = IMAGE, fullPath:Bool = true, extension:String = "", folder:String = ""):Array<String>
	{
		if (folder.length > 0) {
			if (!folder.endsWith("/"))
				folder = '$folder/';

			if (!folder.startsWith('assets/'))
				folder =  folder.startsWith('/') ? 'assets$folder' : 'assets/$folder';
		}

		var list:Array<String> = [];
		
		for (file in OpenFlAssets.list(type))
		{
			if (!file.startsWith('assets/'))
				continue;

			var validExtension:Bool = (extension.length == 0 || file.endsWith(extension));
			var validFolder:Bool = (folder.length == 0 || file.contains(folder));

			if (validExtension) if (validFolder) {
				list.push(fullPath ? file : file.split('/').pop().split('.')[0]);
			}
		}
		
		var sort = setupSort(folder, extension, fullPath);
		var sortedList = CoolUtil.customSort(list, sort);

		return sortedList;
	}

	public static function getModFileList(folder:String, ?extension:String, fullPath:Bool = true, global:Bool = true, curFolder:Bool = true, allFolders:Bool = false):Array<String> {
		#if MODS_ALLOWED
		var fileList:Array<String> = [];
		var pushFile = (folder:String) ->
		{
			if (FileSystem.exists(folder))
			{
				var folderList:Array<String> = [];
				FileSystem.readDirectory(folder).fastForEach((path, i) -> {
					if (extension == null || path.endsWith(extension))
					{
						var path = fullPath ? '$folder/$path' : Path.withoutExtension(path);
						folderList.push(path);
					}
				});

				var sort = setupSort(folder, extension, fullPath);
				var sortedList = CoolUtil.customSort(folderList, sort);
				fileList = fileList.concat(sortedList);
			}
		};

		if (global)
			pushFile(getModPath(folder));

		if (curFolder)
			pushFile(getModPath(ModdingUtil.curModFolder + '/$folder'));

		if (allFolders) {
			for (mod => active in ModdingUtil.activeMods) {
				if (active)
					pushFile(getModPath('$mod/$folder'));
			}
		}

		return fileList;
		#else
		return [];
		#end
	}

	static public function getPackerType(key:String, ?library:String):PackerType {
		if 		(exists(file('images/$key.xml', library), TEXT))				return SPARROW;
		else if (exists(file('images/$key.txt', library), TEXT))				return SHEETPACKER;
		else if (exists(file('images/$key.json', library), TEXT))				return JSON;
		else if (exists(file('images/$key/Animation.json', library), TEXT))		return ATLAS;
		else																	return IMAGE;
	}

	inline static public function getAssetPath(key:String, type:AssetType = IMAGE):String {
		return switch (type) {
			case SOUND: 	soundFolder(key);
			case IMAGE | _:	png(key);
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