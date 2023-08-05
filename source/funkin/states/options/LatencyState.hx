package funkin.states.options;

class LatencyState extends MusicBeatState
{
	var offsetText:Alphabet;
	var hitSpr:FlxSpriteUtil;
	var offset:Float = 0;

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var bg:FunkinSprite = new FunkinSprite('options/latencyDesat');
		bg.color = 0xff2b2b2b;
		add(bg);

		hitSpr = new FlxSpriteUtil(-35, FlxG.height / 2).loadImage('characters/speakers');
		hitSpr.setScale(0.8);
		hitSpr.addAnim('idle', 'speakers');
		hitSpr.playAnim('idle');
		add(hitSpr);

		offsetText = new Alphabet(hitSpr.x + hitSpr.width / 2 + 75, hitSpr.y - hitSpr.height / 2);
		offsetText.alignment = CENTER;
		add(offsetText);

		var txtLine:FlxSprite = new FlxSprite(0,25).makeGraphic(FlxG.width,50,FlxColor.BLACK);
		add(txtLine);

		var txtStr = "Sync your beats by tapping the space bar in rhythm to measure your offset.\nHit enter when done to save your calculated offset.";
		var txt:FlxText = new FlxText(FlxG.width/5,27.5,0,txtStr,16);
		txt.alignment = CENTER;
		add(txt);

		FlxG.sound.playMusic(Paths.music('latency'), 1, true);
		Conductor.bpm = 100;
		Conductor.songPosition = 0;
		offset = Conductor.settingOffset;
		updateTxt();

		super.create();
	}

	function updateTxt() {
		offsetText.text = "Offset:\n" + offset + "ms";
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER) {
			Conductor.settingOffset = offset;
			SaveData.setSave('offset', Conductor.settingOffset);
			SaveData.flushData();
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
		updateTxt();
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
		lastBeatTime = Conductor.songPosition;
		hitSpr.playAnim('idle', true);
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