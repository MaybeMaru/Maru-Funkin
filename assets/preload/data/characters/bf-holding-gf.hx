importLib('HealthIcon', 'funkin.graphics');
var gfIcon:HealthIcon;
var doStuff:Bool = false; // Prevent null error

function createPost():Void {
    doStuff = ScriptChar.iconSpr != null;
    if (doStuff)  {
        gfIcon = new HealthIcon('gf');
        gfIcon.cameras = [PlayState.camHUD];
        PlayState.iconGroup.add(gfIcon);
    
        ScriptChar.iconSpr.staticSize = 0.75;
    }
}

function beatHit():Void {
    if (doStuff)  {
        ScriptChar.iconSpr.bumpIcon(1.3/1.25);
    }
}

function updatePost():Void {
    if (doStuff)  {
        gfIcon.flipX = ScriptChar.iconSpr.flipX;
        var offset:Float = 50;
        if (!ScriptChar.isPlayer) {
            offset *= -1;
        }
    
        gfIcon.x = ScriptChar.iconSpr.x + offset;
        gfIcon.y = ScriptChar.iconSpr.y;
        ScriptChar.iconSpr.offset.y = -5;
        gfIcon.scale.set(ScriptChar.iconSpr.scale.x, ScriptChar.iconSpr.scale.y);
        gfIcon.updateHitbox();
    }
}