package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var game = {
		width: 1280, 					// Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
		height: 720, 					// Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		initialState:					// The FlxState the game starts with.
		#if PRELOAD_ALL	funkin.Preloader
		#else			SplashState	#end,
		//funkin.states.TestingState,
		zoom: -1.0, 					// If -1, zoom is automatically calculated to fit the window dimensions.
		framerate: 60, 					// How many frames per second the game should run at.
		skipSplash: true, 				// Whether to skip the flixel splash screen that appears in release mode.
		startFullscreen: false 			// Whether to start the game in fullscreen on desktop targets
	};

	public static var fpsCounter:FPS_Mem; //The FPS display child
	public static var engineVersion:String = "pre-alpha"; //The engine version, if its not the same as the github one itll open OutdatedSubState

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if !mobile
		fpsCounter = new FPS_Mem(10,10,0xffffff);
		addChild(fpsCounter);
		#end
	}
}
