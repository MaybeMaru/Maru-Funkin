var bgGirls:FunkinSprite;

function create():Void {
	var bgSky:FunkinSprite = new FunkinSprite('weeb/weebSky', [0,0], [0.1,0.1]);
	addSpr(bgSky);
	var	bgSchool:FunkinSprite = new FunkinSprite('weeb/weebSchool', [-200,0], [0.6,0.9]);
	addSpr(bgSchool);
	var	bgStreet:FunkinSprite = new FunkinSprite('weeb/weebStreet', [-200,0], [0.95,0.95]);
	addSpr(bgStreet);
	var	fgTrees:FunkinSprite = new FunkinSprite('weeb/weebTreesBack', [-30,130], [0.9,0.9]);
	addSpr(fgTrees);

	var	bgTrees:FunkinSprite = new FunkinSprite('weeb/weebTrees', [-580,-800], [0.85,0.85]);
	bgTrees.animation.add('treeLoop', CoolUtil.numberArray(18), 12);
	bgTrees.animation.play('treeLoop');
	addSpr(bgTrees);
	var	treeLeaves:FunkinSprite = new FunkinSprite('weeb/petals', [-200,-40], [0.85,0.85]);
	treeLeaves.addAnim('leaves', 'PETALS ALL', 24, true);
	treeLeaves.playAnim('leaves');
	addSpr(treeLeaves);

	var widShit = Std.int(bgSky.width*6);
	var scaleStuff:Array<FunkinSprite> = [bgSky,bgSchool,bgStreet,treeLeaves];
	for (obj in scaleStuff) {
		obj.setGraphicSize(widShit);
		obj.updateHitbox();
	}

	bgTrees.setGraphicSize(Std.int(widShit * 1.4));
	fgTrees.setGraphicSize(Std.int(widShit * 0.8));
	bgTrees.updateHitbox();
	fgTrees.updateHitbox();

	bgGirls = new FunkinSprite('weeb/bgFreaks', [-50,435], [0.9,0.9], ['BG girls group']);
	bgGirls.addAnim('danceLeft', 'BG girls group', 24, false, CoolUtil.numberArray(14));
	bgGirls.addAnim('danceRight', 'BG girls group', 24, false, CoolUtil.numberArray(30,15));
	addSpr(bgGirls);
}


function createPost():Void {
	if (PlayState.curSong.toLowerCase() == 'roses') {	//	MAKE THEM ANGRY IN ROSES
		bgGirls.addAnim('danceLeft', 'BG fangirls dissuaded', 24, false, CoolUtil.numberArray(14));
		bgGirls.addAnim('danceRight', 'BG fangirls dissuaded', 24, false, CoolUtil.numberArray(30,15));
	}
	bgGirls.dance();
	bgGirls.setGraphicSize(Std.int(bgGirls.width * 6));
	bgGirls.updateHitbox();
	bgGirls.dance();
}

function beatHit(curBeat):Void {
    bgGirls.dance();
}

function startTimer():Void {
	bgGirls.dance();
}