package;

import funkin.sound.*;
import flixel.system.FlxAssets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.system.ui.FlxSoundTray;
import flixel.FlxGame;

interface IUpdateable {
	public function update(elapsed:Float):Void;
}

class FlxFunkGame extends FlxGame {
    public var transition:Transition;
    public var console:ScriptConsole;
    public var fpsCounter:FPS_Mem;
    
    public function new(gameWidth:Int = 0, gameHeight:Int = 0, ?initialState:Class<FlxState>, updateFramerate:Int = 60, drawFramerate:Int = 60, skipSplash:Bool = false, startFullscreen:Bool = false) {
        super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);
        _customSoundTray = FlxFunkSoundTray;
    }

    override function create(_:openfl.events.Event)
    {
        // Init save data
        SaveData.init();
        Controls.setupBindings();
        Preferences.setupPrefs();

        // Plugins
        FlxG.plugins.addPlugin(FlxFunkSoundGroup.group = new FlxFunkSoundGroup<FlxFunkSound>());
        
        super.create(_);

        addChild(Main.transition = transition = new Transition());
        removeChild(soundTray); addChild(soundTray); // Correct layering
        addChild(Main.console = console = new ScriptConsole());

        #if !mobile
        addChild(Main.fpsCounter = fpsCounter = new FPS_Mem(10,10,0xffffff));
        #end

        FlxG.mouse.useSystemCursor = true;
        
        Preferences.effectPrefs();
    }

    public var updateObjects:Array<IUpdateable> = [];

    override function update():Void
    {
        if (!_state.active || !_state.exists)
			return;

		if (_nextState != null)
			switchState();

		#if FLX_DEBUG
		if (FlxG.debugger.visible)
			ticks = getTicks();
		#end

		updateElapsed();
        var elapsed = FlxG.elapsed;

		FlxG.signals.preUpdate.dispatch();

		updateInput();

		#if FLX_SOUND_SYSTEM
		FlxG.sound.update(elapsed);
		#end
		FlxG.plugins.update(elapsed);
        transition.update(elapsed);
        console.update(elapsed);

		_state.tryUpdate(elapsed);

        if (_state.persistentUpdate && updateObjects.length != 0) {
            updateObjects.fastForEach((object, i) -> {
                object.update(elapsed);
            });
        }

		FlxG.cameras.update(elapsed);
		FlxG.signals.postUpdate.dispatch();

		#if FLX_DEBUG
		debugger.stats.flixelUpdate(getTicks() - ticks);
		#end

		#if FLX_POINTER_INPUT
		FlxArrayUtil.clearArray(FlxG.swipes);
		#end

		filters = filtersEnabled ? _filters : null;
    }
    
    public var enabledSoundTray(default, set):Bool = true;
    inline function set_enabledSoundTray(value:Bool) {
        #if FLX_KEYBOARD
        if (value != enabledSoundTray) {
            if (value) {
                FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
                FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
                FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
            }
            else {
                FlxG.sound.volumeUpKeys = [];
                FlxG.sound.volumeDownKeys = [];
                FlxG.sound.muteKeys = [];
            }
        }
        #end
        return enabledSoundTray = value;
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

        final tmp:Bitmap = new Bitmap(openfl.Assets.getBitmapData("assets/images/options/soundtray.png", false), null, true);
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
        super.update(elapsed * 4); // hack, sound tray is slow as fuck
    }

    override function show(up:Bool = false) {
        if (!silent) {
            #if desktop
            final sound = FlxAssets.getSound("assets/sounds/volume");
			if (sound != null)
				FlxG.sound.load(sound).play();
            #else
            CoolUtil.playSound("volume");
            #end
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