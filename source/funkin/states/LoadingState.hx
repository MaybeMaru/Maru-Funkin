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

    var imageQueue:Map<String, Bool> = [];
	var imageCache:Map<String, {bitmap:BitmapData, lod:LodLevel}> = [];
    var soundCache:Map<String, Sound> = [];

    var streamSounds:Bool = false;
    var loading:Bool = false;

    public function new() {
        super(false);
        streamSounds = Preferences.getPref('song-stream') ?? false;
    }

    //override function create() {
    //    super.create();
    //
    //      add(new FlxSprite().makeGraphic(600, 600, FlxColor.RED));
    //}

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (startTime <= -1)
            startTime = openfl.Lib.getTimer();
        
        if(loading) if (imageAssets.length + soundAssets.length <= 0) {
            completeAsyncLoad();
            loading = false;
        }
    }

    public function setupPlay(stage:StageJson, characters:Array<String>, song:String):Void
    {
        #if desktop
        var imageAssets:Array<LoadImage> = Stage.getStageAssets(stage);
        var soundAssets:Array<String> = [];

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
        #end

        startAsyncLoad(imageAssets, soundAssets);
    }

    var startTime:Float = -1;

    public function startAsyncLoad(imageAssets:Array<LoadImage>, soundAssets:Array<String>):Void
    {
        loading = true;
        
        #if desktop
        this.imageAssets = imageAssets;
        this.soundAssets = soundAssets;

        imageQueue.clear();
        imageAssets.fastForEach((image, i) -> {
			if (!imageQueue.exists(image.path))
				imageQueue.set(image.path, true);
		});

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

        final cacheImage = (image:LoadImage, array:Array<LoadImage>) -> {
            var path:String = image.path;
            if (imageQueue.get(path)) {
                imageQueue.set(path, false); // Image in queue
                
                if (imageCache.get(path) == null) {
                    imageCache.set(path, {
                        bitmap: AssetManager.__getFileBitmap(path),
                        lod: image.lod
                    });
                }

                array.remove(image);
            }
            else array.remove(image);
        }

        var curThread = 0;

        final cacheImages = (array:Array<LoadImage>) -> {
            var i:Int = 0;
            // curThread++;
            // var thread = curThread;
    
            while (array.length > 0) {
                final image = array[i];
                if (image == null) {
                    i = 0;
                    continue;
                }
                
                if (imageQueue.get(image.path)) {
                    cacheImage(image, array);
                    //trace("loaded " + image.path + " in thread " + thread);
                    continue;
                }
    
                i++; // Find an uncached image index to queue and load
            }
        }

        // Load the rest of the images with the leftover threads
        for (_ in 0...threads) {
            FunkThread.run(() -> cacheImages(this.imageAssets));
        }
        #end
    }

    function completeAsyncLoad():Void
    {
        if (onStart != null)
            onStart();

        #if desktop
        for (key => image in imageCache) {
			AssetManager.__cacheFromBitmap(key, image.bitmap, false, image.lod);
		}

		for (key => sound in soundCache) {
			AssetManager.setAsset(key, Asset.fromAsset(sound, key), false);
		}
        #end

        trace("finished loading!", (openfl.Lib.getTimer() - startTime) / 1000);

        if (onComplete != null)
            onComplete();
    }
}