import funkin.objects.HealthIcon;

var gfIcon;
var hasIcon = false; // Prevent null error

function createPost():Void {
    hasIcon = ScriptChar.iconSpr != null;
    if (hasIcon)  {
        gfIcon = new HealthIcon('gf');
        State.iconGroup.add(gfIcon);
        setObjMap(gfIcon, 'gfIcon');
        ScriptChar.iconSpr.staticSize = 0.75;
    }
}

function updatePost():Void {
    if (hasIcon)  {
        gfIcon.flipX = ScriptChar.iconSpr.flipX;
        
        var offset = 50 * ScriptChar.iconSpr.lodDiv;
        if (!ScriptChar.isPlayer)
            offset = -offset;
    
        gfIcon.x = ScriptChar.iconSpr.x + offset;
        gfIcon.y = ScriptChar.iconSpr.y;
        ScriptChar.iconSpr.offset.y = -5;
        gfIcon.scale.set(ScriptChar.iconSpr.scale.x, ScriptChar.iconSpr.scale.y);
        gfIcon.updateHitbox();
    }
}