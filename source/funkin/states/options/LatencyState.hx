package funkin.states.options;

class LatencyState extends MusicBeatState
{
	var offsetText:FlxText;
	var hitSpr:FlxSprite;
	var offset:Float = 0;

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		offsetText = new FlxText(0,0,0,"", 20);
		add(offsetText);

		hitSpr = new FlxSprite();
		hitSpr.scale.set(3,3);
		hitSpr.screenCenter();
		add(hitSpr);

		FlxG.sound.playMusic(Paths.music('latency'), 1, true);
		Conductor.changeBPM(100);
		Conductor.songPosition = 0;
		offset = Conductor.settingOffset;

		super.create();
	}

	override function update(elapsed:Float)
	{
		offsetText.text = "Press space at the time of the beat.\n" + "Offset: " + offset + "ms";
		offsetText.screenCenter();
		hitSpr.alpha -= elapsed;

		if (FlxG.keys.justPressed.ENTER) {
			CoolUtil.playMusic('freakyMenu', 0);
			FlxG.sound.music.fadeIn(4, 0, 1);
			FlxG.switchState(new OptionsState());
		}

		if (FlxG.sound.music.playing)
			resync();

		if (FlxG.keys.justPressed.SPACE)
			pushOffset();

		super.update(elapsed);
	}

	var lastBeatTime:Float = 0;
	var lastOffsets:Array<Float> = [];

	function pushOffset() {
		resync();
		var _off = Conductor.songPosition - lastBeatTime;
		lastOffsets.push(_off);
		offset = getAverageOffset();
	}

	function getAverageOffset() {
		var averageOff:Float = 0;
		for (i in lastOffsets) {
			averageOff += i;
		}
		return Math.floor(averageOff / lastOffsets.length * 0.1);
	}

	override public function beatHit()
	{
		super.beatHit();
		resync();
		lastBeatTime = Conductor.songPosition;
		hitSpr.alpha = 1;
	}

	function resync()
		Conductor.songPosition = getTime() - Conductor.settingOffset;

	function getTime()
	{
		if (FlxG.sound.music != null)
			return FlxG.sound.music.time;

		return 0;
	}
}