//Lights
var phillyCityLights:FunkinSprite;
var phillyColor:Int = 0;

//Train
var phillyTrain:FunkinSprite;
var trainSound:FlxSound;

var startedMoving:Bool = false;
var trainMoving:Bool = false;
var trainFrameTiming:Float = 0;

var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;

function create():Void {
	var bg:FunkinSprite = new FunkinSprite('philly/sky', [-100, 0], [0.1,0.1]);
	addSpr(bg, 'phillyBg');

	var city:FunkinSprite = new FunkinSprite('philly/city', [-10, 0], [0.3,0.3]);
	city.setGraphicSize(Std.int(city.width * 0.85));
	city.updateHitbox();
	addSpr(city, 'phillyCity');

	phillyCityLights = new FunkinSprite('philly/phillyWindow', [city.x, 0], [0.3,0.3]);
	phillyCityLights.visible = false;
	phillyCityLights.setGraphicSize(Std.int(phillyCityLights.width * 0.85));
	phillyCityLights.updateHitbox();
	phillyCityLights.blend = getBlendMode('add');
	addSpr(phillyCityLights, 'phillyWindow');

	initShader('bloom', 'bloom');
	setShaderFloat('bloom', 'u_intensity', 1);
	setSpriteShader(phillyCityLights, 'bloom');

	var streetBehind:FunkinSprite = new FunkinSprite('philly/behindTrain', [-40, 50]);
	addSpr(streetBehind, 'streetBehind');

	phillyTrain = new FunkinSprite('philly/train', [2000, 360]);
	addSpr(phillyTrain, 'phillyTrain');

	var street:FunkinSprite = new FunkinSprite('philly/street', [-40, streetBehind.y]);
	addSpr(street, 'phillyStreet');

	trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
	FlxG.sound.list.add(trainSound);

	phillyColor += FlxG.random.int(0,3);
}

function beatHit(curBeat):Void {
	var genTrain:Bool = (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8 && !trainSound.playing);
	var inBlammed:Bool = (PlayState.curSong == 'Blammed' && curBeat >= 100);

	if (!trainMoving) {
        trainCooldown++;
	}

    if (genTrain && !inBlammed) {
        trainStart();
    }
}

var phillyLightsColors:Array<Int> = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
function sectionHit(curSection):Void {
	var stuffToColor:Array<Null<FunkinSprite>> = [phillyCityLights, getSpr('blammedOverlay'), getSpr('tunnelBG')];
	var curColor:Int = phillyLightsColors[phillyColor];
	for (obj in stuffToColor) {
		if (obj != null) {	//	BLAMMED COLORS
			obj.color = curColor;
		}
	}
	var showLights:Bool = true;
	switch(PlayState.curSong) {
		case 'Pico': showLights = (curSection > 1);	//	PICO CUTSCENE
	}
	phillyCityLights.visible = showLights;
	phillyCityLights.alpha = 1;
	phillyColor = FlxMath.wrap(phillyColor + 1, 0, 4);
}

function update(elapsed):Void {
    phillyCityLights.alpha -= elapsed*(Conductor.bpm/200);
	if (phillyCityLights.alpha > 0) {
		setShaderFloat('bloom', 'u_intensity', Math.min(phillyCityLights.alpha + 1, 1));
	}

    if (trainMoving) {
        trainFrameTiming += elapsed;
        if (trainFrameTiming >= 1 / 24) {
            updateTrainPos();
            trainFrameTiming = 0;
        }
    }
}

function trainStart():Void {
	trainCooldown = FlxG.random.int(-4, 0);
	trainMoving = true;
	if (!trainSound.playing) {
		trainSound.play(true);
	}
}

function updateTrainPos():Void {
	if (trainSound.time >= 4700) {
		startedMoving = true;
		PlayState.gf.playAnim('hairBlow');
	}

	if (startedMoving) {
		phillyTrain.x -= 400;
		if (phillyTrain.x < -2000 && !trainFinishing) {
			phillyTrain.x = -1150;
			trainCars -= 1;
		    if (trainCars <= 0) {
				trainFinishing = true;
			}
		}

		if (phillyTrain.x < -4000 && trainFinishing) {
			trainReset();
		}
	}
}

function trainReset():Void {
	PlayState.gf.playAnim('hairFall');
	phillyTrain.x = FlxG.width + 200;
	trainMoving = false;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
}