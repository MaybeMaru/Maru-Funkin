var grpLimoDancers:Array<FunkinSprite> = [];
var fastCar:FlxSpriteExt;
var metalPos:FlxSpriteExt;
var bgLimo:FunkinSprite;

var _lastTime:Float = -9999;

var vroomVroom:Array<FlxSound> = [];
var goreSound:FlxSound;

function create():Void {
    PlayState.defaultCamZoom = 0.9;
	metalPos = new FlxSpriteExt(-400, 125);

	var skyBG:FunkinSprite = new FunkinSprite('limo/limoSunset', [-120,-50],[0.1,0.1]);
	PlayState.add(skyBG);

	var metalPole:FunkinSprite = new FunkinSprite('limo/metalPole', [0,0], [0.4,0.4]);
	metalPole._dynamic.update = function (elapsed) metalPole.setPosition(metalPos.x, metalPos.y);
	PlayState.add(metalPole);

	bgLimo = new FunkinSprite('limo/bgLimo',[-200, 480], [0.4, 0.4]);
	bgLimo.addAnim('idle', 'background limo pink', 24, true);
	bgLimo.playAnim('idle');
	PlayState.add(bgLimo);

	grpLimoDancers = [];
	for (i in 0...4) {
		var dancer:FunkinSprite = new FunkinSprite('limo/limoDancer', [(370 * i) + 130, bgLimo.y - 400], [0.4, 0.4]);
		dancer.addAnim('danceLeft', 'bg dancer sketch PINK', 24, false, CoolUtil.numberArray(14));
		dancer.addAnim('danceRight', 'bg dancer sketch PINK', 24, false, CoolUtil.numberArray(30,15));
		dancer._dynamic.initPos = dancer.x;
		dancer._dynamic.dead = false;
		dancer._dynamic.update = function (elapsed) {
			dancer.visible = !dancer._dynamic.dead;
		}
		PlayState.add(dancer);
		grpLimoDancers.push(dancer);
	}

	makeGroup('boogieDeathGrp');

	var highwayLight:FunkinSprite = new FunkinSprite('limo/highwayLight', [0,0], [0.4,0.4]);
	highwayLight.offset.set(200, 30);
	highwayLight._dynamic.update = function (elapsed) highwayLight.setPosition(metalPos.x, metalPos.y);
	PlayState.add(highwayLight);
	
	var limo:FunkinSprite = new FunkinSprite('limo/limoDrive', [-120, 570]);
	limo.addAnim('idle', 'Limo stage', 24, true);
	limo.playAnim('idle');

	fastCar = new FlxSpriteExt(-300, 160).loadImage('limo/fastCarLol');
	addSpr(fastCar, 'fastCar', true);
	resetFastCar();

	//Layering
	PlayState.add(PlayState.bgSpr);
	PlayState.add(PlayState.gfGroup);
	PlayState.add(limo);

	var overlayShit:FunkinSprite = new FunkinSprite('limo/limoOverlay', [-500,-600]);
	overlayShit.alpha = 0.15;
	overlayShit.blend = getBlendMode('add');
	addSpr(overlayShit, 'overlay', true);

	// caching?
	vroomVroom = [getSound('carPass0'), getSound('carPass1')];
	for (sound in vroomVroom) sound.volume = 0.7;
	goreSound = getSound('gore');
	goreSound.volume = 0.7;
}

// Car shit

var fastCarCanDrive:Bool = true;

function beatHit(curBeat):Void {
	limoDancerDance();
    if (FlxG.random.bool(10) && fastCarCanDrive) {
        fastCarDrive();
	}
}

function startTimer():Void {
	limoDancerDance();
}

function limoDancerDance():Void {
	for (dancer in grpLimoDancers) {
		dancer.dance();
	}	
}

function resetFastCar():Void {
    fastCar.x = -12600;
    fastCar.y = FlxG.random.int(140, 250);
    fastCar.velocity.x = 0;
    fastCarCanDrive = true;
}

function fastCarDrive():Void {
	vroomVroom[FlxG.random.int(0, 1)].play();
    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;
    new FlxTimer().start(2, function(tmr:FlxTimer) {
        resetFastCar();
    });
}

// Gore shit

var killin:Bool = false;
var canKill:Bool = true;
var killCount:Int = 0;
var murdered:Bool = false;
var calcMurder:Bool = false;

