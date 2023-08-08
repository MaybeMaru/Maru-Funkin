var grpLimoDancers:Array<FunkinSprite>;
var fastCar:FlxSpriteExt = null;

var fastCarCanDrive:Bool = true;

function create():Void {
    PlayState.defaultCamZoom = 0.9;

	var skyBG:FunkinSprite = new FunkinSprite('limo/limoSunset', [-120,-50],[0.1,0.1]);
	addSpr(skyBG, 'skyBG');

	var bgLimo:FunkinSprite = new FunkinSprite('limo/bgLimo',[-200, 480], [0.4, 0.4]);
	bgLimo.addAnim('idle', 'background limo pink', 24, true);
	bgLimo.playAnim('idle');
	addSpr(bgLimo, 'bgLimo');

	grpLimoDancers = [];
	for (i in 0...4) {
		var dancer:FunkinSprite = new FunkinSprite('limo/limoDancer', [(370 * i) + 130, bgLimo.y - 400], [0.4, 0.4]);
		dancer.addAnim('danceLeft', 'bg dancer sketch PINK', 24, false, CoolUtil.numberArray(14));
		dancer.addAnim('danceRight', 'bg dancer sketch PINK', 24, false, CoolUtil.numberArray(30,15));
		addSpr(dancer, 'limoDancer'+i);
		grpLimoDancers.push(dancer);
	}
	
	var limo:FunkinSprite = new FunkinSprite('limo/limoDrive', [-120, 570]);
	limo.addAnim('idle', 'Limo stage', 24, true);
	limo.playAnim('idle');
	fastCar = new FlxSpriteExt(-300, 160).loadImage('limo/fastCarLol');

	//Layering
	PlayState.add(PlayState.bgSpr);
	PlayState.add(PlayState.gfGroup);
	PlayState.add(limo);

	var overlayShit:FunkinSprite = new FunkinSprite('limo/limoOverlay', [-500,-600]);
	overlayShit.alpha = 0.15;
	overlayShit.blend = getBlendMode('add');
	addSpr(overlayShit, 'overlay', true);
}

function createPost():Void {
	PlayState.add(fastCar);
	resetFastCar();
}

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
    FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);
    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;
    new FlxTimer().start(2, function(tmr:FlxTimer) {
        resetFastCar();
    });
}