package;

import haxe.ui.locale.LocaleManager;
import openfl.display.BitmapData;
import flixel.system.FlxAssets;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
#if !mac
import haxe.ui.Toolkit;
#end

class InitState extends FlxState
{
    override function create():Void
	{
        super.create();

		//Load Settings / Mods
        Conductor.init();
		CoolUtil.init();
		Highscore.load();
		#if DISCORD_ALLOWED
		DiscordClient.initialize();
		lime.app.Application.current.onExit.add((code:Int) -> DiscordClient.shutdown());
        #end

		FlxG.switchState(new funkin.Preloader());
    }
}

class Main extends Sprite
{
	var settings = {
		width: 1280, 					// Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
		height: 720, 					// Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		initialState: InitState,		// The FlxState the game starts with.
		zoom: -1.0, 					// If -1, zoom is automatically calculated to fit the window dimensions.
		framerate: 60, 					// How many frames per second the game should run at.
		skipSplash: true, 				// Whether to skip the flixel splash screen that appears in release mode.
		startFullscreen: false 			// Whether to start the game in fullscreen on desktop targets
	};

	public static var sprite:Main;
	public static var game:FlxFunkGame;
	public static var fpsCounter:FPS_Mem; //The FPS display child
	public static var console:ScriptConsole;
	public static var transition:Transition;
	public static var engineVersion(default, never):String = "1.0.0-b.2"; //The engine version, if its not the same as the github one itll open OutdatedSubState

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(sprite = new Main());
		#if desktop
			Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, errorMsg);
			#if cpp	
				untyped __global__.__hxcpp_set_critical_error_handler(errorMsg);
			#end
		#end
	}

	#if desktop
	static function errorMsg(error:Dynamic)
	{
		Application.current.window.alert(Std.string(error is UncaughtErrorEvent ? error.error : error), "Uncaught Error");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end

	public function new()
	{
		super();
		stage != null ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		#if web throw("no."); #end
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		#if !mac
		// Init haxeui
		Toolkit.theme = "dark";
		Toolkit.init();
		#end
		
		// TODO: Only spanish and portuguese exist
		//LocaleManager.instance.language;

		setupGame();
	}

	public static var DEFAULT_GRAPHIC(default, null):GlobalGraphic = null;

	private function setupGame():Void {
		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;
		
		@:privateAccess
		DEFAULT_GRAPHIC = new GlobalGraphic(null, FlxAssets.getBitmapData("flixel/images/logo/default.png"));

		if (settings.zoom == -1.0) {
			final ratioX:Float = stageWidth / settings.width;
			final ratioY:Float = stageHeight / settings.height;
			settings.zoom = Math.min(ratioX, ratioY);
			settings.width = Math.ceil(stageWidth / settings.zoom);
			settings.height = Math.ceil(stageHeight / settings.zoom);
		}

		addChild(game = new FlxFunkGame(settings.width, settings.height, settings.initialState, settings.framerate, settings.framerate, settings.skipSplash, settings.startFullscreen));
	}

	public static function resizeGame(resolution:String) {
		#if desktop
		var resize = function (w:Int, h:Int) {
			FlxG.resizeWindow(w, h);
			Lib.application.window.x = Std.int((FlxG.stage.fullScreenWidth - w) * 0.5);
			Lib.application.window.y = Std.int((FlxG.stage.fullScreenHeight - h) * 0.5);
		}
		
		switch (resolution) {
			case "256x144": resize(256, 144);
			case "640x360": resize(640, 360);
			case "854x480": resize(854, 480);
			case "960x540": resize(960, 540);
			case "1024x576": resize(1024, 576);
			case "1280x720": resize(1280, 720);
			case "native": resize(FlxG.stage.fullScreenWidth, FlxG.stage.fullScreenHeight);
			default: resize(FlxG.initialWidth, FlxG.initialHeight);
		}
		#end
	}
}

class GlobalGraphic extends FlxGraphic {
	override function destroy() {} // Lol
}