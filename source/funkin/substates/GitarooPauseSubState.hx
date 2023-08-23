package funkin.substates;

class GitarooPauseSubState extends MusicBeatSubstate
{
	var replayButton:FunkinSprite;
	var cancelButton:FunkinSprite;
	var replaySelect:Bool = false;

	public function new():Void
	{
		super();

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		add(new FunkinSprite('pauseAlt/pauseBG'));

		var bf:FunkinSprite = new FunkinSprite('pauseAlt/bfLol', [0, 30]);
		bf.addAnim('lol', 'funnyThing', 13, true);
		bf.playAnim('lol');
		bf.screenCenter(X);
		add(bf);

		replayButton = new FunkinSprite('pauseAlt/pauseUI', [FlxG.width * 0.28, FlxG.height * 0.7]);
		replayButton.addAnim('selected', 'bluereplay');
		replayButton.addAnim('static', 'yellowreplay');
		replayButton.playAnim('selected');
		add(replayButton);

		cancelButton = new FunkinSprite('pauseAlt/pauseUI', [FlxG.width * 0.58, replayButton.y]);
		cancelButton.addAnim('selected', 'bluecancel');
		cancelButton.addAnim('static', 'cancelyellow');
		cancelButton.playAnim('selected');
		add(cancelButton);

		changeThing();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float):Void
	{
		if (getKey('UI_LEFT-P') || getKey('UI_RIGHT-P'))
		{
			changeThing();
		}

		if (getKey('ACCEPT-P'))
		{
			replaySelect ? FlxG.switchState(new PlayState()) : close();
		}

		super.update(elapsed);
	}

	function changeThing():Void
	{
		replaySelect = !replaySelect;
		cancelButton.playAnim(replaySelect ? 'selected' : 'static');
		replayButton.playAnim(replaySelect ? 'static' : 'selected');
	}
}
