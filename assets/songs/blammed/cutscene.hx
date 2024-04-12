import flixel.util.FlxGradient;

var cars = [];
var gradient; var transTrain;

function createPost() {
	createTunnel();
	createCity();
	createCars();

	gradient = FlxGradient.createGradientFlxSprite(FlxG.width * 2, 1, [FlxColor.TRANSPARENT, FlxColor.BLACK, FlxColor.BLACK], 1, 0);
	gradient.scale.y = FlxG.height;
	gradient.updateHitbox();
	gradient.setPosition(1500, 200);
	add(gradient);

	transTrain = new FunkinSprite("train", [1500, 175]);
	transTrain.scale.set(2, 2);
	transTrain.updateHitbox();
	add(transTrain);
}

function createCars() {
	for (i in 0...3) {
		var car:FunkinSprite = new FunkinSprite('blammed/blammedTrain', [switch (i) {
			case 0: -1650; case 1: 950; default: -375;
		}, 675]);
		car.addAnim('t', 'train', 24, true);
		car.playAnim('t');

		if (i != 2)
			car.color = FlxColor.GRAY;

		car.setScale(0.8);
		cars.push(car);
		addSpr(car, 'car' + i);

		car._dynamic.timeElapsed = 0;
		car._dynamic.update = function (e) {
			car._dynamic.timeElapsed += e;
			if (car._dynamic.timeElapsed >= 1 / 24) {
				car._dynamic.timeElapsed = 0;
				car.offset.set(FlxG.random.float(-1.5,1.5), FlxG.random.float(-1.5,1.5));
				
				if (i == 2 && car.visible) {
					for (c in [State.boyfriend, State.dad]) {
						c.applyCurOffset(true);
						c.offset.x += car.offset.x;
						c.offset.y += car.offset.y;
					}
				}
			}
		}
	}

	for (i in cars)
		i.visible = false;
}

// TUNNEL SECTION

var tunnel; var overlay; var lights; var blur;

function createTunnel() {
	var colorLights = getGlobalVar("colorLights");

	tunnel = new FlxSprite(-500, -500).makeRect(FlxG.width + 500, FlxG.height + 500, FlxColor.fromRGB(16, 13, 29));
	tunnel.scrollFactor.set();
	addSpr(tunnel, 'tunnel');

	lights = new FunkinSprite('blammed/tunnelLights', [-550,300],[0.8,0.8]);
	lights.setScale(0.8);
	lights.alpha = 0;
	addSpr(lights,'tunnelLights');
	
	blur = new FunkinSprite('blammed/tunnelLightsBlur', [lights.x - 25, lights.y - 5],[0.8,0.8]);
	blur.blend = getBlendMode('add');
	blur.setScale(0.8);
	blur.alpha = 0;
	addSpr(blur,'tunnelBlur');

	for (i in [lights, blur]) {
		i.addAnim('lights', 'tunnelLights', 24, true);
		i.playAnim('lights');
	}

	overlay = new FlxSprite(-500, -500).makeRect(FlxG.width + 500, FlxG.height + 500);
	overlay.scrollFactor.set();
	overlay.blend = getBlendMode('multiply');
	addSpr(overlay, 'overlay', true);

	colorLights.push(overlay);
	colorLights.push(lights);
	colorLights.push(blur);

	visibleTunnel(false);
}

function visibleTunnel(bool) {
	overlay.visible = bool;
	lights.visible = bool;
	blur.visible = bool;
	tunnel.visible = bool;
}

// CITY SECTION

var cityBg; var cityFg;

function createCity() {
	var cityData = [[0.6, 50], [0.8, 100]];

	cityBg = new FlxBackdrop(Paths.image('blammed/cityLoop'), 0x01);
	cityBg.scrollFactor.set(0, 0.25);
	cityBg.flipX = true;
	cityBg.color = FlxColor.fromRGB(120, 105, 185);
	cityBg.alpha = 0.8;
	cityBg.scale.set(0.6, 0.6);
	cityBg.updateHitbox();
	cityBg.y = 300;

	cityFg = new FlxBackdrop(Paths.image('blammed/cityLoop'), 0x01);
	cityFg.scrollFactor.set(0, 0.25);
	cityFg.scale.set(0.8, 0.8);
	cityFg.updateHitbox();
	cityFg.y = 350;

	addSpr(cityBg, "cityBg");
	addSpr(cityFg, "cityFg");

	cityBg.velocity.x = 30;
	cityFg.velocity.x = 100;
	cityBg.visible = false;
	cityFg.visible = false;
}

function beatHit(beat) {
	lights.alpha = 1;
	blur.alpha = 1;

	switch (beat)
	{
		case 100:
			setGlobalVar("trainAllowed", false);

		case 126: // Train goes over the screen
			FlxTween.tween(gradient, {x: -800}, Conductor.crochetMills * 1.25);
			transTrain.velocity.x = -19125;

		case 128: // Enter tunnel
			visibleTunnel(true);
			State.camGame.flash(switch (overlay.color) {
				case 0xFF31A2FD: 0xFF31FD8C;
				case 0xFF31FD8C: 0xFFFB33F5;
				case 0xFFFB33F5: 0xFFFD4531;
				case 0xFFFD4531: 0xFFFBA633;
				case 0xFFFBA633: 0xFF31A2FD;
			}, Conductor.crochet / 250);

			gradient.visible = false;
			transTrain.visible = false;

			for (i in cars)
				i.visible = true;

			for (i in ["city", "lights", "blur", "tracks", "street"])
				getSpr(i).visible = false;

			State.switchChar('bf', 'bf-car');
			State.gfGroup.visible = false;
			State.boyfriend.x += 75;
			State.dad.x -= 50;
			
			State.camZooming = getPref('camera-zoom');
			State.defaultCamZoom = 1;
			State.camGame.zoom = State.defaultCamZoom;
			State.cameraMovement();
	}
}

function sectionHit(section) {
	switch (section)
	{
		case 28: // Zoom up to bf
			State.camZooming = false;
			FlxTween.tween(State.camGame, {zoom: 1.5}, Conductor.sectionCrochetMills * 4);
		
		case 48: // Exit tunnel
			visibleTunnel(false);

			var flashColor = getPref('flashing-light') ? FlxColor.WHITE : FlxColor.fromRGB(255,255,255,120);
			State.camGame.flash(flashColor, Conductor.crochetMills * 4, null, true);
			State.defaultCamZoom = 0.8;
			State.camGame.zoom = 0.8;

			var sky = getSpr('sky');
			sky.setScale(1.33, false);
			sky.y += 50;

			cityBg.visible = true;
			cityFg.visible = true;
		
		case 72: // Ending fade
			State.camHUD.fade(FlxColor.BLACK, Conductor.crochetMills * 2);
	}
}

function updatePost(e) {
	var speed = Conductor.sectionCrochetMills * e;
	lights.alpha -= speed;
	blur.alpha -= speed * 2.5;
}