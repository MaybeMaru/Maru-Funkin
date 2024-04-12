package;

class SplashState extends FlxState
{
    override function create():Void {
        super.create();

        final iconz:FunkinSprite = new FunkinSprite('title/healthHeads');
        iconz.screenCenter();

        new FlxTimer().start(0.5, (tmr) -> {
            add(iconz);
            FlxG.sound.play(Paths.sound('intro/introSound'), 1, false, null, true, () -> {
                new FlxTimer().start(0.1, (tmr) -> iconz.destroy() );
                new FlxTimer().start(0.5, (tmr) -> switchStuff());
            });
        });

    }

    function switchStuff() {
        #if CHECK_UPDATES
        trace('Checking if version is outdated');	
		var gitFile = new haxe.Http("https://raw.githubusercontent.com/MaybeMaru/FNF-Engine-Backend/main/gameVersion.json");

		gitFile.onError = (error) -> {
			trace('Error: $error');
		}

		var openOutdated:Bool = false;
		gitFile.onData = (data:String) -> {
		    var newVersionData:EngineVersion = Json.parse(data);
		    trace('curVer [${Main.engineVersion}] // newVer [${newVersionData.version}]');

		    if (Main.engineVersion != newVersionData.version) {
			    openOutdated = true;
			    funkin.states.OutdatedState.newVer = newVersionData;
		    }
		}

		gitFile.request();
        openOutdated ? CoolUtil.switchState(new funkin.states.OutdatedState()) :
        #end
        startGame();
    }

    public static function startGame() {
        CoolUtil.playMusic('freakyMenu', 0);
        CoolUtil.switchState(new TitleState(), true, true);
    }
}