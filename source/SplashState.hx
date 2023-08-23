package;

import lime.app.Application;

class SplashState extends FlxState
{
	override function create()
	{
		super.create();

		// Load Settings / Mods
		FlxSprite.defaultAntialiasing = true;
		SaveData.init();
		Controls.setupBindings();
		Preferences.setupPrefs();
		Conductor.init();
		CoolUtil.init();
		Highscore.load();
		#if cpp
		DiscordClient.initialize();
		Application.current.onExit.add(function(exitCode) DiscordClient.shutdown());
		#end

		var iconz:FunkinSprite = new FunkinSprite('title/healthHeads');
		iconz.screenCenter();

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			add(iconz);
			FlxG.sound.play(Paths.sound('intro/introSound'), 1, false, null, true, function()
			{
				new FlxTimer().start(0.1, function(tmr:FlxTimer) iconz.destroy());
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					switchStuff();
				});
			});
		});
	}

	function switchStuff()
	{
		trace('Checking if version is outdated');
		var gitFile = new haxe.Http("https://raw.githubusercontent.com/MaybeMaru/FNF-Engine-Backend/main/gameVersion.json");

		gitFile.onError = function(error)
		{
			trace('error: $error');
		}

		var openOutdated:Bool = false;
		gitFile.onData = function(data:String)
		{
			trace(data);
			var newVersionData:EngineVersion = Json.parse(data);
			trace('cur Version: ${Main.engineVersion} // new Version: ${newVersionData.version}');

			if (Main.engineVersion != newVersionData.version)
			{
				openOutdated = true;
				funkin.states.OutdatedState.newVer = newVersionData;
			}
		}

		gitFile.request();
		openOutdated ? CoolUtil.switchState(new funkin.states.OutdatedState()) : startGame();
	}

	public static function startGame()
	{
		CoolUtil.playMusic('freakyMenu', 0);
		CoolUtil.switchState(new TitleState());
	}
}
