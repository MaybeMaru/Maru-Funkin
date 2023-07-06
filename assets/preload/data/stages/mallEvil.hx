function create():Void {
	var bg:FunkinSprite = new FunkinSprite('christmas/evilBG', [-400,-500], [0.2,0.2]);
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();
	addSpr(bg);
	
	var evilTree:FunkinSprite = new FunkinSprite('christmas/evilTree', [300,-300], [0.25,0.25]);
	addSpr(evilTree);
	var evilSnow:FunkinSprite = new FunkinSprite('christmas/evilSnow', [-200,700]);
	addSpr(evilSnow);
	var fgEvilSnow:FunkinSprite = new FunkinSprite('christmas/fgEvilSnow', [-575, 775]);
	addSpr(fgEvilSnow, 'fgEvilSnow', true);
}