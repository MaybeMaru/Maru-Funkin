var freaks = [];

function createPost()
{
	var freaksPath = 'school/bgGirls';
	var freaksAnim = 'BG girl pair';

	if (State.curSong == 'Roses')
	{
		freaksPath = 'school/bgGirlsDissuaded';
		freaksAnim = 'BG Girls Dissuaded';

		initShader('rosesBg', 'rosesBg');
		for (i in [sky, school, petals])
			setSpriteShader(i, 'rosesBg');
	}

	initShader('thornsBg', 'senpaiTrees');
	setShaderInt('senpaiTrees', 'effectType', 0);
    setShaderFloat('senpaiTrees', 'uFrequency', 5);
	setSpriteShader(trees, 'senpaiTrees');

	for (i in 0...4) {
		var freak = new FunkinSprite(freaksPath, [i * 500, 425 + switch (i) {
			case 0: 25;
			case 3: 25;
		}], [0.95, 0.95]);
		freak.addAnim('danceLeft', freaksAnim, 24, false, CoolUtil.numberArray(14));
		freak.addAnim('danceRight', freaksAnim, 24, false, CoolUtil.numberArray(30,15));
		freak.setScale(6, false);
		addSpr(freak, "freak-" + i, "freaks");
		freaks.push(freak);
	}
}

function dance() {
	for (freak in freaks)
		freak.dance();
}

function beatHit()
	dance();

function startTimer()
	dance();