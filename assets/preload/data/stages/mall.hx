var bottomBoppers:FunkinSprite;
var upperBoppers:FunkinSprite;
var santa:FunkinSprite;

function create():Void {
	var bg:FunkinSprite = new FunkinSprite('bgWalls', [-750, -450], [0.2, 0.2]);
	bg.setScale(0.8);
	addSpr(bg);

	var snowLoop:FunkinSprite = new FunkinSprite('snow loop', [-550, -400], [0.1,0.2]);
	snowLoop.setScale(0.8);
	snowLoop.addAnim('loop', 'snow loop', 24, true);
	snowLoop.playAnim('loop');
	addSpr(snowLoop);

	var snowRoof:FunkinSprite = new FunkinSprite('snow roof', [-375, -450], [0.2,0.2]);
	snowRoof.setScale(0.8);
	addSpr(snowRoof);

	upperBoppers = new FunkinSprite('upper crowd', [-450, -90], [0.33, 0.33]);
	upperBoppers.addAnim('idle', 'Upper Crowd Bob');
	upperBoppers.setScale(0.85);
	upperBoppers.dance();
	addSpr(upperBoppers);

	var bgEscalator:FunkinSprite = new FunkinSprite('bgEscalator', [-1150, -575], [0.3, 0.3]);
	bgEscalator.setScale(0.9);
	addSpr(bgEscalator);

	var floor:FlxSprite = new FlxSprite(-200, 590).makeGraphic(FlxG.width*2, FlxG.height / 2, 0xfff3f4f5);
	floor.scrollFactor.set(0, 0.3);
	addSpr(floor);

	addSpr(new FunkinSprite('christmasTree', [370, -300], [0.4, 0.4]));

	bottomBoppers = new FunkinSprite('bottom bop', [-250,140], [0.8,0.9]);
	bottomBoppers.addAnim('idle', 'Bottom Level Boppers');
	bottomBoppers.setScale(0.95);
	bottomBoppers.dance();
	addSpr(bottomBoppers);

	addSpr(new FunkinSprite('bgSnow', [-600,640]), 'bgSnow');
	addSpr(new FunkinSprite('fgSnow', [-500,757.5]), 'fgSnow', true);

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