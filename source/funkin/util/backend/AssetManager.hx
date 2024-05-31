package funkin.util.backend;

import lime.media.AudioBuffer;
import openfl.media.Sound;
import openfl.display3D.textures.TextureBase;
import flixel.util.typeLimit.OneOfTwo;
import openfl.display.BitmapData;
import lime.utils.Assets as LimeAssets;

typedef AssetClass = OneOfTwo<LodGraphic, Sound>;

class Asset
{
	public var key:String;
	public var asset(default, null):AssetClass;
	public var isSoundAsset(default, null):Bool;
	public var isGraphicAsset(default, null):Bool;
	public var onDispose:()->Void;

	public function new() {}

	public static inline function fromAsset(asset:AssetClass, key:String):Asset {
		var asset = new Asset().setAsset(asset);
		asset.key = key;
		return asset;
	}

	public inline function setAsset(asset:AssetClass):Asset {
		isGraphicAsset = asset is LodGraphic;
		isSoundAsset = !isGraphicAsset;
		this.asset = asset;

		if (isGraphicAsset) {
			var graphic = cast(asset, LodGraphic);
			graphic.persist = true;
			graphic.destroyOnNoUse = false;
		}

		return this;
	}

	public inline function dispose():Void {
		if (asset != null) {
			isGraphicAsset ? __disposeGraphic(asset) : __disposeSound(asset);
			asset = null;

			if (onDispose != null)
				onDispose();
		}
	}

	public static inline function __disposeImage(bitmap:BitmapData) @:privateAccess {
		if (bitmap.image != null)
		{
			if (bitmap.image.data != null)
				bitmap.image.data = null;
				
			if (bitmap.image.buffer != null) {
				bitmap.image.buffer.data = null;
				bitmap.image.buffer = null;							
			}

			bitmap.image = null;
		}

		bitmap.__vertexBuffer = null;
		bitmap.__framebuffer = null;
		bitmap.__framebufferContext = null;

		bitmap.__renderTransform = null;
		bitmap.__worldTransform = null;
		bitmap.__worldColorTransform = null;
	}

	inline function __disposeBitmap(bitmap:BitmapData, disposeTexture:Bool = true):BitmapData @:privateAccess {
		if (disposeTexture)
			__disposeTexture(bitmap.__texture);
		
		__disposeImage(bitmap);
		bitmap.dispose();
		OpenFlAssets.cache.removeBitmapData(key);

		return null;
	}

	inline function __disposeTexture(texture:TextureBase):TextureBase @:privateAccess {
		if (texture != null)
			texture.dispose();

		return null;
	}

	inline function __disposeGraphic(graphic:LodGraphic):LodGraphic {
		__disposeBitmap(graphic.bitmap);
		graphic.destroy();
		
		return null;
	}

	function __disposeSound(sound:Sound):Sound @:privateAccess
	{
		#if !web
		var buffer = sound.__buffer;
		if (buffer != null)
		{
			if (buffer.data != null)
			{
				buffer.data.buffer = null;
				buffer.data = null;
			}
		}
		#end

		sound.close();

		return null;
	}
}

class LodGraphic extends FlxGraphic
{
	private var _lodGenerated:Bool = false;
	public var parsedChildren:Bool = false;
	
	public var lodScale(default, null):Float = 1.0;
	public var lodLevel(default, null):Int = 0;
	
	public function generateLod(level:Int = 0)
	{
		lodLevel = level;
		if (_lodGenerated || level <= 0 || !bitmap.readable)
			return;
		
		lodScale = 1 << level;
		var scale = 1 / lodScale;

        var matrix = CoolUtil.resetMatrix();
		matrix.scale(scale, scale);

		var newWidth:Int = bitmap.width >> level;
		var newHeight:Int = bitmap.height >> level;

        var lodBitmap = new BitmapData(newWidth, newHeight, true, 0x00000000);
		lodBitmap.draw(bitmap, matrix, null, null, null, true);

		bitmap.dispose();
		bitmap = lodBitmap;

		imageFrame.frame.sourceSize *= lodScale;
	}

	public var lodWidth(default, null):Int;
	public var lodHeight(default, null):Int;

	public inline function setSize(width:Int, height:Int):Void {
		this.width = width;
		this.height = height;
	}

	override function set_bitmap(value:BitmapData):BitmapData
	{
		if (value != null)
		{
			bitmap = value;
			setSize(bitmap.width, bitmap.height);
			lodWidth = bitmap.width << lodLevel;
			lodHeight = bitmap.height << lodLevel;
		}

		return value;
	}
}

