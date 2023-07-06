var tankWatchtower:FunkinSprite;
var tankGround:FunkinSprite;

function create():Void {
	PlayState.defaultCamZoom = 0.9;

	var sky:FunkinSprite = new FunkinSprite('tankSky', [-400, -400], [0, 0]);
	addSpr(sky);
	
	var clouds:FunkinSprite = new FunkinSprite('tankClouds', [FlxG.random.int(-700, -100), FlxG.random.int(-20, 20)], [0.1, 0.1]);
	clouds.velocity.x = FlxG.random.float(5, 15);
	addSpr(clouds);

	var extraClouds:FunkinSprite = new FunkinSprite('tankClouds', [clouds.x-clouds.width-50,clouds.y], [0.1,0.1]);
	extraClouds.velocity.x = clouds.velocity.x;
	addSpr(extraClouds);
	
	var mountains:FunkinSprite = new FunkinSprite('tankMountains', [-300, -20], [0.2, 0.2]);
	mountains.setGraphicSize(Std.int(mountains.width * 1.2));
	mountains.updateHitbox();
	addSpr(mountains);
	
	var buildings:FunkinSprite = new FunkinSprite('tankBuildings', [-200, 0], [0.3, 0.3]);
	buildings.setGraphicSize(Std.int(buildings.width * 1.1));
	buildings.updateHitbox();
	addSpr(buildings);
	
	var ruins:FunkinSprite = new FunkinSprite('tankRuins', [-200, 0], [0.35, 0.35]);
	ruins.setGraphicSize(Std.int(ruins.width * 1.1));
	ruins.updateHitbox();
	addSpr(ruins);

	var smokeL:FunkinSprite = new FunkinSprite('smokeLeft', [-200, -100], [0.4, 0.4]);
	smokeL.addAnim('smoke', 'SmokeBlurLeft', 24, true);
	smokeL.playAnim('smoke');
	addSpr(smokeL);
	
	var smokeR:FunkinSprite = new FunkinSprite('smokeRight', [1100, -100], [0.4, 0.4]);
	smokeR.addAnim('smoke', 'SmokeRight', 24, true);
	smokeR.playAnim('smoke');
	addSpr(smokeR);
	
	tankWatchtower = new FunkinSprite('tankWatchtower', [100, 50], [0.5, 0.5]);
	tankWatchtower.addAnim('idle', 'watchtower gradient color');
	tankWatchtower.dance();
	addSpr(tankWatchtower);
						
	tankGround = new FunkinSprite('tankRolling', [300, 300],[ 0.5, 0.5]);
	tankGround.addAnim('tank', 'BG tank w lighting', 24, true);
	tankGround.playAnim('tank');
	addSpr(tankGround);
						
	var ground:FunkinSprite = new FunkinSprite('tankGround', [-420, -150]);
	ground.setGraphicSize(Std.int(ground.width * 1.15));
	ground.updateHitbox();
	addSpr(ground);
}

var tankDudes:Array<FunkinSprite> = [];
var tankDudesData:Array<Array<Dynamic>> = [
	['tank5', [1620, 700], 	[1.5, 1.5], ['fg']],
	['tank4', [1300, 900], 	[1.5, 1.5], ['fg']],
	['tank2', [450, 940], 	[1.5, 1.5], ['foreground']],
	['tank1', [-300, 750], 	[2, 0.2], 	['fg']],
	['tank0', [-500, 650], 	[1.7, 1.5], ['fg']],
	['tank3', [1300, 1200], [3.5, 2.5], ['fg']]
];

function createPost():Void {
	for (i in 0...tankDudesData.length) {
		var tankDude:FunkinSprite = new FunkinSprite(tankDudesData[i][0], tankDudesData[i][1], tankDudesData[i][2]);
		tankDude.addAnim('idle', tankDudesData[i][3]);
		tankDude.playAnim('idle', true);
		tankDudes.push(tankDude);
		addSpr(tankDude, 'tank' + i, true);
	}
}

function startTimer():Void {
	tankBop();
}
function beatHit():Void {
	tankBop();
}

function tankBop():Void {
	tankWatchtower.playAnim('idle', true);
	for (dude in tankDudes) {
		dude.playAnim('idle', true);
	}
}

function update():Void {
	moveTank();
}

var tankAngle:Float = FlxG.random.int(-90, 45);
var tankSpeed:Float = FlxG.random.float(5, 7);
var tankX:Float = 400;

function moveTank():Void {
	if (!PlayState.inCutscene) {
		tankAngle += tankSpeed * FlxG.elapsed;
		tankGround.angle = (tankAngle - 90 + 15);
		tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
		tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
	}
}