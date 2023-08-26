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
    if (PlayState.curSong == 'Spookeez') return;
    calcThunder();
}

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function calcThunder():Void {
    if (FlxG.random.bool(10) && PlayState.curBeat > lightningStrikeBeat + lightningOffset) {
        thunder(true); 
    }
}

var startThunder:Bool = false;

function thunder(_sound:Bool) {
    lightningStrikeBeat = PlayState.curBeat;
	lightningOffset = FlxG.random.int(8, 24);
    scaredAnim();
    if (_sound) FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    if (getPref('flashing-light')) PlayState.camGame.flash(FlxColor.fromRGB(255,255,255,125), Conductor.crochetMills * 2, null, true);

    startThunder = true;
    getSpr('bg').playAnim("thunder", true);
}

function scaredAnim() {
    PlayState.boyfriend.forceDance = false;     PlayState.boyfriend.playAnim('scared', true);
    PlayState.gf.forceDance = false;	        PlayState.gf.playAnim('scared', true);
    new FlxTimer().start(Conductor.crochetMills * 2, function(tmr:FlxTimer) {
        PlayState.boyfriend.forceDance = true;
        PlayState.gf.forceDance = true;
    });
}

function updatePost() {
    if (startThunder && getSpr('bg').animation.curAnim.curFrame == 2) {
        startThunder = false;
        getSpr("thunderBg").alpha = 1;
        getSpr("thunderLight").alpha = 1;
    }
}