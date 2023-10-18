function create() {
    var bg:FunkinSprite = new FunkinSprite("halloweenBg", [-200,-80]);
    bg.addAnim('static', 'strike', 24, false, [3]);
    bg.addAnim('thunder', 'strike');
    bg.playAnim('static');
    bg._dynamic.thunder = function (_sound:Bool) {
        thunder(_sound);
    }
    bg._dynamic.calcThunder = function () {
        calcThunder();
    }
    addSpr(bg, 'bg');

    var thunderBg:FlxSpriteExt = new FunkinSprite("", [-FlxG.width*0.5,-FlxG.height*0.5]).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xff32325a);
    thunderBg.blend = getBlendMode('multiply');
    thunderBg.alpha = 0;
    addSpr(thunderBg, 'thunderBg');

    var thunderLight:FunkinSprite = new FunkinSprite("lightningStrike", [250, 80]);
    thunderLight.blend = getBlendMode('add');
    thunderLight.alpha = 0;
    addSpr(thunderLight, 'thunderLight');

    thunderLight._dynamic.update = function (elapsed) {
        thunderLight.alpha -= elapsed * 1.25;
        thunderBg.alpha -= elapsed * 1.25;
    }
}

function beatHit(curBeat) {
    if (State.curSong != 'Spookeez')
        calcThunder();
}

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function calcThunder():Void {
    if (FlxG.random.bool(10) && State.curBeat > lightningStrikeBeat + lightningOffset) {
        thunder(true); 
    }
}

var startThunder:Bool = false;

function thunder(_sound:Bool) {
    lightningStrikeBeat = State.curBeat;
	lightningOffset = FlxG.random.int(8, 24);
    scaredAnim();
    if (_sound) FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    if (getPref('flashing-light')) State.camGame.flash(FlxColor.fromRGB(255,255,255,125), Conductor.crochetMills * 2, null, true);

    startThunder = true;
    getSpr('bg').playAnim("thunder", true);
}

function scaredAnim() {
    State.boyfriend.forceDance = false;     State.boyfriend.playAnim('scared', true);
    State.gf.forceDance = false;	        State.gf.playAnim('scared', true);
    new FlxTimer().start(Conductor.crochetMills * 2, function(tmr:FlxTimer) {
        State.boyfriend.forceDance = true;
        State.gf.forceDance = true;
    });
}

function updatePost() {
    if (startThunder && getSpr('bg').animation.curAnim.curFrame == 2) {
        startThunder = false;
        getSpr("thunderBg").alpha = 1;
        getSpr("thunderLight").alpha = 1;
    }
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
        var sound = new FlxSound().loadEmbedded(Paths.soundRandom('thunder_', 1, 2));
        sound.play();
        State.camGame.flash(FlxColor.WHITE, 2);
        return sound;
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
            State.camGame.fade(FlxColor.BLACK, 2);
            new FlxTimer().start(2.5, function (tmr:FlxTimer) {
                CoolUtil.resetState();
            });
        }
    }
    State.openSubState(tankSub);
    spook();
}