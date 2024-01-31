package funkin;

import flixel.addons.util.FlxAsyncLoop;

/*
	Some stuff taken from the FNF FPS Plus preloader
	Credits to Rozebud
*/

class Preloader extends FlxState {
    inline public static function cacheImage(key:String) {
        AssetManager.cacheGraphicPath(key, true);
    }
    
    function fixFileList(list:Array<String>, typeFolder:String = 'images/', noLibFolder:String = 'assets/weeks'):Array<String> {
        final finalList:Array<String> = [];
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
		super.create();

        if (#if hl true #else !Preferences.getPref('preload') #end) {
            skipPreload = true;
            return;
        }

        final loaderArt:FlxSpriteExt = new FlxSpriteExt();
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
	}

    var _index:Int = 0;
    var _length:Int = 0;

    public function loadBitmap():Void {
        if (imageCache.length <= 0) return;

        final cacheStr = imageCache[0];
        if (cacheStr != null) {
            var png = Paths.getPath('images/$cacheStr.png', IMAGE, null, false, false);
            cacheImage(png);
            imageCache.splice(imageCache.indexOf(cacheStr), 1);

            cachePart.text = 'Preloading Sprites...\n' + cacheStr;
            cachePart.screenCenter(X);

            var listPercent:Float = (_index/(_length-1))*100;
            cacheProgress.scale.x = listPercent;
            _index++;
        }
    }

    var skipPreload:Bool = false;

    inline function exit() {
        FlxG.switchState(new SplashState());
        //FlxG.switchState(new funkin.states.TestState());
        //FlxG.switchState(new funkin.states.TestStateUI());
    }

	override public function update(elapsed:Float):Void {
		if (!skipPreload) {
            if (!cacheLoop.started) {
                cacheLoop.start();
            }
            else {
                if (cacheLoop.finished) {
                    cacheLoop.kill();
                    cacheLoop.destroy();
                    exit();
                }
            }
        }

		super.update(elapsed);
        
        if (skipPreload) {
            exit();
        }
	}
}