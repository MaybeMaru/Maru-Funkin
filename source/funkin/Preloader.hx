package funkin;

import openfl.Assets;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.Context3D;

/*
	Some stuff taken from the FNF FPS Plus preloader
	Credits to Rozebud
*/

class Preloader extends flixel.FlxState {
    public static var cachedGraphics:Map<String,FlxGraphic> = [];
    public static var cachedTextures:Map<String,Texture> = [];

    inline public static function addBitmap(key:String) {
        addFromBitmap(Assets.getBitmapData(key, false), key);
    }

    inline public static function getGraphic(key:String):FlxGraphic {
        return cachedGraphics.get(key);
    }

    inline public static function existsGraphic(key:String):Bool {
        return cachedGraphics.exists(key);
    }

    public static function uploadTexture(bmp:BitmapData, key:String) {
        var _texture = FlxG.stage.context3D.createTexture(bmp.width, bmp.height, COMPRESSED, true);
        _texture.uploadFromBitmapData(bmp);
        cachedTextures.set(key, _texture);
        Paths.disposeBitmap(bmp);
        var graphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(_texture));
        graphic.persist = true;
        graphic.destroyOnNoUse = false;
        return graphic;
    }

    public static function addFromBitmap(bmp:BitmapData, key:String) {        
        var graphic:FlxGraphic = uploadTexture(bmp, key);
        cachedGraphics.set(key, graphic);
        return graphic;
    }

    public static function removeByKey(key:String) {
        if(!existsGraphic(key)) return;
        var graphic = getGraphic(key);
        cachedGraphics.remove(key);
        Paths.destroyGraphic(graphic);
    }

    var imageCache:Array<String>    = [];
    var songCache:Array<String>     = [];
    var musicCache:Array<String>    = [];
    var soundCache:Array<String>    = [];

    var cacheProgress:FlxSprite;
    var cachePart:FlxText;

    var elapsedCrap:Float = 0;
    var startedCache:Bool = false;

    var cacheList:Array<Array<String>> = [];
    var listIndex:Int = 0;
    var fileIndex:Int = 0;

    function fixFileList(list:Array<String>, typeFolder:String = 'images/', noLibFolder:String = 'assets/weeks'):Array<String> {
        var finalList:Array<String> = [];
        for (file in list) {
            if (!file.startsWith(noLibFolder) && !file.contains('unused/')) {
                finalList.push(file.split(typeFolder)[1].split('.')[0]);
            }
        }
        return finalList;
    }

    function cacheAssets():Void {
            //  Get the assets image list
        var assetsImages:Array<String> = Paths.getFileList(IMAGE, true, 'png');
        imageCache = fixFileList(assetsImages);

            //  Get the assets music list
        /*var musicAssets:Array<String> = Paths.getFileList(MUSIC, true, Paths.SOUND_EXT, 'music/');
        musicCache = fixFileList(musicAssets, 'music/');
        
            //  Get the assets sound list
        var soundAssets:Array<String> = Paths.getFileList(SOUND, true, Paths.SOUND_EXT, 'sounds/');
        soundCache = fixFileList(soundAssets, 'sounds/');*/

            //  Get the assets song list
        /*var assetsSongs:Array<String> = Paths.getFileList(MUSIC, true, Paths.SOUND_EXT, 'Inst');
        for (i in 0...assetsSongs.length) {
            var songParts = assetsSongs[i].split('/');
            assetsSongs[i] = songParts[songParts.length-3];
        }
        songCache = assetsSongs;*/

            //  MUST BE IN THIS ORDER
        cacheList = [
            imageCache,
            songCache,
            musicCache,
            soundCache
        ];

        var loaderArt:FlxSprite = new FlxSprite().loadGraphic(Paths.image('preloaderArt'));
        loaderArt.setGraphicSize(Std.int(loaderArt.width*0.4));
        loaderArt.updateHitbox();
        loaderArt.screenCenter();
        add(loaderArt);

        cacheProgress = new FlxSprite().makeGraphic(10,10,0xFFFFFFFF);
        cacheProgress.screenCenter();
        cacheProgress.y += loaderArt.height/2;
        add(cacheProgress);

        cachePart = new FlxText(0,0,0,'',16);
        cachePart.alignment = CENTER;
        cachePart.y = cacheProgress.y + cacheProgress.height*1.5;
		add(cachePart);
    }

    override public function update(elapsed:Float):Void {
        FlxG.mouse.visible = false;
        elapsedCrap+=elapsed;

        if (elapsedCrap > 0.3) {
            if (!startedCache) {
                cacheAssets();
                startedCache = true;
            }

            var curFile:String = cacheList[listIndex][fileIndex];
            if (curFile != null) {
                switch (listIndex) {
                    case 0: //  BITMAP CACHE
                        cachePart.text = 'Preloading Sprites...';
                        addBitmap(Paths.getPath('images/$curFile.png', IMAGE, null, false, false));
                    case 1: //  INST/VOICES CACHE
                        cachePart.text = 'Preloading Songs...';
                        FlxG.sound.cache(Paths.inst(curFile));
                        FlxG.sound.cache(Paths.voices(curFile));
                    case 2: //  MUSIC CACHE
                        cachePart.text = 'Preloading Music...';
                        FlxG.sound.cache(Paths.music(curFile));
                    case 3: //  SOUND CACHE
                        cachePart.text = 'Preloading Sounds...';
                        FlxG.sound.cache(Paths.sound(curFile));
                }
                cachePart.text += '\n$curFile';
                cachePart.screenCenter(X);
                var listPercent:Float = (fileIndex/(cacheList[listIndex].length-1))*100;
                cacheProgress.scale.x = listPercent;
            }

            if (fileIndex > cacheList[listIndex].length-1) {    //  CHANGE LIST
                listIndex++;
                fileIndex=0;

                if (listIndex > cacheList.length-1) {
                    CustomTransition.init();
                    FlxG.switchState(new SplashState());
                }
            }
            else {  //  CHANGE FILE
                fileIndex++;
            }
        }

        super.update(elapsed);
    }
}