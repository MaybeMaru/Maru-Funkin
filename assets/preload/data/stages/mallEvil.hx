function create():Void
{
	var bg:FunkinSprite = new FunkinSprite('evilBG', [-400, -500], [0.2, 0.2]);
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();
	addSpr(bg);

	var evilTree:FunkinSprite = new FunkinSprite('evilTree', [300, -300], [0.25, 0.25]);
	addSpr(evilTree);
	var evilSnow:FunkinSprite = new FunkinSprite('evilSnow', [-200, 700]);
	addSpr(evilSnow);
	var fgEvilSnow:FunkinSprite = new FunkinSprite('fgEvilSnow', [-575, 775]);
	addSpr(fgEvilSnow, 'fgEvilSnow', true);
}
