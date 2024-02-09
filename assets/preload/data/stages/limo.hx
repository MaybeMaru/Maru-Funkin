import funkin.util.song.WeekSetup;

var naughty;
var random;
var limbs = [];
var bloods = [];

var dancers = [];

function createPost()
{
	State.camGame.bgColor = 0xff516bdf;

	limo.playAnim("loop");
	driveLimo.playAnim("loop");

	var layer = getLayer("limo");
	for (i in 0...4) {
		var dancer = new FunkinSprite('limo/limoDancer', [130 + (370 * i), 80], [0.4, 0.4]);
		dancer.addAnim('danceLeft', 'bg dancer sketch PINK', 24, false, CoolUtil.numberArray(14));
		dancer.addAnim('danceRight', 'bg dancer sketch PINK', 24, false, CoolUtil.numberArray(30,15));
		dancer.dance();

		dancer._dynamic.dead = false;

		layer.add(dancer);
		dancers.push(dancer);
	}

	// Gore stuff

	var layer = getLayer("gore");
	naughty = getPref("naughty");
	random = FlxG.random;
	
	if (naughty)
	{
		for (i in 0...4)
		{
			var x = 370 * i;
			
			// Create limbs (Head, arms, legs, on rail)
			limbs.push([]);
			for (_ in 0...3)
			{
				var limb = new FunkinSprite("limo/henchmenGore", [x, 80], [0.4, 0.4]);
				
				limb.addAnim("rail1", "Henchmen on rail 1 PINK");
				limb.addAnim("rail2", "henchmen on rail 2 PINK", 24, false, null, [-100, -100]);
				
				limb.addAnim("head1", "hench head spin PINK", 24, true);
				limb.addAnim("head2", "hench head spin 2 PINK", 24, true);
				limb.addAnim("arm1", "hench arm spin PINK", 24, true);
				limb.addAnim("arm2", "hench arm spin 2 PINK", 24, true);
				limb.addAnim("leg1", "hench leg spin PINK", 24, true);
				limb.addAnim("leg2", "hench leg spin 2 PINK", 24, true);

				layer.add(limb);
				limbs[i].push(limb);
				limb.visible = false;

				// Set up a "class" of some sort for henchmen limbs

				var limbClass = limb._dynamic;

				limbClass.type = -1;

				limbClass.update = function () {
					if (limbClass.type == 0)
					{
						limb.x = pole.x - 200;
						if (limb.x > 2000)
							limb.active = false;
					}
					else
					{
						if (limb.y > 1200)
							limb.active = false;
					}
				}

				limbClass.reset = function (id) {
					limbClass.type = id;
					limb.visible = true;
					limb.active = true;
					
					switch (id) {
						case 0: limb.playAnim("rail" + random.int(1, 2));
						case 1: limb.playAnim("head" + random.int(1, 2));
						case 2: limb.playAnim("arm" + random.int(1, 2));
						case 3: limb.playAnim("leg" + random.int(1, 2));
					}

					if (id != 0)
					{
						limb.x = x + 275;
						limb.y = 180;
						
						var scroll = FlxG.random.float(0.325, 0.475);
						limb.scrollFactor.set(scroll, scroll);

						limb.acceleration.y = random.float(800, 1000);
						limb.velocity.y = random.float(-140, -160);
						limb.velocity.x = random.float(-50, 50);

						var ang = random.int(0, 360);
						var force = random.int(25, 75);
						CoolUtil.translateWithAngle(limb, force, force, ang);
					}
					else
					{
						limb.y = 80;
						limb.offset.x += random.int(-15, 15);
						limb.offset.y += random.int(-15, 15);
						limb.scrollFactor.set(0.4, 0.4);

						limb.acceleration.set();
						limb.velocity.set();
					}
				}
			}
			
			// Create blood
			var blood = new FunkinSprite("limo/blood", [25 + x, 80], [0.4, 0.4]);
			blood.addAnim("blood", "blood");
			blood.flipX = true;
			blood.visible = false;
			
			layer.add(blood);
			bloods.push(blood);

			blood.animation.finishCallback = function (name) {
				blood.visible = false;
			}
		}
	}

	light.offset.set(185, 0);

	overlay.alpha = 0.15;
	overlay.blend = getBlendMode('add');

	resetCar();
}

// Gore

function killDancer(id)
{
	dancers[id].visible = false;

	if (random.bool() || !naughty) // On rails
	{
		limbs[id][0]._dynamic.reset(0);
	}
	else // Explode
	{
		var limbs = limbs[id];
		limbs[0]._dynamic.reset(1); // Head
		limbs[1]._dynamic.reset(2); // Arms
		limbs[2]._dynamic.reset(3); // Legs
	}

	if (naughty && random.bool())
	{
		var blood = bloods[id];
		blood.visible = true;
		blood.playAnim("blood");
	}
}

var lastTime = 0;
var doingGore = false;
var didGore = false;
var dodged = false;
var goreIndex = 0;

function sectionHit()
{
	if (FlxG.random.bool(10) && !doingGore)
		startGore();
}

function startGore()
{
	lastTime = Conductor.songPosition;
	doingGore = true;
	didGore = false;
}

function updatePost()
{
	if (!carCanDrive) {
		if (FlxG.mouse.overlaps(car) && FlxG.mouse.justPressed)
			WeekSetup.loadSong("", "ridge", "normal");
	}
	
	if (!doingGore) 
		return;

	pole.x = (Conductor.songPosition - lastTime) * 6;
	light.x = pole.x;
	
	if (pole.x > 0)
	{		
		if (!didGore) {
			FlxG.sound.play(Paths.sound("gore"));
			didGore = true;
		}

		if (!dodged && pole.x > 725) {
			State.gf._dynamic.dodge();
			dodged = true;
		}

		var dancer = dancers[goreIndex];
		if (dancer != null) {
			if (pole.x > (dancer.x + 120) && !dancer._dynamic.dead)
			{
				dancer._dynamic.dead = true;
				killDancer(goreIndex);
				goreIndex++;

				if (goreIndex == dancers.length)
					new FlxTimer().start(Conductor.crochetMills * 2, resetLimo);
			}
		}
	}
}

function resetLimo()
{
	var time = Conductor.crochetMills * 2;
	
	FlxTween.tween(limo, {x: 1280}, time, {ease: FlxEase.backIn, onComplete: function () {
		new FlxTimer().start(time * 2, function (tmr)
		{
			for (i in dancers)
			{
				i.x += 1480;
				i.visible = true;
				i._dynamic.dead = false;
				FlxTween.tween(i, {x: i.x - 1480}, time, {ease: FlxEase.backOut});
			}

			// Get the limo back on screen
			FlxTween.tween(limo, {x: -200}, time, {ease: FlxEase.backOut, onComplete: function () {
				doingGore = false;
				dodged = false;
				goreIndex = 0;
			}});
		});
	}});
}

function startTimer()
{
	for (i in dancers)
		i.dance();
}

function beatHit()
{
	for (i in dancers)
		i.dance();

	carCooldown--;
	if (carCanDrive && FlxG.random.bool(10) && carCooldown <= 0)
        driveCar();
}

// Fast car

var carCanDrive;
var carCooldown;

function resetCar() {
    car.x = -12600;
    car.velocity.x = 0;
	carCanDrive = true;
	carCooldown = FlxG.random.int(4, 8);
}

function driveCar() {
    FlxG.sound.play(Paths.soundRandom('carPass', 0, 1));
	
	car.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    carCanDrive = false;
    new FlxTimer().start(2, function(tmr:FlxTimer) {
        resetCar();
    });
}