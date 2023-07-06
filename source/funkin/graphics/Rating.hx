package funkin.graphics;

class Rating extends FlxTypedSpriteGroup<RatingSprite> {
    public var targetSpr:FlxSprite = null;

    public function new():Void {
        super();
        screenCenter();
    }

    var lastComboSpr:RatingSprite = null;
    var lastSickSpr:RatingSprite = null;

    public function ratingDisplay(rating:String, combo:Int, comboStart:Int = 10):Void {
        sickRating(rating);
        if (combo >= comboStart) {
            comboNumRating(combo);
        }
    }

    public function sickRating(daRating:String = 'sick'):Void {
        var ratingSpr:RatingSprite = getRatingSpr();
        ratingSpr.setupRating(daRating);
        ratingSpr.tweenDissapear(1);
        lastSickSpr = ratingSpr;
        add(ratingSpr);
    }

    public function comboRating():Void {
        var comboSpr:RatingSprite = getRatingSpr();
        comboSpr.setupRating('combo');
        comboSpr.tweenDissapear(1.5);
        /*comboSpr.scale.x /= 1.25;
        comboSpr.scale.y /= 1.25;
        comboSpr.updateHitbox();*/
        //comboSpr.offset.set(-40,-80);
        comboSpr.y += lastSickSpr.height;
        comboSpr.x += lastSickSpr.width/3;
        comboSpr.acceleration.y = FlxG.random.int(200, 300);
		comboSpr.velocity.y = FlxG.random.int(-140, -160);
		comboSpr.velocity.x = FlxG.random.int(-5, 5);
        lastComboSpr = comboSpr;
        add(comboSpr);
    }

    public function comboNumRating(combo:Int):Void {
        var numSplit:Array<String> = Std.string(combo).split('');
        numSplit.reverse();
        for (i in 0...numSplit.length) {
            if (combo >= 10) {
                if (i == 0) {
                    comboRating();
                    lastComboSpr.visible = !Preferences.getPref('vanilla-ui');
                }
                var numSpr:RatingSprite = getRatingSpr();
                numSpr.setupRating('nums/num${numSplit[i]}');
                numSpr.tweenDissapear(1.5);
                numSpr.x -= (numSpr.width * (i+1)) - lastSickSpr.width/3;
                numSpr.y += (lastComboSpr.height/2 - numSpr.height/2) + lastSickSpr.height;
                /*numSpr.scale.x /= 1.25;
                numSpr.scale.y /= 1.25;
                numSpr.updateHitbox();*/
                //numSpr.offset.set(lastComboSpr.offset.x, -100);
                numSpr.acceleration.y = FlxG.random.int(200, 300);
                numSpr.velocity.y = FlxG.random.int(-140, -160);
                numSpr.velocity.x = FlxG.random.float(-5, 5);
                add(numSpr);
            }
        }
    }

    function getRatingSpr():RatingSprite {
        if (Preferences.getPref('stack-rating')) {
            return new RatingSprite();
        }
        return recycle(RatingSprite);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (targetSpr != null) {
            setPosition(targetSpr.x - targetSpr.width/2, targetSpr.y - targetSpr.width/4);
        }
    }
}

class RatingSprite extends FlxSpriteUtil {
    public var lePath:String = '';

    public function new(path:String = 'sick'):Void {
        super();
        lePath = path;
        loadImage('skins/${SkinUtil.curSkin}/ratings/$path');
    }

    public function setupRating(path:String) {
       //if (lePath != path) {
            loadImage('skins/${SkinUtil.curSkin}/ratings/$path');
        //}
        setPosition(0,0);
        offset.set(0,0);
        acceleration.y = 550;
		velocity.y = FlxG.random.int(-140, -175);
		velocity.x = FlxG.random.int(0, -10);
        FlxTween.cancelTweensOf(this);
        loadSkinSettings();
    }

    public function loadSkinSettings():Void {
        var skinData = SkinUtil.getSkinData(SkinUtil.curSkin);
        setGraphicSize(Std.int(width*skinData.scale));
        updateHitbox();
        antialiasing = (skinData.antialiasing) ? Preferences.getPref('antialiasing') : false;
    }

    public function tweenDissapear(crochetMult:Float = 1):Void {
        alpha = 1;
        FlxTween.tween(this, {alpha: 0}, Conductor.stepCrochet/400, {
            onComplete: function(tween:FlxTween) {
                kill();
            },
            startDelay: Conductor.crochet * (0.001*crochetMult)
        });
    }
}