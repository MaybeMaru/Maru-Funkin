import flixel.addons.display.FlxBackdrop;

function create()
{
	var blammedOverlay:FunkinSprite = new FunkinSprite('', [-500,-500], [0,0]).makeGraphic(FlxG.width*2, FlxG.height*2, FlxColor.WHITE);
	blammedOverlay.blend = getBlendMode('multiply');
	addSpr(blammedOverlay, 'blammedOverlay', true);

	var tunnelBG:FlxSpriteExt = new FlxSpriteExt().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(16, 13, 29));
	tunnelBG.scrollFactor.set();
	addSpr(tunnelBG,'tunnelBG');
	
	var tunnelLights = new FunkinSprite('blammed/tunnelLights', [-300,300],[0.8,0.8]);
	tunnelLights.blend = getBlendMode('add');
	tunnelLights.addAnim('lights', 'tunnelLights', 24, true);
	tunnelLights.playAnim('lights');
	tunnelLights.setScale(0.8);
	addSpr(tunnelLights,'tunnelLights');
	
	var tunnelLightsBlur = new FunkinSprite('blammed/tunnelLightsBlur', [tunnelLights.x - 25, tunnelLights.y - 5],[0.8,0.8]);
	tunnelLightsBlur.blend = getBlendMode('add');
	tunnelLightsBlur.addAnim('lights', 'tunnelLights', 24, true);
	tunnelLightsBlur.playAnim('lights');
	tunnelLightsBlur.setScale(0.8);
	addSpr(tunnelLightsBlur,'tunnelLightsBlur');
	
	tunnelLights._dynamic.update = function (elapsed) {
		var alphaVal = Conductor.sectionCrochetMills * elapsed;
		tunnelLights.alpha -= alphaVal;
		tunnelLightsBlur.alpha -= alphaVal * 2.5;
	}

	// scale, speed
	var cityData = [[0.6, 50], [0.8, 100]];
	for (i in 0...2) {
		var cityLoop = new FlxBackdrop(Paths.image('blammed/cityLoop'), 0x01);
		cityLoop.flipX = i == 0;
		cityLoop.color = (i == 0 ? FlxColor.fromRGB(120, 105, 185) : FlxColor.WHITE);
		cityLoop.alpha = (i == 0 ? 0.8 : 1);
		cityLoop.scale.set(cityData[i][0], cityData[i][0]);
		cityLoop.updateHitbox();
		cityLoop.y += 300 + (i * 50);
		cityLoop.scrollFactor.set(0.25,0.25);
		cityLoop.visible = false;
		addSpr(cityLoop, 'cityLoop' + i);
		cityLoop._dynamic.update = function (elapsed) {
			cityLoop.x += elapsed * cityData[i][1];
			cityLoop.x %= cityLoop.width;
		}
	}
	
	// sides trains
	for (i in 0...2) {
		var sideTrain = new FunkinSprite('blammed/blammedTrain', [i == 0 ? -1650 : 950, 675]);
		sideTrain.color = FlxColor.GRAY;
		sideTrain.setScale(0.8);
		sideTrain.addAnim('train', 'train', 24, true);
		sideTrain.playAnim('train', true, false, FlxG.random.int(0,2));
		addSpr(sideTrain,'sideTrain' + i);
	}
	
	var blammedTrain:FunkinSprite = new FunkinSprite('blammed/blammedTrain', [-375, 675]);
	blammedTrain.setScale(0.8);
	blammedTrain.addAnim('train', 'train', 24, true);
	blammedTrain.playAnim('train');
	addSpr(blammedTrain, 'blammedTrain');
	
	for (i in ['sideTrain0','sideTrain1','blammedTrain']) {
		var spr = getSpr(i);
		spr._dynamic.timeElapsed = 0;
		spr._dynamic.update = function (elapsed) {
			spr._dynamic.timeElapsed += elapsed;
			if (spr._dynamic.timeElapsed >= 1 / 24) {
				spr._dynamic.timeElapsed = 0;
				spr.offset.set(FlxG.random.float(-1.5,1.5), FlxG.random.float(-1.5,1.5));
				
				if (i == 'blammedTrain' && spr.visible) {
					for (c in [State.boyfriend, State.dad]) {
						c.applyCurOffset(true);
						c.offset.x += spr.offset.x;
						c.offset.y += spr.offset.y;
					}
				}
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

	for (i in ['tunnelLights', 'tunnelLightsBlur'])
		getSpr(i).alpha = 1;
}
	
function hidePhilly(value) {
	for (i in ['overlayTrain', 'overlayTrainBG', 'phillyStreet', 'phillyTrain', 'streetBehind']) {
		if (existsSpr(i))
			getSpr(i).visible = value;
	}
}
	
function hideBlammed(value) {
	for (i in ['sideTrain0','sideTrain1','blammedTrain','tunnelBG','tunnelLights','tunnelLightsBlur','blammedOverlay']) {
		getSpr(i).visible = value;
	}
}
	
function addBlammedTransition() {
	State.camGame.flash(getSpr('phillyWindow').color, Conductor.crochet/250, null, true);
	State.switchChar('bf', 'bf-car');
	State.gfGroup.visible = false;

	State.boyfriend.x += 75;
	State.dad.x -= 50;
	
	hidePhilly(false);
	hideBlammed(true);
	
	State.camZooming = getPref('camera-zoom');
	State.defaultCamZoom = 1;
	State.camGame.zoom = State.defaultCamZoom;
	State.cameraMovement();
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
	
function exitTunnelTransition() {
	for (i in ['blammedOverlay', 'tunnelBG', 'tunnelLights','tunnelLightsBlur']) getSpr(i).visible = false;
	for (i in ['cityLoop0', 'cityLoop1'])  getSpr(i).visible = true;
	State.camGame.flash(getPref('flashing-light') ? FlxColor.WHITE : FlxColor.fromRGB(255,255,255,120), Conductor.crochetMills * 4, null, true);
	State.defaultCamZoom = 0.8;
	State.camGame.zoom = 0.8;
	
	for (i in ['phillyWindow', 'phillyWindowBlur', 'phillyCity']) getSpr(i).y += 2000;
	var sky = getSpr('phillyBg');
	sky.setScale(1.33, false);
	sky.y += 50;
}
	
function sectionHit(curSection)
{
	switch (curSection)
	{
		case 28:
			State.camZooming = false;
			FlxTween.tween(State.camGame, {zoom: 1.5}, Conductor.sectionCrochetMills * 4);
		case 48: exitTunnelTransition();
		case 72: State.camHUD.fade(FlxColor.BLACK, Conductor.crochetMills * 2);
	}
}
	
/* WIP
function stepHit(curStep) {
	if (!getPref('flashing-light')) return;
	if (curStep >= 1144 && curStep <= 1150 && curStep % 2 == 0) {
		var alpha = curStep <= 1146 ? 120 : 160;
		State.camHUD.fade(FlxColor.fromRGB(0,0,0,Std.int(alpha)), Conductor.stepCrochetMills * 0.9);
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