function updatePost() {
	if (!calcMurder) {
		return;
	}

	var _pos = Math.min((Conductor.songPosition - _lastTime - 200) * 6, 2000);
	killin = _pos < 2000;
	metalPos.x = _pos;

	if (killin) {
		for (i in grpLimoDancers) {
			if (!i._dynamic.dead && _pos >= i.x) {
				i._dynamic.dead = true;
				canKill = false;
				dancerDeath(i);
				if (killCount == 0) {
					if (PlayState.gf._dynamic.dodge != null) {
						PlayState.gf._dynamic.dodge();
					}
				}
				killCount++;
			}
		}
	} else
		killCount = 0;

	if (killin && killCount >= 4 && !murdered) {
		murdered = true;
		var _time = Conductor.crochet * 0.001 * 2;
		var _offPos = FlxG.width * 1.5;

		FlxTween.tween(bgLimo, {x: _offPos - 200}, _time * 0.5, {
			onComplete: function(twn:FlxTween) {
				new FlxTimer().start( Conductor.crochet * 0.001 * 4, function(tmr) {
					FlxTween.tween(bgLimo, {x: -200}, _time, {ease: FlxEase.backOut, // go back limo
						onComplete: function(twn:FlxTween) {
							canKill = true;
							murdered = false;
							calcMurder = false;
					}});
					for (dancer in grpLimoDancers) { // go back boogie
						dancer._dynamic.dead = false;
						dancer.x = dancer._dynamic.initPos + _offPos;
						FlxTween.tween(dancer, {x: dancer._dynamic.initPos}, _time, {ease: FlxEase.backOut});
					}
				});
			}
		});
	}
}

function jumpSpr(spr) {
	spr.acceleration.y = FlxG.random.float(800, 1000);
	spr.velocity.y = FlxG.random.float(-140, -160);
	spr.velocity.x = FlxG.random.float(-50, 50);
}

function getRandom() {
	return FlxG.random.int(-100,100);
}

function dancerDeath(dancer):Void {
	var mainSpr = getGroup('boogieDeathGrp').recycle(FunkinSprite).loadImage('limo/henchmenGore');
	var midPos = [dancer.x + dancer.width / 3, dancer.y + dancer.height / 3];
	mainSpr.scrollFactor.set(0.4,0.4);
	mainSpr.acceleration.set();
	mainSpr.velocity.set();
	getGroup('boogieDeathGrp').add(mainSpr);

	if (FlxG.random.bool(66) && getPref('naughty')) {
		var _arr = [mainSpr];
		mainSpr.addAnim("headSpin", FlxG.random.bool() ? "hench head spin PINK" : "hench head spin 2 PINK", 24, true);
		mainSpr.playAnim("headSpin", true);
		mainSpr.setPosition(midPos[0] + getRandom(), midPos[1] + getRandom());
		jumpSpr(mainSpr);

		for (i in 0...2) {
			var part =  getGroup('boogieDeathGrp').recycle(FunkinSprite).loadImage('limo/henchmenGore');
			part.setPosition(midPos[0] + getRandom(), midPos[1] + getRandom());
			part.scrollFactor.set(0.4,0.4);
			getGroup('boogieDeathGrp').add(part);

			var _anim = FlxG.random.bool() ? "" : " 2";
			var _part = i == 0 ? "leg" : "arm";//"hench leg spin PINK0007"
			part.addAnim("part", "hench " + _part + " spin" + _anim + " PINK", 24, true);
			part.playAnim("part");
			jumpSpr(part);
			_arr.push(part);
		}

		new FlxTimer().start(Conductor.crochet * 0.001 * 4, function(tmr) {
			for (i in _arr)
				i.kill();
		});
	} else {
		mainSpr.addAnim("onRail", "Henchmen on rail " + FlxG.random.int(1,2) + " PINK");//"Henchmen on rail " + FlxG.random.int(1,2) + " PINK");
		mainSpr.playAnim("onRail", true);
		mainSpr.offset.set(275 + FlxG.random.int(-15,15), -25 + FlxG.random.int(-15,15));
		mainSpr.setPosition(metalPos.x, 0);
		mainSpr._dynamic.update = function (elapsed) {
			mainSpr.x = metalPos.x;
			if (mainSpr.x >= FlxG.width * 1.5)
				mainSpr.kill();
		}
	}

	if (FlxG.random.bool(33) && getPref('naughty')) { // blood
		var blood = getGroup('boogieDeathGrp').recycle(FunkinSprite).loadImage('limo/blood');
		blood.scrollFactor.set(0.4, 0.4);
		blood.setPosition(metalPos.x, midPos[1]);
		blood.flipX = true;
		blood.addAnim('blood', 'blood 1');
		blood.playAnim('blood', true, false, FlxG.random.int(0, 2));
		getGroup('boogieDeathGrp').add(blood);
		blood._dynamic.update = function (elapsed) {
			if (blood.animation.curAnim.finished)
				blood.kill();
		}
	}
}

function sectionHit(curSection):Void {
	if (canKill && FlxG.random.bool(20))
		killBoogies();
}

function killBoogies() {
	goreSound.play();
	_lastTime = Conductor.songPosition;
	calcMurder = true;
}