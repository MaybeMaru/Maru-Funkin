package;

import flixel.system.ui.FlxSoundTray;
import flixel.FlxGame;

// TODO stylize this

class FlxFunkGame extends FlxGame {
    public var transition:Transition;
    public var console:ScriptConsole;
    
    public function new(gameWidth:Int = 0, gameHeight:Int = 0, ?initialState:Class<FlxState>, updateFramerate:Int = 60, drawFramerate:Int = 60, skipSplash:Bool = false, startFullscreen:Bool = false) {
        super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);
        _customSoundTray = FlxFunkSoundTray;
    }

    override function create(_:openfl.events.Event) {
        super.create(_);

        addChild(Main.transition = transition = new Transition());
        addChild(Main.console = console = new ScriptConsole());
    }

    override function update() {
        super.update();

        transition.update(FlxG.elapsed);
        console.update(FlxG.elapsed);
    }
}

class FlxFunkSoundTray extends FlxSoundTray {
    override function update(elapsed:Float) {
        super.update(elapsed * 4);
    }

    override function show(up:Bool = false) {
        super.show(up);
        _timer *= 4;
    }
}