var colors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
var color = 0;
var start;
var sound;

function create() {
	setGlobalVar("colorLights", [lights, blur]);
}

function createPost() {
	lights.blend = getBlendMode("add");
	blur.blend = getBlendMode("add");

	lights.alpha = 0;
	blur.alpha = 0;

	start = switch (State.curSong) {
		case "Pico": 2;
		default: 0;
	}

	sound = getSound('train_passes');
	color += FlxG.random.int(0, colors.length);
}

function sectionHit(section) {
	if (State.curSong == "Blammed") {
		if (section > 26)
			trainEnabled = false;
	}
	
	if (section < start) return;
	
	color = FlxMath.wrap(color + 1, 0, 4);

	var lightsColor = colors[color];
	for (i in getGlobalVar("colorLights"))
		i.color = lightsColor;

	lights.alpha = 1;
	blur.alpha = 1;
}

function updatePost(elapsed) {
	var speed = Conductor.crochetMills * elapsed * 2;
	lights.alpha -= speed;
	blur.alpha -= speed * 1.25;

	trainMoving = sound.playing && sound.time > 4650;
	if (trainMoving && !finishedMove)
		updateTrain(elapsed);
}

/*
 * TRAIN CRAP
**/

var trainFrame = 0;
var trainCars = 8;
var trainMoving = false;
var trainFinished = false;
var trainCooldown = 0;
var finishedMove = false;
var trainEnabled = true;

function beatHit(beat) {
	if (trainEnabled) {
		if (!trainMoving)
			trainCooldown++;
	
		var moveTrain = (!trainMoving && trainCooldown > 8) && (beat % 8 == 4 && FlxG.random.bool(30));
		if (moveTrain)
			startTrain();
	}
}

function startTrain() {
	trainCooldown = FlxG.random.int(-4, 0);
	finishedMove = false;
	sound.play(true);
}

function updateTrain(elapsed) {
	trainFrame += elapsed;
    if (trainFrame >= 1 / 24) {
        moveTrain();
        trainFrame = 0;
    }
}

function moveTrain() {
	train.x -= 400;
	if (!trainFinished) {
		if (train.x < 800)
			State.gf.playAnim('hairBlow');
		
		if (train.x < -1900) {
			train.x = -850; 
			trainCars--;
			if (trainCars < 1)
				trainFinished = true;
		}
	}

	if (train.x < -4000 && trainFinished) {
		resetTrain();
	}
}

function resetTrain() {
	State.gf.playAnim('hairFall');
	train.x = 2000;
	trainCars = 8;
	trainFinished = false;
	trainMoving = false;
	finishedMove = true;
}