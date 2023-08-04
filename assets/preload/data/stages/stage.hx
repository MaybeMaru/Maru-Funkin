function create():Void {
    PlayState.defaultCamZoom = 0.9;
	var bg:FunkinSprite = new FunkinSprite('stageback', [-600, -200], [0.9,0.9]);
	addSpr(bg, 'bg');

	var stageFront:FunkinSprite = new FunkinSprite('stagefront', [-650, 600]);
	stageFront.setScale(1.1);
	addSpr(stageFront, 'stageFront');

	for (i in 0...2) {
		var right:Bool = i == 1;
		var stageLight:FunkinSprite = new FunkinSprite('stage_light', [-150 + (right ? 1300 : 0), -50], [0.95,0.95]);
		stageLight.setScale(1.1);
		stageLight.flipX = right;
		addSpr(stageLight, 'stageLight' + i);
	}

	var stageCurtains:FunkinSprite = new FunkinSprite('stagecurtains', [-500, -300], [1.3,1.3]);
	stageCurtains.setScale(0.9);
	addSpr(stageCurtains, 'stageCurtains', true);
}