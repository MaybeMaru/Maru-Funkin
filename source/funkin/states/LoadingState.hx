package funkin.states;

import openfl.media.Sound;
import openfl.display.BitmapData;

@:access(funkin.util.backend.AssetManager)
class LoadingState extends MusicBeatState
{
    public var onStart:()->Void;
    public var onComplete:()->Void;
    
    var imageAssets:Array<LoadImage> = [];
    var soundAssets:Array<String> = [];

    var imagesCached:Array<Bool>;
	var imageCache:Map<String, {bitmap:BitmapData, lod:LodLevel}> = [];
    var soundCache:Map<String, Sound> = [];

    var streamSounds:Bool = false;
    var loading:Bool = false;

    public function new() {
        super(false);
        streamSounds = Preferences.getPref('song-stream') ?? false;
    }

    override function create() {
        super.create();
        startTime = openfl.Lib.getTimer();
        
        #if !desktop // Force loading on targets without threads
        soundAssets.fastForEach((sound, i) -> {
            soundCache.set(sound, AssetManager.__getFileSound(sound));
        });
        
        imageAssets.fastForEach((image, i) -> {
            imageCache.set(image.path, {
                bitmap: AssetManager.__getFileBitmap(image.path),
                lod: image.lod
            });
        });

        imageAssets.clear();
        soundAssets.clear();
        #end
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(loading) if (imagesCached.indexOf(false) == -1) if (soundAssets.length <= 0) {
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
        
        this.imageAssets = imageAssets;
        this.soundAssets = soundAssets;

        #if desktop
        CoolUtil.enableGc(false);

        var threads:Int = FunkThread.MAX_THREADS;
        threads -= soundAssets.length;

        final cacheSound = (sound:String, array:Array<String>) -> {
            if (!soundCache.exists(sound)) {
                soundCache.set(sound, streamSounds ?
                    AssetManager.__streamSound(sound) :
                    AssetManager.__getFileSound(sound)
                );
            }
    
            array.remove(sound);
        }

        // Song audio get each their own thread
        this.soundAssets.fastForEach((sound, i) -> {
            FunkThread.run(() -> cacheSound(sound, this.soundAssets));
        });

        var imagesLength:Int = imageAssets.length;
        var imagesQueued:Array<Bool> = [];
        imagesCached = [];
        
        for (i in 0...imagesLength) {
            imagesQueued[i] = false;
            imagesCached[i] = false;
        }

        //var curThread = 0;

        final cacheImages = () -> {
            
            //curThread++;
            //var thread = curThread;

            while (imagesCached.indexOf(false) != -1) {
                var index = imagesQueued.indexOf(false);
                if (index == -1) break;
                
                imagesQueued.unsafeSet(index, true);

                var image = imageAssets[index];
                var path = image.path;
                imageCache.set(path, {
                    bitmap: AssetManager.__getFileBitmap(path),
                    lod: image.lod
                });
    
                imagesCached.unsafeSet(index, true);

                //trace(index, path, thread);
            }
        }

        // Load the rest of the images with the leftover threads
        for (_ in 0...threads) {
            FunkThread.run(cacheImages);
            Sys.sleep(0.004); // Fire thread with a bit of delay for safety reasons
        }
        #end
    }

    function completeAsyncLoad():Void
    {
        if (onStart != null)
            onStart();

        for (key => image in imageCache) {
			AssetManager.__cacheFromBitmap(key, image.bitmap, false, image.lod);
		}

		for (key => sound in soundCache) {
			AssetManager.setAsset(key, Asset.fromAsset(sound, key), false);
		}

        trace("finished loading!", (openfl.Lib.getTimer() - startTime) / 1000);

        if (onComplete != null)
            onComplete();
    }
}