package funkin.states;

class LoadingState extends MusicBeatState
{
    var stageAssets:Array<LoadImage>;
    var charAssets:Array<LoadImage>;
    var songAssets:Array<String>;

    public var onComplete:()->Void;

    public function new() {
        super(false);
    }

    public function init(stage:StageJson, characters:Array<String>, song:String)
    {
        #if desktop
        var addedAssets:Array<String> = []; // Prevent repeating assets

        stageAssets = Stage.getStageAssets(stage);
        charAssets = [];
        songAssets = [];

        characters = CoolUtil.removeDuplicates(characters);

        characters.fastForEach((char, i) -> {
            if (char != null) if (!addedAssets.contains(char))
            {
                var json = Character.getCharData(char);
                
                var path:String = json.imagePath;
                if (!path.startsWith('characters/')) path = 'characters/$path';

                charAssets.push({
                    path: Paths.png(path),
                    lod: LodLevel.resolve(json.allowLod)
                });

                addedAssets.push(char);
            }
        });

        var inst = Paths.instPath(song);
        var voices = Paths.voicesPath(song);

        songAssets.push(inst);
        if (Paths.exists(voices, MUSIC))
            songAssets.push(voices);
        #else
        #if web
        //TODO: may need to make a custom loading screen for web
        #end
        #end
    }

    public var onStart:()->Void;

    public function start()
    {
        #if desktop
        var start = openfl.Lib.getTimer();

        if (onStart != null)
            onStart();

        AssetManager.loadAsync({
            stageImages: stageAssets,
            charImages: charAssets,
            songSounds: songAssets
        },
        () -> {
            trace("finished loading!", (openfl.Lib.getTimer() - start) / 1000);

            if (onComplete != null)
                onComplete();
        });
        #else
        if (onStart != null)    onStart();
        if (onComplete != null) onComplete();
        #end
    }

    var started:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (!started) {
            start();
            started = true;
        }
    }
}