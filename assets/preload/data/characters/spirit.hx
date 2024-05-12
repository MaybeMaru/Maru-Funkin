var evilIconTrail;

function createChar() {
    var evilTrail = new FlxTrail(ScriptChar, null, 4, 24, 0.3, 0.069);
    evilTrail.color = 0xffff3b6c;
    evilTrail.blend = getBlendMode("add");
    ScriptChar.group.insert(0, evilTrail);

    evilIconTrail = new FlxTrail(ScriptChar.iconSpr, null, 4, 24, 0.3, 0.069);
    evilIconTrail.color = 0xffff3b6c;
    evilIconTrail.blend = getBlendMode("add");
    State.iconGroup.insert(0, evilIconTrail);
}

function updatePost() {
    var lodScale = ScriptChar.iconSpr.lodScale;
    if (lodScale > 1) {
        evilIconTrail.scale.set(lodScale, lodScale);
        var offset = -((lodScale <= 2) ? 70 : ((lodScale <= 4) ? 220 : 500));
        evilIconTrail.offset.set(offset, offset);
    }
}

function destroyChar() {
    evilIconTrail.destroy();
}