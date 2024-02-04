import flixel.effects.FlxFlicker;

var lerpColor;

function createPost() {
    bg.playAnim("static");
    bg._dynamic.thunder = function (useSound:Bool) playThunder(useSound);
    bg._dynamic.calcThunder = function () calcThunder();

    dark.makeRect(FlxG.width * 2, FlxG.height * 2, 0xff32325a);
    dark.blend = getBlendMode('multiply');
    dark.alpha = 0;
    
    thunder.blend = getBlendMode('add');
    thunder.alpha = 0;

    lerpColor = new FlxColor();

    var target = 0xFFD6D6F0;
    State.boyfriendGroup.color = target;
    State.dadGroup.color = target;
    State.gfGroup.color = target;
    
    thunder._dynamic.update = function (e) {
        var speed = e * 1.25;
        thunder.alpha -= speed;
        dark.alpha -= speed;
        lerpColor.lerp(target, 0.03, true);

        var color = lerpColor.get();
        State.boyfriendGroup.color = color;
        State.dadGroup.color = color;
        State.gfGroup.color = color;
    }
}

function beatHit() {
    if (State.curSong != 'Spookeez')
        calcThunder();
}

var beat = 0;
var cooldown = 8;

function calcThunder() {
    if (FlxG.random.bool(10) && State.curBeat > beat + cooldown)
        playThunder(true);
}

function playThunder(useSound:Bool) {
    beat = State.curBeat;
	cooldown = FlxG.random.int(8, 24);
    lerpColor.set(50, 50, 90);

    dark.alpha = 1;
    thunder.alpha = 1;
    bg.playAnim("thunder", true);

    if (useSound) FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    thunderScared();

    if (getPref('flashing-light')) {
        FlxFlicker.flicker(thunder, Conductor.crochetMills * 2, 1.5 / 24);
        State.camGame.flash(0x6cffffff, Conductor.crochetMills * 2, null, true);
    }
}

function thunderScared() {
    State.boyfriend.forceDance = false;
    State.boyfriend.playAnim('scared', true);

    State.gf.forceDance = false;
    State.gf.playAnim('scared', true);
    
    new FlxTimer().start(Conductor.crochetMills * 2, function(tmr:FlxTimer) {
        State.boyfriend.forceDance = true;
        State.gf.forceDance = true;
    });
}

function updatePost(e) {
    State.boyfriendGroup.color = FlxColor.interpolate(State.boyfriend.color, FlxColor.WHITE, e * 2);
    State.dadGroup.color = State.boyfriendGroup.color;
    State.gfGroup.color = State.boyfriendGroup.color;
}

function openGameOverSubstate() {
    if (State.boyfriend.curCharacter == "tankman") {
        openTankmanGameover();
        return STOP_FUNCTION;
    }
}

function openTankmanGameover() {
    State.persistentUpdate = false;
    State.persistentDraw = false;
	Conductor.stop();

    var spook = function () {
        State.camGame.flash(FlxColor.WHITE, 2, null, true);
        return FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    }
    var tankSub:MusicBeatSubstate = new MusicBeatSubstate();
    CoolUtil.setGlobalManager(false);
    CoolUtil.playMusic("scarySwings", 0.4);
    
    var bg = new FunkinSprite("tankman/spookyBg", [-150,-50], [0,0]);
    bg.setScale(1.5);
    tankSub.add(bg);

    var tank = new FunkinSprite("tankman/spookyTankman", [300,270], [0,0]);
    tank.addAnim("dance", "dance", 48, true);
    tank.playAnim("dance");
    tankSub.add(tank);

    var didTrans:Bool = false;
    tankSub._update = function() {
        tank.setScale(1.75);
        if (!didTrans && getKey('ACCEPT-P')) {
            didTrans = true;
            spook().fadeOut(1.5);
            FlxG.sound.music.fadeOut();
            State.camGame.fade(FlxColor.BLACK, 1.75);
            new FlxTimer().start(2, function (tmr:FlxTimer) {
                CoolUtil.resetState();
            });
        }
    }
    State.openSubState(tankSub);
    spook();
}