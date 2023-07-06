package funkin.states;

/*  
 *  State to test shit, this shouldnt even be public lol
 */

class TestingState extends MusicBeatState {

    var testGrp:FlxGroup;

    function init():Void {
        FlxG.debugger.drawDebug = true;
        FlxG.save.bind('funkin');
        Controls.setupBindings();
        Preferences.setupPrefs();
        CoolUtil.init();
        Highscore.load();

        Conductor.songPosition = 0;
    }

    override function create() {
        super.create();
        init();

        /*testGrp = new FlxGroup();
        add(testGrp);
        for (i in 0...50) {
            var testSpr:FlxSprite = new FlxSprite(FlxG.random.int(0,FlxG.width),FlxG.random.int(0,FlxG.height)).makeGraphic(10,10,FlxColor.RED);
            testGrp.add(testSpr);
        }

        var testMouse:MouseSelector = new MouseSelector(testGrp);
        add(testMouse);*/
        
        var conductorBar:FlxSprite = new FlxSprite().makeGraphic(500, 5,FlxColor.WHITE);
        conductorBar.screenCenter();
        conductorBar.y -= Preferences.getPref('downscroll') ? -FlxG.height/4 : FlxG.height/4;
        add(conductorBar);

        for (i in 0...16*4) {
            var testNote:NoteCool = new NoteCool(100 + i * 200, i%4, 100 + i%4 * 100);
            testNote.targetSpr = conductorBar;
            add(testNote);
            testNote.x = FlxG.width/4 + 100 * i%4;
            testNote.y = FlxG.height/4;
        }

    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        debugUtil();

        Conductor.songPosition+=elapsed*1000;
    }

    function debugUtil():Void {
        if (FlxG.keys.justPressed.NINE) {
            FlxG.resetState();
        }
        if (FlxG.keys.justPressed.EIGHT) {
            Preferences.setPref('downscroll', !Preferences.getPref('downscroll'));
        }
    }
}

class NoteCool extends FlxTypedSpriteGroup<FlxSpriteUtil> {
    var noteSpr:FlxSpriteUtil;
    var susSpr:FlxSpriteUtil;
    var susTailSpr:FlxSpriteUtil;

    public var strumTime:Float = 0;
    public var noteData:Int = 0;
    public var susLength(default, set):Float = 0;

    public var targetSpr:FlxSprite = null;

    public function new(strumTime:Float = 0, noteData:Int = 0, susLength:Float = 0):Void {
        super();
        this.noteData = noteData;
        loadNoteGraphics();

        this.strumTime = strumTime;
        this.susLength = susLength;
    }

    public function loadNoteGraphics():Void {
        var skinPath:String = "skins/default/noteAssets";

        var colors:Array<String> = ['purple', 'blue', 'green', 'red'];
        var anims:Array<String> = [' hold end0',' hold piece0','0'];

        for (i in 0...3) {
            var spr = new FlxSpriteUtil();
            spr.loadImage(skinPath);
            spr.antialiasing = true;
            spr.addAnim('static', '${colors[noteData]}${anims[i]}');
            spr.playAnim('static');
            spr.updateHitbox();
            var scaleOffset:Float = 0.7;
            spr.setGraphicSize(Std.int(spr.width*scaleOffset),Std.int(spr.height*scaleOffset));
            switch (i) {
                case 2: 
                    spr.updateHitbox();
                default:
                    updateHitboxCustom(spr);
                    spr.alpha = 0.6;
            }
            switch (i) {
                case 2: 
                    noteSpr = spr;
                    add(noteSpr);
                case 1: 
                    susSpr = spr;
                    add(susSpr);
                    susSpr.clipRect = new FlxRect(0, 0, susSpr.frameWidth, susSpr.frameHeight-1);
                case 0:
                    susTailSpr = spr;
                    add(susTailSpr);
            }
        }
    }

    var songSpeed(default, set):Float = 1;
    public function set_songSpeed(val:Float):Float {
        if (val < 0.1) {
            val = 0.1;
        }
        songSpeed = val;
        set_susLength(susLength);
        return val;
    }

    public function set_susLength(val:Float):Float {
        val = Math.floor(val);
        susSpr.visible = val > 0;
        susTailSpr.visible = val > 0;
        susLength = val;
        if (val > 0) {
            susSpr.origin.y = 0;
            susSpr.scale.y = val / 100 * 1.5 * songSpeed;

            updateHitboxCustom(susSpr);
            updateHitboxCustom(susTailSpr);

            susSpr.origin.x = susSpr.width/2;
            susTailSpr.origin = susSpr.origin;

            var downScroll:Bool = Preferences.getPref('downscroll');
            susSpr.scale.y = (susSpr.height + (susSpr.height / susSpr.frameHeight) + (downScroll ? 0 : 0.15)) / susSpr.frameHeight;
            susSpr.scale.y *= downScroll ? -1 : 1;
            susTailSpr.scale.y = downScroll ? -0.7 : 0.7;
            updateSusPos();
        }
        return val;
    }

    function updateHitboxCustom(spr:FlxSpriteUtil):Void {
        spr.width = Math.abs(spr.scale.x) * spr.frameWidth;
        spr.height = Math.abs(spr.scale.y) * spr.frameHeight;
    }

    function updateSusPos():Void {
        susSpr.x = noteSpr.x + noteSpr.width/2 - susSpr.width/2 - 5;
        susSpr.y = noteSpr.y + noteSpr.height/2;
        susTailSpr.x = susSpr.x;
        susTailSpr.y = susSpr.y + (Preferences.getPref('downscroll') ? -susSpr.height : susSpr.height);
    }

