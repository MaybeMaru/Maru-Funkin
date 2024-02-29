package funkin.states;

class LoadingState extends MusicBeatState
{
    var stageAssets:Array<LoadImage>;
    var charAssets:Array<LoadImage>;
    var songAssets:Array<String>;

    public function init(stage:StageJson, characters:Array<String>, song:String)
    {
        var addedAssets:Array<String> = []; // Prevent repeating assets

        stageAssets = Stage.getStageAssets(stage);
        charAssets = [];
        songAssets = [];

        characters.fastForEach((char, i) -> {
            if (char != null) if (!addedAssets.contains(char))
            {
                var json = Character.getCharData(char);
                
                var path:String = json.imagePath;
                if (!path.startsWith('characters/')) path = 'characters/$path';
                var lod:Null<LodLevel> = json.allowLod ? null : HIGH;

                charAssets.push({
                    path: Paths.png(path),
                    lod: lod
                });

                addedAssets.push(char);
            }
        });

        var inst = Paths.instPath(song);
        var voices = Paths.voicesPath(song);

        songAssets.push(inst);
        if (Paths.exists(voices, MUSIC))
            songAssets.push(voices);
    }

    public function start()
    {
        var start = openfl.Lib.getTimer();

        AssetManager.loadAsync({
            stageImages: stageAssets,
            charImages: charAssets,
            songSounds: songAssets
        }, function () {

            //trace(AssetManager.tempAssets);
            //trace(AssetManager.getAsset(Paths.instPath("milf")));
            
            //new funkin.sound.FlxFunkSound().loadSound(Paths.inst("milf")).play();
            //new funkin.sound.FlxFunkSound().loadSound(Paths.voices("milf")).play();
            
            trace("finished!");
            trace((openfl.Lib.getTimer() - start) / 1000);
        });
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

    /*override function create() {
        super.create();
    }

    var timeElapsed:Float = 0.0;
    var showTime:Bool = false;

    override function update(elapsed:Float)
    {
        if (!showTime) {
            timeElapsed += elapsed;
            if (timeElapsed >= 3) {
                showTime = true;
            }
        }
    }*/
}