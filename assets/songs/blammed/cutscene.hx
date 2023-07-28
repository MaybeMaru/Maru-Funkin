//Lights
var blammedOverlay:FunkinSprite;

//Tunnel Section
var tunnelBG:FunkinSprite;
var trainFloor:FunkinSprite;

function create()
{
	blammedOverlay = new FunkinSprite('', [-200,0], [1,1]).makeGraphic(FlxG.width*2, FlxG.height*2, FlxColor.WHITE);
	blammedOverlay.blend = getBlendMode('multiply');
	blammedOverlay.alpha = 0;
	addSpr(blammedOverlay, 'blammedOverlay', true);

	tunnelBG = new FunkinSprite('blammed/tunnelBg', [0,0], [0.8,0.8]);
	tunnelBG.scale.set(0.8,0.8);
	tunnelBG.updateHitbox();
	addSpr(tunnelBG,'tunnelBG');

	trainFloor = new FunkinSprite('blammed/trainFloor', [-150, 725]);
	//trainFloor.scale.set(0.8,0.8);
	//rainFloor.updateHitbox();
	addSpr(trainFloor,'trainFloor');

	trainFloor.visible = false;
	tunnelBG.visible = false;
}

function beatHit(curBeat)
{
	switch (curBeat)
	{
		case 128: addBlammedTransition();
		case 126: startBlammedTransition();
	}
}

function addBlammedTransition() {
	PlayState.camGame.flash(getSpr('phillyWindow').color, Conductor.crochet/250, null, true);
	PlayState.switchChar('bf', 'bf-car');
	PlayState.gfGroup.visible = false;
	blammedOverlay.alpha = 0.6;

	PlayState.boyfriend.x += 75;
	PlayState.dad.x -= 50;
	
	getSpr('overlayTrain').visible = false;
	getSpr('overlayTrainBG').visible = false;

	getSpr('phillyStreet').visible = false;
	getSpr('phillyTrain').visible = false;
	getSpr('streetBehind').visible = false;

	trainFloor.visible = true;
	tunnelBG.visible = true;

	PlayState.camZooming = getPref('camera-zoom');
	PlayState.defaultCamZoom = 1;
	PlayState.camGame.zoom = PlayState.defaultCamZoom;
}

function startBlammedTransition() {
	var overlayTrain:FunkinSprite = new FunkinSprite('philly/train', [4200, -50], [0,0]);
	overlayTrain.scale.set(2,2);
	var overlayTrainBG:FunkinSprite = new FunkinSprite('', [overlayTrain.x,overlayTrain.y], [0,0]).makeGraphic(overlayTrain.width/1.35, overlayTrain.height/1.4, FlxColor.BLACK);

	overlayTrainBG.scale.set(overlayTrain.scale.x,overlayTrain.scale.y);
	overlayTrainBG.scale.x *= 2;
	overlayTrain.updateHitbox();
	overlayTrainBG.updateHitbox();
	overlayTrainBG.offset.x -= overlayTrain.width/15*overlayTrain.scale.x;

	addSpr(overlayTrainBG, 'overlayTrainBG', true);
	addSpr(overlayTrain, 'overlayTrain', true);
}

function startSong() {
	Conductor.songPosition = 40 * 1000;
	Conductor.setPitch(1);
}

function sectionHit(curSection)
{
	switch (curSection)
	{
		case 28:
			PlayState.camZooming = false;
			FlxTween.tween(PlayState.camGame, {zoom: 1.5}, (Conductor.crochet/1000)*16);

		case 48:
			blammedOverlay.visible = false;
			tunnelBG.visible = false;
			PlayState.camGame.flash(FlxColor.WHITE, Conductor.crochet/250, null, true);
			PlayState.defaultCamZoom = 0.8;
	}
}

function update(elapsed)
{
	if (getSpr('overlayTrain') != null)
	{
		getSpr('overlayTrain').x -= (225*75)*elapsed;//elapsed*Conductor.bpm;
		getSpr('overlayTrainBG').x = getSpr('overlayTrain').x;
	}
}