enum abstract LodLevel(Int) from Int to Int {
	var DEFAULT = -1;
	var HIGH = 0;
	var MEDIUM = 1;
	var LOW = 2;
	var RUDY = 3;

	public static inline function resolve(useLod:Bool):Int {
		return useLod ? DEFAULT : HIGH;
	}

	public static function fromString(value:String):LodLevel {
		return (switch(value) {
			case "high": HIGH;
			case "medium": MEDIUM;
			case "low": LOW;
			case "rudy": RUDY;
			default: HIGH;
		});
	}

	public static function toString(value:LodLevel):String {
		return (switch(value) {
			case HIGH: "high";
			case MEDIUM: "medium";
			case LOW: "low";
			case RUDY: "rudy";
			default: "high";
		});
	}
}

typedef LoadImage = {
    var path:String;
    var lod:LodLevel;
}

class AssetManager
{
	public static var assetsMap:Map<String, Asset> = [];
	public static var staticAssets:Array<String> = [];
	public static var tempAssets:Array<String> = [];

	public static inline function clearAllCache(?clearGraphics:Bool, ?clearSounds:Bool):Void
	{
		#if web
		AlphabetFont.cachedAlphabets.clear();
		NoteUtil.skinSpriteMap.clear();
		#else
		clearStaticCache(false, clearGraphics, clearSounds);
		clearTempCache(false, clearGraphics, clearSounds);
		#end

		CoolUtil.gc(true);
	}

	public static inline function clearStaticCache(runGc:Bool = true, clearGraphics:Bool = true, clearSounds:Bool = true):Void {
		__clearCacheFromKeys(staticAssets, clearGraphics, clearSounds);
		if (runGc) CoolUtil.gc(true);
	}

	public static inline function clearTempCache(runGc:Bool = true, clearGraphics:Bool = true, clearSounds:Bool = true):Void {
		__clearCacheFromKeys(tempAssets, clearGraphics, clearSounds);
		if (runGc) CoolUtil.gc(true);
	}

	/*
	 * GRAPHIC CACHE
	 */

	public static var gpuTextures:Bool = #if TEXTURES_OFF false; #else true; #end
	public static var lodQuality:LodLevel = HIGH;
	public static function setLodQuality(level:String):LodLevel {
		return lodQuality = LodLevel.fromString(level);
	}

	public static function cacheGraphicPath(path:String, staticAsset:Bool = false, ?useTexture:Bool, lodLevel:LodLevel = DEFAULT, ?key:String):LodGraphic
	{
		if (key == null)
			key = path;

		if (lodLevel == DEFAULT)
			lodLevel = lodQuality;
		
		var asset = getAsset(key); // Check if asset is already cached
		if (asset != null) {
			final graphic:LodGraphic = asset.asset;
			if (graphic.lodLevel == lodLevel) // TODO: May need some disposing if this is false
				return graphic;
		}

		var bitmap = __getFileBitmap(path);
		
		return __cacheFromBitmap(key, bitmap, staticAsset, lodLevel, useTexture);
	}

	@:noCompletion
	private static inline function __cacheFromBitmap(key:String, bitmap:BitmapData, staticAsset:Bool, lodLevel:LodLevel = DEFAULT, ?useTexture:Bool) {
		@:privateAccess
		var graphic = new LodGraphic(null, bitmap);

		if (lodLevel == DEFAULT)
			lodLevel = lodQuality;
		
		if (lodLevel != HIGH)
			graphic.generateLod(lodLevel);

		if (useTexture == null)
			useTexture = gpuTextures;

		if (gpuTextures)
			graphic = cast uploadGraphicTexture(graphic);
		
		var asset = Asset.fromAsset(graphic, key);
		setAsset(key, asset, staticAsset);

		// TODO: Maybe its the shader pool thing?? i have no idea
		//#if (lime_cffi && lime_cairo && !macro)
		//lime.graphics.cairo.CairoPattern.createForSurface(graphic.bitmap.getSurface());
		//#end

		return graphic;
	}

	public static function uploadGraphicTexture(graphic:FlxGraphic):FlxGraphic
	{
		var bitmap = graphic.bitmap;

		if (bitmap.readable)
		{
			var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGR_PACKED, true);
			texture.uploadFromBitmapData(bitmap);

			@:privateAccess
			{
				// Dispose the previous bitmap data
				Asset.__disposeImage(bitmap);

				// Load the texture
				bitmap.readable = false;
				bitmap.__texture = texture;
				bitmap.__textureContext = texture.__textureContext;
			}

			graphic.bitmap = bitmap;
		}

