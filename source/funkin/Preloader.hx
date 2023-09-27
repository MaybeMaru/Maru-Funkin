package funkin;

import openfl.Assets;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.Context3D;

import flixel.addons.util.FlxAsyncLoop;
import flixel.ui.FlxBar;

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
    
    function fixFileList(list:Array<String>, typeFolder:String = 'images/', noLibFolder:String = 'assets/weeks'):Array<String> {
        var finalList:Array<String> = [];
        for (file in list) {
            if (!file.startsWith(noLibFolder) && !file.contains('unused/')) {
                finalList.push(file.split(typeFolder)[1].split('.')[0]);
            }
        }
        return finalList;
    }

    var cacheLoop:FlxAsyncLoop;
    var imageCache:Array<String> = [];

    var cacheProgress:FlxSprite;
    var cachePart:FlxText;

	override public function create():Void {
        var loaderArt:FlxSpriteExt = new FlxSpriteExt();
        loaderArt.loadGraphic(Paths.image('preloaderArt'));
        loaderArt.setScale(0.4);
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
        
        imageCache = fixFileList(Paths.getFileList(IMAGE, true, 'png'));
        _length = imageCache.length;
		cacheLoop = new FlxAsyncLoop(_length, loadBitmap);
		add(cacheLoop);

		super.create();
	}

    var _index:Int = 0;
    var _length:Int = 0;

    public function loadBitmap():Void {
        if (imageCache.length <= 0) return;

        var cacheStr = imageCache[0];
        if (cacheStr != null) {
            addBitmap(Paths.getPath('images/$cacheStr.png', IMAGE, null, false, false));
            imageCache.splice(imageCache.indexOf(cacheStr), 1);

            cachePart.text = 'Preloading Sprites...\n$cacheStr';
            cachePart.screenCenter(X);

            var listPercent:Float = (_index/(_length-1))*100;
            cacheProgress.scale.x = listPercent;
            _index++;
        }
    }

	override public function update(elapsed:Float):Void {
		if (!cacheLoop.started) {
			cacheLoop.start();
		}
		else {
			if (cacheLoop.finished) {
				cacheLoop.kill();
				cacheLoop.destroy();

                CustomTransition.init();
                FlxG.switchState(new SplashState());
			}
		}

		super.update(elapsed);
	}
}