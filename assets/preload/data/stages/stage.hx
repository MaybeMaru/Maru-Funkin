function create():Void {
    PlayState.defaultCamZoom = 0.9;
	var bg:FunkinSprite = new FunkinSprite('stageback', [-600, -200], [0.9,0.9]);
	addSpr(bg, 'bg');

	var stageFront:FunkinSprite = new FunkinSprite('stagefront', [-650, 600]);
	stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
	stageFront.updateHitbox();
	addSpr(stageFront, 'stageFront');

	var stageLight:FunkinSprite = new FunkinSprite('stage_light', [-150, -50], [0.95,0.95]);
	stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
	stageLight.updateHitbox();
	addSpr(stageLight, 'stageLight');

	var stageLight_:FunkinSprite = new FunkinSprite('stage_light', [stageLight.x + 1300, stageLight.y], [0.95,0.95]);
	stageLight_.setGraphicSize(Std.int(stageLight_.width * 1.1));
	stageLight_.updateHitbox();
	stageLight_.flipX = true;
	addSpr(stageLight_, 'stageLight_');

	var stageCurtains:FunkinSprite = new FunkinSprite('stagecurtains', [-500, -300], [1.3,1.3]);
	stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
	stageCurtains.updateHitbox();
	addSpr(stageCurtains, 'stageCurtains', true);
}