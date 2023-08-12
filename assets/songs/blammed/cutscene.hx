//Lights
var blammedOverlay:FunkinSprite;

//Tunnel Section
var tunnelBG:FunkinSprite;
var blammedTrain:FunkinSprite;

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

	// sides trains
	for (i in 0...2) {
		var sideTrain = new FunkinSprite('blammed/blammedTrain', [i == 0 ? -1650 : 950, 675]);
		sideTrain.color = FlxColor.GRAY;
		sideTrain.setScale(0.8);
		sideTrain.addAnim('train', 'train', 24, true);
		sideTrain.playAnim('train', true, false, FlxG.random.int(0,2));
		addSpr(sideTrain,'sideTrain' + i);
	}

	blammedTrain = new FunkinSprite('blammed/blammedTrain', [-375, 675]);
	blammedTrain.setScale(0.8);
	blammedTrain.addAnim('train', 'train', 24, true);
	blammedTrain.playAnim('train');
	addSpr(blammedTrain, 'blammedTrain');

	for (i in ['sideTrain0','sideTrain1','blammedTrain']) {
		getSpr(i)._dynamic.timeElapsed = 0;
		getSpr(i)._dynamic.update = function (elapsed) {
			getSpr(i)._dynamic.timeElapsed += elapsed;
			if (getSpr(i)._dynamic.timeElapsed >= 1 / 24) {
				getSpr(i)._dynamic.timeElapsed = 0;
				getSpr(i).offset.set(FlxG.random.int(-1,1), FlxG.random.int(-1,1));
			}
		}
	}

	hideBlammed(false);
}

function beatHit(curBeat)
{
	switch (curBeat)
	{
		case 128: addBlammedTransition();
		case 126: startBlammedTransition();
	}
}

function hidePhilly(value) {
	for (i in ['overlayTrain', 'overlayTrainBG', 'phillyStreet', 'phillyTrain', 'streetBehind']) {
		if (existsSpr(i))
			getSpr(i).visible = value;
	}
}

function hideBlammed(value) {
	for (i in ['sideTrain0','sideTrain1','blammedTrain','tunnelBG']) {
		getSpr(i).visible = value;
	}
}

function addBlammedTransition() {
	PlayState.camGame.flash(getSpr('phillyWindow').color, Conductor.crochet/250, null, true);
	PlayState.switchChar('bf', 'bf-car');
	PlayState.gfGroup.visible = false;
	//blammedOverlay.alpha = 0.6;

	PlayState.boyfriend.x += 75;
	PlayState.dad.x -= 50;
	
	hidePhilly(false);
	hideBlammed(true);

	PlayState.camZooming = getPref('camera-zoom');
	PlayState.defaultCamZoom = 1;
	PlayState.camGame.zoom = PlayState.defaultCamZoom;
	PlayState.cameraMovement();
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
}

function sectionHit(curSection)
{
	switch (curSection)
	{
		case 28:
			PlayState.camZooming = false;
			FlxTween.tween(PlayState.camGame, {zoom: 1.5}, Conductor.sectionCrochetMills * 4);

		case 48:
			blammedOverlay.visible = false;
			tunnelBG.visible = false;
			PlayState.camGame.flash(FlxColor.WHITE, Conductor.crochetMills * 4, null, true);
			PlayState.defaultCamZoom = 0.8;
		case 72:
			PlayState.camHUD.fade(FlxColor.BLACK, Conductor.crochetMills * 2);
	}
}

/* WIP
function stepHit(curStep) {
	if (!getPref('flashing-light')) return;
	if (curStep >= 1144 && curStep <= 1150 && curStep % 2 == 0) {
		var alpha = curStep <= 1146 ? 120 : 160;
		PlayState.camHUD.fade(FlxColor.fromRGB(0,0,0,Std.int(alpha)), Conductor.stepCrochetMills * 0.9);
	}
}*/

function update(elapsed)
{
	if (existsSpr('overlayTrain'))
	{
		getSpr('overlayTrain').x -= (225*75)*elapsed;
		getSpr('overlayTrainBG').x = getSpr('overlayTrain').x;
	}
}