		return graphic;
	}

	public static inline function getAssetGraphic(key:String):LodGraphic
	{
		return __nullAssetGet(key);
	}

	public static function getFileBitmap(path:String, ?staticAsset:Bool):BitmapData 
	{
		return cacheGraphicPath(path, staticAsset, false).bitmap;
	}

	@:noCompletion
	static inline function __getFileBitmap(path:String, cache:Bool = true):BitmapData {
		#if desktop
		if (!path.startsWith('assets'))
			return BitmapData.fromFile(path);
		#end

		return OpenFlAssets.getBitmapData(path, cache);
	}
	
	/*
	 * SOUND CACHE
	 */

	public static function cacheSoundPath(path:String, staticAsset:Bool = false, ?key:String):Sound
	{
		if (key == null)
			key = path;
		
		var asset = getAsset(key); // Check if asset is already cached
		if (asset != null)
			return asset.asset;

		var sound = __getFileSound(path);

		var asset = Asset.fromAsset(sound, key);
		setAsset(key, asset, staticAsset);

		return sound;
	}

	public static inline function getAssetSound(key:String):Sound
	{
		return __nullAssetGet(key);
	}

	public static function getFileSound(path:String, ?staticAsset:Bool):Sound 
	{
		return cacheSoundPath(path, staticAsset);
	}

	@:noCompletion
	static inline function __streamSound(path:String):Sound {
		var sound:Sound = null;

        #if (desktop && lime_vorbis)
        var vorbis = lime.media.vorbis.VorbisFile.fromFile(path);
        var buffer = AudioBuffer.fromVorbisFile(vorbis);
        if (buffer != null)
            sound = Sound.fromAudioBuffer(buffer);
        #end

		if (sound == null)
			sound = __getFileSound(path);

		return sound;
	}

	@:noCompletion
	static inline function __getFileSound(path:String):Sound {
		#if desktop
		if (!path.startsWith('assets'))
			return Sound.fromFile(path);
		#end

		return getLimeAssetsSound(path);
	}

	public static inline function getLimeAssetsSound(id:String):Sound {
		var buffer = LimeAssets.getAudioBuffer(id, false);
		if (buffer != null)
			return Sound.fromAudioBuffer(buffer);

        return null;
    }
	
	
	// Anal Sex

	public static inline function setAsset(key:String, asset:Asset, staticAsset:Bool):Void
	{
		assetsMap.set(key, asset);
		staticAsset ? staticAssets.push(key) : tempAssets.push(key);
	}

	public static inline function getAsset(key:String):Asset
	{
		return assetsMap.get(key);
	}

	public static inline function existsAsset(key:String):Bool
	{
		return assetsMap.exists(key);
	}

	public static function disposeAsset(key:String):Bool {
		if (!existsAsset(key))
			return false;

		var asset = getAsset(key);
		asset.dispose();
		assetsMap.remove(key);

		if (tempAssets.contains(key)) tempAssets.removeAt(tempAssets.indexOf(key));
		else if (staticAssets.contains(key)) staticAssets.removeAt(staticAssets.indexOf(key));

		return true;
	}

	@:noCompletion
	inline static function __nullAssetGet(key:String):AssetClass
	{
		return existsAsset(key) ? getAsset(key).asset : null;
	}

	@:noCompletion
	inline static function __clearCacheFromKeys(keys:Array<String>, clearGraphics:Bool, clearSounds:Bool):Array<String>
	{
		#if !web // Temp slap-on fix till i figure out the problem with web disposing
		var removeKeys:Array<String> = [];
		
		keys.fastForEach((key, i) -> {
			var asset = assetsMap.get(key);
			if (asset != null) {
				var dispose = (asset.isGraphicAsset && clearGraphics) || (asset.isSoundAsset && clearSounds);
				if (dispose) {
					removeKeys.push(key);
					asset.dispose();
					assetsMap.remove(key);
				}
			}
		});

		removeKeys.fastForEach((key, i) -> {
			keys.remove(key);
		});
		#end

		return keys;
	}

	@:noCompletion
	inline static function __clearCacheFromMod(keys:Array<String>, mod:String, clearGraphics:Bool, clearSounds:Bool):Array<String> {
		var removeKeys:Array<String> = [];

		keys.fastForEach((key, i) -> {
			var keyMod = key.split("/")[1];
			if (keyMod == mod) {
				var asset = assetsMap.get(key);
				if (asset != null) {
					var dispose = (asset.isGraphicAsset && clearGraphics) || (asset.isSoundAsset && clearSounds);
					if (dispose) {
						removeKeys.push(key);
						asset.dispose();
						assetsMap.remove(key);
					}
				}
			}
		});

		removeKeys.fastForEach((key, i) -> {
			keys.remove(key);
		});

		return keys;
	}
}