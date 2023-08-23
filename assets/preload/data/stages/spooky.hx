var halloweenBG:FunkinSprite;
var introOverlay:FunkinSprite;
var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function create():Void
{
	halloweenBG = new FunkinSprite('halloween_bg', [-200, -80], [1, 1]);
	halloweenBG.addAnim('static', 'halloweem bg0');
	halloweenBG.addAnim('thunder', 'halloweem bg lightning strike');
	halloweenBG.playAnim('static');
	addSpr(halloweenBG, 'halloweenBG');
}

function createPost():Void
{
	if (PlayState.curSong == 'Spookeez')
	{
		PlayState.defaultCamZoom = 1.2;
		PlayState.camGame.zoom = PlayState.defaultCamZoom;
		introOverlay = new FunkinSprite('', [-200, 0], [1, 1]).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		introOverlay.blend = getBlendMode('multiply');
		introOverlay.alpha = 0.6;
		addSpr(introOverlay, 'introOverlay', true);
	}
}

function startCountdown()
{
	PlayState.showUI(!(PlayState.curSong == 'Spookeez'));
}

// It would be so awesome, it would be so cool
var scriptedThunder:Array<Int> = [4, 144, 160, 176, 192, 208, 224];

function beatHit(curBeat)
{
	if (PlayState.curSong == 'Spookeez')
	{
		var closeThunder:Bool = false;
		for (thunder in scriptedThunder)
		{
			if (curBeat == thunder)
			{
				closeThunder = true;
				lightningStrikeShit(curBeat, true);
				break;
			}
			if (curBeat + 8 > thunder && curBeat - 8 < thunder)
			{
				closeThunder = true;
				break;
			}
		}
		if (!closeThunder)
		{
			calculateThunder(curBeat);
		}
	}
	else
	{
		calculateThunder(curBeat);
	}
}

function calculateThunder(curBeat:Int):Void
{
	if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
	{
		lightningStrikeShit(curBeat, false);
	}
}

function lightningStrikeShit(curBeat:Int, muteThunder:Bool):Void
{
	PlayState.boyfriend.forceDance = false;
	PlayState.gf.forceDance = false;
	PlayState.boyfriend.playAnim('scared', true);
	PlayState.gf.playAnim('scared', true);
	halloweenBG.playAnim('thunder');
	lightningStrikeBeat = curBeat;
	lightningOffset = FlxG.random.int(8, 24);

	new FlxTimer().start(Conductor.stepCrochet / 166, function(tmr:FlxTimer)
	{
		PlayState.boyfriend.forceDance = true;
		PlayState.gf.forceDance = true;
	});

	if (PlayState.curSong == 'Spookeez')
	{
		introOverlay.visible = false;
		PlayState.showUI(true);
		PlayState.defaultCamZoom = 1.05;
	}

	if (getPref('flashing-light'))
	{
		PlayState.camGame.flash(FlxColor.fromRGB(255, 255, 255, 125), Conductor.stepCrochet / 166, null, true);
	}

	if (!muteThunder)
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
	}
}
