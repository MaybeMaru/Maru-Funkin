var bgGirls:Array<FunkinSprite> = [];

function createPost():Void {
	var bgSky:FunkinSprite = new FunkinSprite('school/sky', [-200,0], [0.1,0.1]);
	addSpr(bgSky);

	var	bgRoad:FunkinSprite = new FunkinSprite('school/road', [-200,0], [0.95,0.95]);
	addSpr(bgRoad);

	var	bgSchool:FunkinSprite = new FunkinSprite('school/school', [-200,0], [0.6,0.9]);
	addSpr(bgSchool);

	var	bgTrees:FunkinSprite = new FunkinSprite('school/bgtrees', [-200,0], [0.85,0.85]);
	addSpr(bgTrees);

	var	petals:FunkinSprite = new FunkinSprite('school/petals', [-200,0], [0.85,0.85]);
	petals.addAnim('petals','petals',24,true);
	petals.playAnim('petals');
	addSpr(petals);

	var	bgTrunks:FunkinSprite = new FunkinSprite('school/trunks', [-200,0], [0.875,0.875]);
	addSpr(bgTrunks);

	var	fgTrees:FunkinSprite = new FunkinSprite('school/trees', [-200,0], [0.9,0.9]);
	addSpr(fgTrees);

	initShader('thornsBg', 'senpaiTrees');
	setShaderInt('senpaiTrees', 'effectType', 0);
    setShaderFloat('senpaiTrees', 'uFrequency', 5);
	setSpriteShader(fgTrees, 'senpaiTrees');

	var isRoses = State.curSong == 'Roses';
	var freaksSpr = isRoses ? 'school/bgGirlsDissuaded' : 'school/bgGirls';
	var freaksAnim = isRoses ? 'BG Girls Dissuaded' : 'BG girl pair';
	for (i in 0...4) {
		var freaks:FunkinSprite = new FunkinSprite(freaksSpr, [i * 500, 450], [0.95, 0.95]);
		freaks.addAnim('danceLeft', freaksAnim, 24, false, CoolUtil.numberArray(14));
		freaks.addAnim('danceRight', freaksAnim, 24, false, CoolUtil.numberArray(30,15));
		addSpr(freaks);
		bgGirls.push(freaks);
	}

	for (i in [bgSky, bgSchool, bgRoad, bgTrees,petals, bgTrunks, fgTrees].concat(bgGirls))
		i.setScale(6);

	if (isRoses) {
		initShader('rosesBg', 'rosesBg');
		for (i in [bgSky, bgSchool, petals])
			setSpriteShader(i, 'rosesBg');
	}

	danceFreaks();
}

function danceFreaks(){
	for (i in bgGirls) {
		i.dance();
	}
}

function beatHit(curBeat):Void {
    danceFreaks();
}

function startTimer():Void {
	danceFreaks();
}