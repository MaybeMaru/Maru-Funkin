var bottomBoppers:FunkinSprite;
var upperBoppers:FunkinSprite;
var santa:FunkinSprite;

function create():Void {
    PlayState.defaultCamZoom = 0.8;

	var bg:FunkinSprite = new FunkinSprite('christmas/bgWalls', [-1000, -500], [0.2, 0.2]);
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();
	addSpr(bg);

	var snowRoof:FunkinSprite = new FunkinSprite('christmas/snowRoof', [0,0], [0.2,0.2]);
	snowRoof.addAnim('snowFall', 'snowFall', 24, true);
	snowRoof.playAnim('snowFall');
	addSpr(snowRoof);

	upperBoppers = new FunkinSprite('christmas/upperBop', [-45,-100], [0.33,0.33]);
	upperBoppers.addAnim('idle', 'upperBop');
	upperBoppers.dance();
	addSpr(upperBoppers);

	var bgEscalator:FunkinSprite = new FunkinSprite('christmas/bgEscalator', [-1100,-600], [0.3, 0.3]);
	bgEscalator.setGraphicSize(Std.int(bgEscalator.width*0.9));
	bgEscalator.updateHitbox();
	addSpr(bgEscalator);

	var tree:FunkinSprite = new FunkinSprite('christmas/christmasTree', [370,-250], [0.4, 0.4]);
	addSpr(tree);

	bottomBoppers = new FunkinSprite('christmas/bottomBop', [-300,140], [0.9,0.9]);
	bottomBoppers.addAnim('idle', 'Bottom Level Boppers');
	bottomBoppers.dance();
	addSpr(bottomBoppers);

	var bgSnow:FunkinSprite = new FunkinSprite('christmas/bgSnow', [-600,700]);
	addSpr(bgSnow);

	var fgSnow:FunkinSprite = new FunkinSprite('christmas/fgSnow', [-700,765]);
	fgSnow.active = false;
	addSpr(fgSnow, 'fgSnow',true);

    //Offsetting
	bg.screenCenter();
	bg.y -= 250/4;
	snowRoof.screenCenter();
	snowRoof.y -= 455;
	snowRoof.x -= 775;
	bgEscalator.y += 250/2;
	bgEscalator.y += 5;

	santa = new FunkinSprite('christmas/santa', [-415,75]);
	santa.addAnim('idle', 'santa idle in fear');
	addSpr(santa, 'santa', true);
}

function mallDance():Void {
	upperBoppers.dance();
	bottomBoppers.dance();
	santa.dance();
}

function beatHit():Void {
	mallDance();
}
function startTimer():Void {
	mallDance();
}