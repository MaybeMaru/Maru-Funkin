package funkin.states.options;

class LatencyState extends MusicBeatState
{
	var offsetText:FlxText;

	var noteGrp:FlxTypedGroup<Note>;
	var strumLine:FlxSprite;
	var offsetBF:Character;

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		noteGrp = new FlxTypedGroup<Note>();
		add(noteGrp);

		offsetText = new FlxText();
		offsetText.screenCenter();
		add(offsetText);

		strumLine = new FlxSprite(FlxG.width / 2, 100).makeGraphic(FlxG.width, 5);
		add(strumLine);

		offsetBF = new Character(0,0,'bf-pixel');
		offsetBF.screenCenter();
		offsetBF.x -= 180;
		offsetBF.y += 180;
		add(offsetBF);

		FlxG.sound.playMusic(Paths.inst('bopeebo'), 1, true);
				//FlxG.sound.playMusic(Paths.sound('soundTest'));

		Conductor.changeBPM(100);
		Conductor.songPosition = 0;

		super.create();
	}

	override function update(elapsed:Float)
	{
		offsetText.text = "Offset: " + Conductor.settingOffset + "ms";
		var multiply:Float = 1;

		if (FlxG.keys.pressed.SHIFT)
			multiply = 10;

		if (FlxG.keys.justPressed.RIGHT)
		{
			Conductor.settingOffset += 1 * multiply;
			resync();
		}
		if (FlxG.keys.justPressed.LEFT)
		{
			Conductor.settingOffset -= 1 * multiply;
			resync();
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			if (FlxG.sound.music.playing)
				FlxG.sound.music.pause();
			else
				FlxG.sound.music.play();
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.sound.music.playing)
		{
			resync();
		}

		noteGrp.forEach(function(daNote:Note)
		{
			daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * 0.45);
			daNote.x = strumLine.x + 30 + (125 * daNote.noteData%4);

			if (daNote.y < strumLine.y)
			{
				/*if (!daNote.wasGoodHit)
				{
					var rating:Rating = new Rating();
					rating.sickRating('sick');
					add(rating);
					FlxG.sound.play(Paths.sound('chart/hitclick'));
				}

				daNote.alpha = 0.6;
				daNote.wasGoodHit = true;*/
			}
			else
			{
				daNote.alpha = 1;
			}

			if (daNote.y < 0 - 100)
			{
				daNote.kill();
				daNote.destroy();
				noteGrp.remove(daNote);
			}

		});

		super.update(elapsed);
	}

	override public function beatHit()
	{
		super.beatHit();
		if (FlxG.sound.music.playing)
		{

			offsetBF.dance();

			var newNote:Note = new Note(Conductor.songPosition + Conductor.crochet * 4, FlxG.random.int(0, 3));
			//newNote.loadSkin('pixel');
			noteGrp.add(newNote);
		}
	}

	function resync()
	{
		Conductor.songPosition = getTime() - Conductor.settingOffset;
	}

	function getTime()
	{
		if (FlxG.sound.music != null)
			return FlxG.sound.music.time;

		return 0;
	}
}
