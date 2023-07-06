importLib('HealthIcon', 'funkin.graphics');
var fakeIcon:HealthIcon;
var iconEvilTrail:FlxTrail;

function create()
{
    var evilTrail = new FlxTrail(ScriptChar, null, 4, 24, 0.3, 0.069);
    PlayState.add(evilTrail);
}

function createPost()
{
    if (ScriptChar == PlayState.boyfriend)
    {
        fakeIcon = new HealthIcon(PlayState.boyfriend.icon, true);
        fakeIcon.ID = 0;
        iconEvilTrail = new FlxTrail(fakeIcon, null, 4, 24, 0.3, 0.069);

        PlayState.iconGroup.add(iconEvilTrail);
        PlayState.iconGroup.add(fakeIcon);
        fakeIcon.cameras = [PlayState.camHUD];
        iconEvilTrail.cameras = [PlayState.camHUD];
    }
    else if (ScriptChar == PlayState.dad)
    {

        fakeIcon = new HealthIcon(PlayState.dad.icon, false);
        fakeIcon.ID = 1;
        iconEvilTrail = new FlxTrail(fakeIcon, null, 4, 24, 0.3, 0.069);

        PlayState.iconGroup.add(iconEvilTrail);
        PlayState.iconGroup.add(fakeIcon);
        fakeIcon.cameras = [PlayState.camHUD];
        iconEvilTrail.cameras = [PlayState.camHUD];
    }
}

function updatePost()
{
    switch(fakeIcon.ID)
    {
        case 0:
            PlayState.iconP1.visible = false;

            fakeIcon.x = PlayState.iconP1.x;
            fakeIcon.y = PlayState.iconP1.y;
            fakeIcon.scale.set(PlayState.iconP1.scale.x, PlayState.iconP1.scale.y);
            fakeIcon.updateHitbox();

        case 1:
            PlayState.iconP2.visible = false;

            fakeIcon.x = PlayState.iconP2.x;
            fakeIcon.y = PlayState.iconP2.y;
            fakeIcon.scale.set(PlayState.iconP2.scale.x, PlayState.iconP2.scale.y);
            fakeIcon.updateHitbox();
    }    
}