    override public function update(elp:Float):Void {
        super.update(elp);

        if (targetSpr != null) {
            var noteMove = (Conductor.songPosition - strumTime) * 0.45 * songSpeed;
            y = targetSpr.y - (Preferences.getPref('downscroll') ? -noteMove : noteMove);
            calculateHit();
        }
    }

    public var inSustain:Bool = false; // If in the current song position the sustain key should be pressed
    public var mustPress:Bool = false; // If the note should or not be on the player's lane

    public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var willMiss:Bool = false;

	public function calculateHit():Void {
		if (mustPress) {
			if (willMiss && !wasGoodHit) {
				tooLate = true;
				canBeHit = false;
			}
			else {
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset) {
					if (strumTime < Conductor.songPosition + 0.5 * Conductor.safeZoneOffset) {
						canBeHit = true;
					}
				}
				else {
					willMiss = true;
					canBeHit = true;
				}
			}
		}
		else {
			canBeHit = false;
			if (strumTime <= Conductor.songPosition) {
				wasGoodHit = true;
			}
		}
        handleSustains();
	}

    function handleSustains():Void {
        if (strumTime <= Conductor.songPosition && strumTime + susLength >= Conductor.songPosition) {
            //trace('IN SUSSS');
        }

        var susParts = [susTailSpr, susSpr];
        var downscroll = Preferences.getPref('downscroll');

        for (i in 0...susParts.length) {
            var daNote = susParts[i];
            var center = targetSpr.y + (targetSpr.height / 2);
            var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight-i);

            if ((!downscroll ? daNote.y + daNote.offset.y * daNote.scale.y <= center :
                daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)) {
                if (!downscroll) {
                    swagRect.y = (center - daNote.y) / daNote.scale.y;
                    swagRect.height -= swagRect.y;
                } else {
                    swagRect.y = daNote.frameHeight - swagRect.height;
                    swagRect.height = (center - daNote.y) / daNote.scale.y;
                }
                daNote.clipRect = swagRect;
            }
        }
    }
}

/*
class MouseSelector extends FlxSprite {
    var clickPos:FlxPoint;
    var detectGroup:FlxGroup;
    var curDetectedObjs:Array<Dynamic> = [];

    public function new(?detectGroup:FlxGroup) {
        super();
        clickPos = new FlxPoint();
        this.detectGroup = (detectGroup != null) ? detectGroup : new FlxGroup();
        makeGraphic(FlxG.width,FlxG.height, FlxColor.fromRGB(255,255,255,125));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.mouse.justPressed) {
            clickPos.set(FlxG.mouse.screenX,FlxG.mouse.screenY);
            selectedObjsShine(true);
        }

        if (FlxG.mouse.pressed) {
            visible = true;
            setPosition(clickPos.x,clickPos.y);
            var targetScales:FlxPoint = new FlxPoint(FlxG.mouse.screenX-clickPos.x,FlxG.mouse.screenY-clickPos.y);
            var widthBox = Std.int(Math.abs(targetScales.x));   var heightBox = Std.int(Math.abs(targetScales.y));
            if (widthBox==0) widthBox = 1;                      if (heightBox==0) heightBox = 1;
            if (targetScales.x < 0) x += targetScales.x;        if (targetScales.y < 0) y += targetScales.y;
            setGraphicSize(widthBox,heightBox);
            updateHitbox();
            objDetection();
        } else {
            visible = false;
            setPosition(FlxG.mouse.screenX,FlxG.mouse.screenY);
            selectedObjsShine();
            xcvCheck();
        }
    }

    function objDetection():Void {
        curDetectedObjs = [];
        FlxG.overlap(this, detectGroup, touched);
    }

    function touched(obj1:Dynamic, obj2:Dynamic):Void {
        if (!curDetectedObjs.contains(obj2)) {
            curDetectedObjs.push(obj2);
        }
    }

    var shineElp:Float = 0;
    function selectedObjsShine(cancel:Bool = false):Void {
        shineElp+=FlxG.elapsed*10;
        shineElp=shineElp%180;
        for (obj in curDetectedObjs) {
            obj.offset.y = cancel ? 0 : Math.abs(Math.sin(shineElp))*10;
        }
    }

    function xcvCheck():Void {
        if (FlxG.keys.pressed.CONTROL) {
            if (FlxG.keys.justPressed.X)        cut();
            else if (FlxG.keys.justPressed.C)   copy();
            else if (FlxG.keys.justPressed.V)   paste();
        }
    }

    var copyArray:Array<Dynamic> = [];
    function cut():Void {
        if (curDetectedObjs.length > 0) {
            copyArray = [];
            for (obj in curDetectedObjs) {
                copyArray.push(obj);
                obj.kill();
            }
            curDetectedObjs = [];
        }

    }
    function copy():Void {
        copyArray = [];
        if (curDetectedObjs.length > 0) {
            for (obj in curDetectedObjs) {
                copyArray.push(obj);
            }
        }
    }
    function paste():Void {
        if (curDetectedObjs.length > 0) {
            for (obj in copyArray) {
                if (!obj.alive) {   //CUT
                    obj.revive();
                } else {            //COPY
                    var copyObj:Dynamic = Reflect.copy(obj);
                    copyObj.offset.x += 10;
                    detectGroup.add(copyObj);
                }
            }
        }
    }
}*/