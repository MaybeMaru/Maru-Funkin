var speaker:FlxSpriteExt;

function createPost():Void
{
	ScriptChar.x += 250;
	speaker = new FlxSpriteExt(ScriptChar.x - 210, ScriptChar.y + 300);
	speaker.loadImage('characters/speakers');
	speaker.addAnim('speakers', 'speakers');
	ScriptChar.group.insert(0, speaker);

	speaker.flippedOffsets = ScriptChar.flippedOffsets;
	speaker.flipX = ScriptChar.flipX;
	if (speaker.flippedOffsets)
	{
		speaker.x += 140;
	}

	ScriptChar._dynamic.dodge = function()
	{
		ScriptChar.playAnim('dodge', true);
		ScriptChar.forceDance = false;
		ScriptChar.specialAnim = true;
		new FlxTimer().start(Conductor.crochet * 0.001, function(tmr:FlxTimer)
		{
			ScriptChar.forceDance = true;
			ScriptChar.specialAnim = false;
			ScriptChar.dance();
		});
	}
}

function beatHit():Void
{
	speaker.playAnim('speakers', true);
}

function startTimer():Void
{
	speaker.playAnim('speakers', true);
}
