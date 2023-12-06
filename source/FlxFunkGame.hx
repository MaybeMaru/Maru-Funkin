package;

import flixel.system.FlxAssets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.system.ui.FlxSoundTray;
import flixel.FlxGame;

class FlxFunkGame extends FlxGame {
    public var transition:Transition;
    public var console:ScriptConsole;
    public var fpsCounter:FPS_Mem;
    
    public function new(gameWidth:Int = 0, gameHeight:Int = 0, ?initialState:Class<FlxState>, updateFramerate:Int = 60, drawFramerate:Int = 60, skipSplash:Bool = false, startFullscreen:Bool = false) {
        super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);
        _customSoundTray = FlxFunkSoundTray;
    }

    override function create(_:openfl.events.Event) {
        super.create(_);

        addChild(Main.transition = transition = new Transition());
        addChild(Main.console = console = new ScriptConsole());

        #if !mobile
        addChild(Main.fpsCounter = fpsCounter = new FPS_Mem(10,10,0xffffff));
        #end

        FlxG.mouse.useSystemCursor = true;
        Preferences.effectPrefs();
    }

    override function update() {
        super.update();

        transition.update(FlxG.elapsed);
        console.update(FlxG.elapsed);
    }
}

class FlxFunkSoundTray extends FlxSoundTray {
    var _bar:Bitmap;
    
    public function new() {
        super();
        removeChildren();
        
        final bg = new Bitmap(new BitmapData(80, 25, false, 0xff3f3f3f));
        addChild(bg);

        _bar = new Bitmap(new BitmapData(75, 25, false, 0xffffffff));
        _bar.x = 2.5;
        addChild(_bar);

        final tmp:Bitmap = new Bitmap(openfl.Assets.getBitmapData("assets/images/options/soundtray.png"), null, true);
        addChild(tmp);
        screenCenter();
        
        tmp.scaleX = 0.5;
        tmp.scaleY = 0.5;
        tmp.x -= tmp.width * 0.2;
        tmp.y -= 5;

        y = -height;
		visible = false;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed * 4);
    }

    override function show(up:Bool = false) {
        if (!silent) {
			final sound = FlxAssets.getSound("assets/sounds/volume");
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		_timer = 4;
		y = 0;
		visible = active = true;
        _bar.scaleX = FlxG.sound.muted ? 0 : FlxG.sound.volume;
    }

    override function screenCenter() {
        _defaultScale = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height) * 2;
        super.screenCenter();
    }
}