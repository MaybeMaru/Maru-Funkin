var evilIconTrail:FlxTrail;

function createChar() {
    var evilTrail:FlxTrail = new FlxTrail(ScriptChar, null, 4, 24, 0.3, 0.069);
    ScriptChar.group.insert(0, evilTrail);

    evilIconTrail = new FlxTrail(ScriptChar.iconSpr, null, 4, 24, 0.3, 0.069);
    State.iconGroup.insert(0, evilIconTrail);
}

function destroyChar() {
    evilIconTrail.destroy();
}