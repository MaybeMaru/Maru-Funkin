package funkin.util;

import flash.media.Sound;
import flixel.system.FlxAssets.FlxSoundAsset;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
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

	public static function getPath(file:String, type:AssetType, library:Null<String>, forceFolder:Bool = false, takeMod:Bool = true):String {
		#if desktop
		if (takeMod) {
			var modLib:String = '';
			if (library != null)
				modLib = '$library/';
	
			var modFolderPath = getModPath('${ModdingUtil.curModFolder}/$modLib$file');
			if (FileSystem.exists(modFolderPath))
				return modFolderPath;
			
			if (forceFolder) {
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

		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null) {
			var levelPath = getLibraryPathForce(file, 'weeks',currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		var levelPath = getLibraryPathForce(file, "shared");
		if (OpenFlAssets.exists(levelPath, type))
			return levelPath;

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

	inline static public function txt(key:String, ?library:String):String
	{
		return getPath('data/$key.txt', TEXT, library);
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

	static public function sound(key:String, ?library:String):FlxSoundAsset
	{
		var soundPath:String = getPath('sounds/$key.$SOUND_EXT', SOUND, library);
		var soundFile:FlxSoundAsset = getSound(soundPath);
		return soundFile;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):FlxSoundAsset
	{
		return sound('$key${FlxG.random.int(min, max)}', library);
	}

	inline static public function music(key:String, ?library:String):FlxSoundAsset
	{
		var musicPath:String = getPath('music/$key.$SOUND_EXT', MUSIC, library);
		var soundFile:FlxSoundAsset = getSound(musicPath);
		return soundFile;
	}

	inline static public function voices(song:String, forcePath:Bool = false):FlxSoundAsset
	{
		var voicesPath:String = getPath('${Song.formatSongFolder(song)}/audio/Voices.$SOUND_EXT', MUSIC, 'songs');
		if (forcePath) return voicesPath;

		var soundFile:FlxSoundAsset = getSound(voicesPath);
		return soundFile;
	}

	inline static public function inst(song:String):FlxSoundAsset
	{
		var instPath:String = getPath('${Song.formatSongFolder(song)}/audio/Inst.$SOUND_EXT', MUSIC, 'songs');
		var soundFile:FlxSoundAsset = getSound(instPath);
		return soundFile;
	}

	inline static public function chart(song:String, diff:String, ext:String = 'json'):String
	{
		return getPath('${Song.formatSongFolder(song)}/charts/${diff.toLowerCase()}.$ext', TEXT, 'songs');
	}

	inline static public function image(key:String, ?library:String, forcePath:Bool = false, getGlobal:Bool = false):FlxGraphicAsset
	{
		var imagePath:String = getPath('images/$key.png', IMAGE, library, getGlobal);
		return forcePath ? imagePath : getImage(imagePath);
	}

	inline static public function atlas(key:String, ?library:String):String
	{
		var atlasJson:String = file('images/$key/Animation.json', library);
		return atlasJson.split('/Animation.json')[0];
	}

	inline static public function font(key:String, ?library:String):String
	{
		return getPath('fonts/$key.ttf', FONT, library);
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

	inline static public function getFileMod(dir:String):Array<String> {
		var dirParts = dir.split('/');
		return [dirParts[1], dirParts[dirParts.length-1].split('.')[0]];
		//	Returns [file Mod, file Name]
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, gpu:Bool = true):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key, library, gpu), CoolUtil.getFileContent(file('images/$key.xml', library)));
	}

	inline static public function getPackerAtlas(key:String, ?library:String, gpu:Bool = true):FlxAtlasFrames {
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library, gpu), CoolUtil.getFileContent(file('images/$key.txt', library)));
	}

	inline static public function getAsepriteAtlas(key:String, ?library:String, gpu:Bool = true):FlxAtlasFrames {
		return JsonUtil.getAsepritePacker(key, library, gpu);
	}

	inline static public function getAnimateAtlas(key:String, ?library:String):FlxAtlasFrames {
		return flxanimate.frames.FlxAnimateFrames.fromTextureAtlas(atlas(key, library));
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

	inline static public function getImage(path:String):FlxGraphicAsset {
		var returnThing:FlxGraphicAsset = path;
		if (Preloader.existsBitmap(path)) returnThing = Preloader.getBitmap(path);
		else if (exists(path, IMAGE)) {
			var bitmap:BitmapData = getBitmapData(path);//#if desktop BitmapData.fromFile(removeAssetLib(path)); #else OpenFlAssets.getBitmapData(path, false); #end
			Preloader.addFromBitmap(bitmap, path);
			returnThing = Preloader.getBitmap(path);
		}
		return returnThing;
	}

	inline static public function getBitmapData(path:String):BitmapData {
		#if desktop return BitmapData.fromFile(removeAssetLib(path));
		#else 		return OpenFlAssets.getBitmapData(path, false); #end
	}

	inline static public function getSound(path:String):FlxSoundAsset {
		var returnThing:FlxSoundAsset = path;
		#if desktop
		if(FileSystem.exists(path))
			returnThing = Sound.fromFile(path);
		#end
		return returnThing;
	}

	inline static public function getPackerType(key:String, ?library:String):String {
		if 		(exists(file('images/$key.xml', library), TEXT))				return 'sparrow';
		else if (exists(file('images/$key.txt', library), TEXT))				return 'sheetpacker';
		else if (exists(file('images/$key.json', library), TEXT))				return 'json';
		else if (exists(file('images/$key/Animation.json', library), TEXT))		return 'atlas';
		else																	return 'image';
	}
}