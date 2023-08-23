package funkin.states.options;

class LatencyState extends MusicBeatState
{
	var offsetText:Alphabet;
	var hitSpr:FlxSpriteExt;
	var offset:Float = 0;

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var bg:FunkinSprite = new FunkinSprite('options/latencyDesat');
		bg.color = 0xff2b2b2b;
		add(bg);

		hitSpr = new FlxSpriteExt(-35, FlxG.height / 2).loadImage('characters/speakers');
		hitSpr.setScale(0.8);
		hitSpr.addAnim('idle', 'speakers');
		hitSpr.playAnim('idle');
		add(hitSpr);

		offsetText = new Alphabet(hitSpr.x + hitSpr.width / 2 + 75, hitSpr.y - hitSpr.height / 2);
		offsetText.alignment = CENTER;
		add(offsetText);

		var txtLine:FlxSprite = new FlxSprite(0, 25).makeGraphic(FlxG.width, 70, FlxColor.BLACK);
		add(txtLine);

		var txtStr = "Sync your beats by tapping the space bar in rhythm to measure your offset.\nHit enter when done to save your calculated offset.\nHit escape to exit without saving your calculated offset.";
		var txt:FlxText = new FlxText(FlxG.width / 5, 27.5, 0, txtStr, 16);
		txt.alignment = CENTER;
		add(txt);

		FlxG.sound.playMusic(Paths.music('maruOffsets'), 1, true);
		Conductor.bpm = 100;
		Conductor.songPosition = 0;
		offset = Conductor.settingOffset;
		updateTxt();

		super.create();
	}

	function updateTxt()
	{
		offsetText.text = "Offset:\n" + offset + "ms";
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			Conductor.settingOffset = offset;
			SaveData.setSave('offset', Conductor.settingOffset);
			SaveData.flushData();
			exit();
		}
		else if (FlxG.keys.justPressed.ESCAPE)
		{
			exit();
		}

		if (FlxG.sound.music.playing)
			resync();

		if (FlxG.keys.justPressed.SPACE)
			pushOffset();

		super.update(elapsed);
	}

	function exit()
	{
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		switchState(new OptionsState());
	}

	var lastBeatTime:Float = 0;
	var nextBeatTime:Float = 0;
	var lastOffsets:Array<Float> = [];

	function pushOffset()
	{
		resync();
		var off1_:Float = Math.abs(Conductor.songPosition - lastBeatTime);
		var off2_:Float = Math.abs(Conductor.songPosition - nextBeatTime);
		var _off = (off1_ < off2_ ? Conductor.songPosition - lastBeatTime : Conductor.songPosition - nextBeatTime);

		lastOffsets.push(_off);
		offset = getAverageOffset();
		updateTxt();
	}

	function getAverageOffset()
	{
		var averageOff:Float = 0;
		for (i in lastOffsets)
		{
			averageOff += i;
		}
		return Math.floor(averageOff / lastOffsets.length * 0.1);
	}

	override public function beatHit()
	{
		super.beatHit();
		lastBeatTime = Conductor.songPosition;
		nextBeatTime = Conductor.songPosition + Conductor.crochet;
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
