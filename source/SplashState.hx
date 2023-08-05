package;

import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import lime.app.Application;

class SplashState extends MusicBeatState {
    override function create() {
        super.create();

        //Load Settings / Mods
        FlxSprite.defaultAntialiasing = true;
        SaveData.init();
		Controls.setupBindings();
		Preferences.setupPrefs();
        Conductor.init();
		CoolUtil.init();
		Highscore.load();
		#if cpp
		DiscordClient.initialize();
		Application.current.onExit.add (function (exitCode)DiscordClient.shutdown());
        #end

		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.6, new FlxPoint(0, -1),
		{asset: diamond, width: 32, height: 32},
		new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.4, new FlxPoint(0, 1),
		{asset: diamond, width: 32, height: 32},
		new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

        var iconz:FunkinSprite = new FunkinSprite('title/healthHeads');
        iconz.screenCenter();

        new FlxTimer().start(0.5, function(tmr:FlxTimer) {
            add(iconz);
            FlxG.sound.play(Paths.sound('intro/introSound'), 1, false, null, true, function() {
                new FlxTimer().start(0.1, function(tmr:FlxTimer) iconz.destroy() );
                new FlxTimer().start(0.5, function(tmr:FlxTimer) {
                    CoolUtil.playMusic('freakyMenu', 0);
                    FlxG.sound.music.fadeIn(4, 0, 1);
                    FlxG.switchState(new TitleState());
                });
            });
        });

    }
}