function createPost()
{
	var evilTrail = new FlxTrail(ScriptChar, null, 4, 24, 0.3, 0.069);
	ScriptChar.group.insert(0, evilTrail);

	var evilIconTrail = new FlxTrail(ScriptChar.iconSpr, null, 4, 24, 0.3, 0.069);
	PlayState.iconGroup.insert(0, evilIconTrail);
}
