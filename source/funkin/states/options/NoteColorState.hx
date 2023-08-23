package funkin.states.options;

import funkin.states.options.items.SettingItem;

class NoteColorState extends MusicBeatState
{
	private var notesArray:Array<Note> = [];
	private var notesGroup:FlxTypedGroup<Note>;
	private var optionsGroup:FlxTypedGroup<SettingItem>;

	public static var baseColorRGB:Array<Array<Int>> = [[255, 255, 255], [255, 255, 255], [255, 255, 255], [255, 255, 255]];
	public static var whiteColorRGB:Array<Array<Int>> = [[255, 255, 255], [255, 255, 255], [255, 255, 255], [255, 255, 255]];
	public static var outlineColorRGB:Array<Array<Int>> = [[255, 255, 255], [255, 255, 255], [255, 255, 255], [255, 255, 255]];

	private var curNote:Int = 0;
	private var curRow:Int = 0;
	private var inNote:Bool = false;

	override public function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);

		notesGroup = new FlxTypedGroup<Note>();
		add(notesGroup);

		for (i in 0...4)
		{
			var daNote:Note = new Note(0, i);
			// daNote.setNoteScale(1,1,'note');
			daNote.screenCenter();
			daNote.x += (-1 + i) * (daNote.width * 1.5);
			daNote.y = FlxG.height * 0.2;
			notesGroup.add(daNote);
		}

		var textColors:Array<Int> = [FlxColor.RED, FlxColor.LIME, FlxColor.CYAN];
		var textCrap:Array<String> = ['Red', 'Green', 'Blue'];
		var tempShit:Array<Alphabet> = [];
		for (i in 0...textCrap.length)
		{
			var alphaText:Alphabet = new Alphabet(FlxG.width * 0.025, FlxG.height * 0.4 + 150 * i, textCrap[i]);
			add(alphaText);
			alphaText.color = textColors[i];
			tempShit.push(alphaText);
		}

		optionsGroup = new FlxTypedGroup<SettingItem>();
		add(optionsGroup);

		for (X in 0...4)
		{
			for (Y in 0...3)
			{
				var leOption:SettingItem = new SettingItem('noteRGB', '', false, 255);
				optionsGroup.add(leOption);
				var leY:Float = tempShit[Y].y - 100;
				leOption.stringID = '${X}${Y}';
				leOption.targetY = leY;
				leOption.setPosition(notesGroup.members[X].x - 75, leY);
			}
		}
		changeNoteSelection();

		super.create();
	}

	function changeNoteSelection(change:Int = 0):Void
	{
		if (change != 0)
			CoolUtil.playSound('scrollMenu');
		curNote += change;
		if (curNote > notesGroup.members.length - 1)
			curNote = 0;
		if (curNote < 0)
			curNote = notesGroup.members.length - 1;

		for (i in 0...notesGroup.members.length)
		{
			notesGroup.members[i].alpha = 0.5;
			if (i == curNote)
				notesGroup.members[i].alpha = 1;
		}
	}

	function changeRowSelection(change:Int = 0):Void
	{
		if (change != 0)
			CoolUtil.playSound('scrollMenu');
		curRow += change;
		if (curRow > 2)
			curRow = 0;
		if (curRow < 0)
			curRow = 2;

		for (i in 0...optionsGroup.members.length)
		{
			optionsGroup.members[i].alpha = 0.5; // stringID
			var guh:Array<String> = optionsGroup.members[i].stringID.split(''); // Std.string(optionsGroup.members[i].ID).split('');
			var idShit:Array<Int> = [];
			for (crap in guh)
				idShit.push(Std.parseInt(crap));

			if (curNote == idShit[0] && curRow == idShit[1])
				optionsGroup.members[i].alpha = 1;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (getKey('BACK-P'))
		{
			// Preferences.savePrefs();
			if (inNote)
			{
				inNote = false;
				changeRowSelection();
				changeNoteSelection();
			}
			else
			{
				switchState(new OptionsState());
			}
		}

		if (getKey('UI_LEFT-P') || getKey('UI_RIGHT-P'))
		{
			if (inNote)
			{
			}
			else
			{
				if (getKey('UI_LEFT-P'))
					changeNoteSelection(-1);
				if (getKey('UI_RIGHT-P'))
					changeNoteSelection(1);
			}
		}

		if (getKey('UI_UP-P') || getKey('UI_DOWN-P') && inNote)
		{
			if (getKey('UI_UP-P'))
				changeRowSelection(-1);
			if (getKey('UI_DOWN-P'))
				changeRowSelection(1);
		}

		if (getKey('ACCEPT-P') && !inNote)
		{
			curRow = 0;
			inNote = true;
			changeRowSelection();
		}

		for (option in optionsGroup)
		{
			if (option.numSetSpr.text.contains('<'))
				option.numSetSpr.makeText('${option.prefValue}');
		}
	}
}
