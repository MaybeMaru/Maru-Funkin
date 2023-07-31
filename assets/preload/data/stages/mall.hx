var bottomBoppers:FunkinSprite;
var upperBoppers:FunkinSprite;
var santa:FunkinSprite;

function create():Void {
    PlayState.defaultCamZoom = 0.8;

	var bg:FunkinSprite = new FunkinSprite('bgWalls', [-750, -450], [0.2, 0.2]);
	bg.scale.set(0.8,0.8);
	bg.updateHitbox();
	addSpr(bg);

	var snowLoop:FunkinSprite = new FunkinSprite('snow loop', [-550, -400], [0.1,0.2]);
	snowLoop.scale.set(0.8,0.8);
	snowLoop.updateHitbox();
	snowLoop.addAnim('loop', 'snow loop', 24, true);
	snowLoop.playAnim('loop');
	addSpr(snowLoop);

	var snowRoof:FunkinSprite = new FunkinSprite('snow roof', [-375, -450], [0.2,0.2]);
	snowRoof.scale.set(0.8,0.8);
	snowRoof.updateHitbox();
	addSpr(snowRoof);

	upperBoppers = new FunkinSprite('upper crowd', [-450, -90], [0.33, 0.33]);
	upperBoppers.addAnim('idle', 'Upper Crowd Bob');
	upperBoppers.scale.set(0.85,0.85);
	upperBoppers.updateHitbox();
	upperBoppers.dance();
	addSpr(upperBoppers);

	var bgEscalator:FunkinSprite = new FunkinSprite('bgEscalator', [-1150, -575], [0.3, 0.3]);
	bgEscalator.scale.set(0.9,0.9);
	bgEscalator.updateHitbox();
	addSpr(bgEscalator);

	var floor:FlxSprite = new FlxSprite(-200, 590).makeGraphic(FlxG.width*2, FlxG.height / 2, 0xfff3f4f5);
	floor.scrollFactor.set(0, 0.3);
	addSpr(floor);

	var tree:FunkinSprite = new FunkinSprite('christmasTree', [370, -300], [0.4, 0.4]);
	addSpr(tree);

	bottomBoppers = new FunkinSprite('bottom bop', [-250,140], [0.9,0.9]);
	bottomBoppers.addAnim('idle', 'Bottom Level Boppers');
	bottomBoppers.scale.set(0.95,0.95);
	bottomBoppers.updateHitbox();
	bottomBoppers.dance();
	addSpr(bottomBoppers);

	addSpr(new FunkinSprite('bgSnow', [-600,640]), 'bgSnow');
	addSpr(new FunkinSprite('fgSnow', [-500,750]), 'fgSnow', true);

	santa = new FunkinSprite('santa', [-750,175]);
	santa.addAnim('idle', 'santa idle in fear');
	addSpr(santa, 'santa', true);
}

function mallDance():Void {
	upperBoppers.playAnim('idle', true);
	bottomBoppers.playAnim('idle', true);
	santa.playAnim('idle', true);
}

function beatHit():Void {
	mallDance();
}
function startTimer():Void {
	mallDance();
}