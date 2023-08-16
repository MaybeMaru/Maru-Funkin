package funkin.states;
class OutdatedState extends MusicBeatState {
	public static var leftState:Bool = false;
	public static var newVer:EngineVersion = null;

	override function create():Void {
		super.create();

		CoolUtil.playMusic('breakfast', 0.6);
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var ver = Main.engineVersion;
		var patchNotes:String = "";
		for (i in newVer.patchNotes)
			patchNotes += '$i\n';

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
		if (getKey('ACCEPT-P')) {
			FlxG.openURL("https://github.com/MaybeMaru/Maru-Funkin");
		}
		if (getKey('BACK-P')) {
			leftState = true;
			SplashState.startGame();
		}
	}
}
