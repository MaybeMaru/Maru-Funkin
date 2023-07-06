package funkin.states;
class OutdatedState extends MusicBeatState {
	public static var leftState:Bool = false;
	public static var newVer:EngineVersion = null;

	override function create():Void {
		super.create();

		var patchNotes:String = "";
		for (shit in newVer.patchNotes)
			patchNotes += '$shit\n';

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var ver = Main.engineVersion;
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			  "HEY! You're running an outdated version of the game!
			 \nCurrent version is v"+ver+" while the most recent version is v"+newVer.version+"!"+
			"\nThe new version includes:"+
			"\n"+patchNotes+
			"\nPress SPACE to go to Github, or ESCAPE to ignore this!!",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float):Void {
		if (getKey('ACCEPT-P')) {
			FlxG.openURL("https://github.com/MaybeMaru/Funkin");
		}
		if (getKey('BACK-P')) {
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
