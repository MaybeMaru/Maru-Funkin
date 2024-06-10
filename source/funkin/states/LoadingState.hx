package funkin.states;

import openfl.media.Sound;
import openfl.display.BitmapData;

typedef UncachedAsset = {
    var isImage:Bool;
    var ?key:String;
    var ?lod:LodLevel;
}

typedef CachedAsset = {
    var ?bitmap:BitmapData;
    var ?lod:LodLevel;
    var ?sound:Sound;
}

@:access(funkin.util.backend.AssetManager)
class LoadingState extends MusicBeatState
{
    public var onStart:()->Void;
    public var onComplete:()->Void;

    var uncachedAssets:Array<UncachedAsset> = [];
    var assetsCached:Array<Bool> = [];
    var assetCache:Map<String, CachedAsset> = [];

    var streamSounds:Bool = false;
    var loading:Bool = false;

    public function new() {
        super(false);
        streamSounds = Preferences.getPref('song-stream') ?? false;
    }

    inline function cacheAsset(asset:UncachedAsset) {
        var key = asset.key;
        if (asset.isImage) {
            assetCache.set(key, {
                bitmap: AssetManager.__getFileBitmap(key),
                lod: asset.lod
            });
        }
        else {
            var sound:Sound = streamSounds ? AssetManager.__streamSound(key) : AssetManager.__getFileSound(key);
            assetCache.set(key, {sound: sound});
        }
    }

    override function create() {
        super.create();
        startTime = openfl.Lib.getTimer();
        
        #if !desktop // Force loading on targets without threads
        uncachedAssets.fastForEach((asset, i) -> cacheAsset(asset));
        #end
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (loading) if (assetsCached.indexOf(false) == -1) {
            completeAsyncLoad();
            loading = false;
        }
    }

    public function setupPlay(stage:StageJson, characters:Array<String>, song:String):Void
    {
        var imageAssets:Array<LoadImage> = Stage.getStageAssets(stage);
        var soundAssets:Array<String> = [];

        characters.push(Character.getCharData(characters[0]).gameOverChar);

        CoolUtil.removeDuplicates(characters).fastForEach((char, i) -> {
            var json = Character.getCharData(char);
            var path:String = json.imagePath;
            if (!path.startsWith('characters/'))
                path = 'characters/$path';

            imageAssets.push({
                path: Paths.png(path),
                lod: LodLevel.resolve(json.allowLod)
            });
        });

        var instPath = Paths.instPath(song);
        var voicesPath = Paths.voicesPath(song);

        soundAssets.push(instPath);
        if (Paths.exists(voicesPath, MUSIC))
            soundAssets.push(voicesPath);

        startAsyncLoad(imageAssets, soundAssets);
    }

    var startTime:Float = -1;

    public function startAsyncLoad(imageAssets:Array<LoadImage>, soundAssets:Array<String>):Void
    {
        loading = true;

        // Making sure theres no repeated assets
        var addedAssets:Array<String> = [];

        uncachedAssets.clear();
        imageAssets.fastForEach((image, i) -> {
            if (addedAssets.indexOf(image.path) == -1) {
                uncachedAssets.push({isImage:true, key: image.path, lod: image.lod});
                addedAssets.push(image.path);
            }
        });

        if (streamSounds)
            soundAssets.clear();

        soundAssets.fastForEach((sound, i) -> {
            if (addedAssets.indexOf(sound) == -1) {
                uncachedAssets.push({isImage:false, key: sound});
                addedAssets.push(sound);
            }
        });

        #if desktop
        CoolUtil.enableGc(false);

        var assetsQueued:Array<Bool> = [];
        assetsCached.clear();
        
        for (i in 0...uncachedAssets.length) {
            assetsQueued.push(false);
            assetsCached.push(false);
        }

        //var curThread = 0;

        final cacheAssets = () -> {

            //curThread++;
            //var thread = curThread;

            while (assetsCached.indexOf(false) != -1) {
                var index:Int = assetsQueued.indexOf(false);
                if (index == -1) break;

                assetsQueued.unsafeSet(index, true);

                cacheAsset(uncachedAssets[index]);

                assetsCached.unsafeSet(index, true);
                //trace(index, key, thread);
                //trace(assetsCached, assetsQueued);
            }
        }

        for (i in 0...FunkThread.MAX_THREADS) {
            FunkThread.run(cacheAssets);
            Sys.sleep(0.01); // Fire thread with a bit of delay for safety reasons
        }
        #end
    }

    function completeAsyncLoad():Void
    {
        CoolUtil.enableGc(true);
        uncachedAssets.clear();

        if (onStart != null)
            onStart();

        //trace(assetCache);
        for (key in assetCache.keys()) {
            var asset = assetCache.get(key);
            if (asset == null) continue;
            
            if (asset.bitmap != null)
            {
                AssetManager.__cacheFromBitmap(key, asset.bitmap, false, asset.lod);
            }
            else
            {
                AssetManager.setAsset(key, Asset.fromAsset(asset.sound, key), false);
            }
        }

        trace("finished loading!", (openfl.Lib.getTimer() - startTime) / 1000);

        if (onComplete != null)
            onComplete();
    }
}