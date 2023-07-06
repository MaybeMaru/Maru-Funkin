importLib('HealthIcon', 'funkin.graphics');
var gfIcon:HealthIcon;
var targetIcon:HealthIcon;

function createPost():Void {
    gfIcon = new HealthIcon('gf');
    gfIcon.cameras = [PlayState.camHUD];
    PlayState.iconGroup.add(gfIcon);

    targetIcon = (ScriptChar.isPlayer) ? PlayState.iconP1 : PlayState.iconP2;
    targetIcon.staticSize = 0.75;
}

function beatHit():Void {
    targetIcon.bumpIcon(1.3/1.25);
}

function updatePost():Void {
    gfIcon.flipX = ScriptChar.isPlayer;
    var offset:Float = 50;
    if (!ScriptChar.isPlayer) {
        offset *= -1;
    }

    gfIcon.x = targetIcon.x + offset;
    gfIcon.y = targetIcon.y;
    targetIcon.offset.y = -5;
    gfIcon.scale.set(targetIcon.scale.x, targetIcon.scale.y);
    gfIcon.updateHitbox();
}