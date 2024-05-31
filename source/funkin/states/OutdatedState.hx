package funkin.states;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var newVer:EngineVersion;

	override function create():Void {
		super.create();

		if (newVer == null) {
			leftState = true;
			SplashState.startGame();
			return;
		}

		CoolUtil.playMusic('breakfast', 0.6);

		var ver = Main.engineVersion;
		var patchNotes:String = newVer.patchNotes.join("\n");		

		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			  "HEY! You're running an outdated version of the game!
			 \nCurrent version is v"+ver+" while the most recent version is v"+newVer.version+"!"+
			"\n\nThe new version includes:"+
			"\n"+patchNotes+
			"\n\nPress ACCEPT to go to Github, or BACK to ignore this!!",
			32);
		txt.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (getKey('ACCEPT', JUST_PRESSED)) {
			CoolUtil.openUrl("https://github.com/MaybeMaru/Maru-Funkin");
		}
		if (getKey('BACK', JUST_PRESSED)) {
			leftState = true;
			SplashState.startGame();
		}
	}
}
