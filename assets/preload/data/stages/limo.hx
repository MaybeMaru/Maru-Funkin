var grpLimoDancers:Array<FunkinSprite>;
var fastCar:FlxSprite = null;

var fastCarCanDrive:Bool = true;

function create():Void {
    PlayState.defaultCamZoom = 0.9;

	var skyBG:FunkinSprite = new FunkinSprite('limo/limoSunset', [-120,-50],[0.1,0.1]);
	addSpr(skyBG, 'skyBG');

	var bgLimo:FunkinSprite = new FunkinSprite('limo/bgLimo',[-200, 480], [0.4, 0.4], ['background limo pink'], true);
	addSpr(bgLimo, 'bgLimo');

	grpLimoDancers = [];
	for (i in 0...4) {
		dancer = new FunkinSprite('limo/limoDancer', [(370 * i) + 130, bgLimo.y - 400], [0.4, 0.4], ['bg dancer sketch PINK']);
		dancer.addAnim('danceLeft', 'bg dancer sketch PINK', 24, false, CoolUtil.numberArray(14));
		dancer.addAnim('danceRight', 'bg dancer sketch PINK', 24, false, CoolUtil.numberArray(30,15));
		addSpr(dancer, 'limoDancer'+i);
		grpLimoDancers.push(dancer);
	}

	var overlayShit:FunkinSprite = new FunkinSprite('limo/limoOverlay', [-500,-600]);
	overlayShit.alpha = 0.2;
	overlayShit.blend = getBlendMode('add');
	addSpr(overlayShit, 'overlay', true);

	var limo:FunkinSprite = new FunkinSprite('limo/limoDrive', [-120, 570], [1,1], ['Limo stage'], true);
	fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));

	//Layering
	PlayState.add(PlayState.bgSpr);
	PlayState.add(PlayState.gfGroup);
	PlayState.add(limo);
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