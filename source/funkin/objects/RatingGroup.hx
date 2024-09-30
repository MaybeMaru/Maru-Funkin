package funkin.objects;

class RatingGroup extends TypedSpriteGroup<RemoveRating>
{
    public var targetSpr:FlxObject = null;
    public var _offset:FlxPoint;

    public function new(?targetSpr:FlxSprite):Void {
        super();
        this.targetSpr = targetSpr;
        _offset = FlxPoint.get();
        if (targetSpr is FlxSprite)
            _offset.set(targetSpr.frameWidth * targetSpr.scale.x, targetSpr.frameHeight * targetSpr.scale.y);

        // Cache default ratings
        add(new JudgeRating());
        add(new ComboRating());
        for (i in 0...3) add(new NumRating());
        clearGroup();
    }

    public function clearGroup() {
        members.fastForEach((rating, i) -> rating.kill());
    }

    override function destroy() {
        super.destroy();
        _offset = FlxDestroyUtil.put(_offset);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (targetSpr != null) {
            setPosition(targetSpr.x - _offset.x * 0.5, targetSpr.y - _offset.y * 0.5);
        }
    }

    public function drawCombo(combo:Int):Void
    {
        if (combo < 10)
            return;

        if (!cast(Preferences.getPref('vanilla-ui'), Bool)) {
            final comboSpr:ComboRating = cast(recycle(ComboRating), ComboRating);
            comboSpr.init();
            addTop(comboSpr);
        }

        var nums:String = Std.string(combo);
        var l:Int = nums.length;
        var i:Int = l;

        while (i > 0) {
            i--;
            final num:NumRating = cast(recycle(NumRating, null), NumRating);
            num.init(nums.charAt(i), l - i - 1);
            addTop(num);
        }
    }

    public function drawJudgement(judgement:String):Void {
        final judgeSpr:JudgeRating = cast(recycle(JudgeRating), JudgeRating);
        judgeSpr.init(judgement);
        addTop(judgeSpr);
    }

    public function drawComplete(judgement:String, combo:Int) {
        drawJudgement(judgement);
        drawCombo(combo);
    }

    function addTop(spr:RemoveRating) {
        add(spr);
        remove(spr, true);
        insert(members.length, spr);
    }
}

class JudgeRating extends RemoveRating
{
    var animated:Bool = true;
    
    public function new() {
        super();

        var judgeRatings:Array<String> = ['shit', 'bad', 'good', 'sick'];
        
        judgeRatings.fastForEach((i, _) -> {
            var oldJudge = Paths.png('skins/${SkinUtil.curSkin}/ratings/$i');
            if (Paths.exists(oldJudge, IMAGE)) {
                animated = false; // Backwards compatibility
                break;
            }
        });

        if (animated) {
            var imagePath = 'skins/${SkinUtil.curSkin}/ratings/ratings';
            loadImage(imagePath, false, null, null, lodLevel);

            var length = CoolUtil.returnJudgements.length + 1;
            loadGraphic(graphic, true, Std.int(width / length / lodScale), Std.int(height / lodScale));
            for (i in 0...length)
                animation.add(judgeRatings[i], [i], 1);
        }
    }

    public function init(judgement:String) {
        setPosition();
        animated ? animation.play(judgement, true) : loadImage('skins/${SkinUtil.curSkin}/ratings/$judgement', false, null, null, lodLevel);
        updateHitbox();
        start(Conductor.crochet * 0.001, Conductor.stepCrochet * 0.025);
        jump();
    }
}

class ComboRating extends RemoveRating {
    public function new() {
        super();
        loadImage('skins/${SkinUtil.curSkin}/ratings/combo', false, null, null, lodLevel);
    }

    public function init() {
        setPosition(50, 100);
        updateHitbox();
        start(Conductor.crochet * 0.001 * 2, Conductor.stepCrochet * 0.025);
        jump(0.8);
    }
}

class NumRating extends RemoveRating
{
    public var initScale:Float = 1;
    var animated:Bool = true;
    
    public function new() {
        super();
        
        for (i in 0...10)
        {
            var oldNum = Paths.png('skins/${SkinUtil.curSkin}/ratings/num$i');
            if (Paths.exists(oldNum, IMAGE)) {
                animated = false; // Backwards compatibility
                break;
            }
        }
        
        if (animated) {
            final path:String = 'skins/${SkinUtil.curSkin}/ratings/nums';
            loadImage(path, false, null, null, lodLevel);
            
            loadGraphic(graphic, true, Std.int(width * 0.1 / lodScale), Std.int(height / lodScale));
            for (i in 0...10)
                animation.add(Std.string(i), [i], 1);
            
            setScale(scale.x);
            initScale = scale.x;
        }
    }

    public function init(num:String, id:Int = 0) {
        setPosition(0, 100);
        animated ? animation.play(num, true) : loadImage('skins/${SkinUtil.curSkin}/ratings/num$num', false, null, null, lodLevel);
        updateHitbox();
        start(Conductor.crochetMills * 2, Conductor.stepCrochet * 0.025);
        jump(0.8);
        offset.x = width * lodScale * id;
    }
}

class RemoveRating extends FlxSpriteExt
{
    public var lifeTime:Float = 1;
    public var alphaSpeed:Float = 1;
    var lodLevel:LodLevel;

    public function new() {
        super();
        var skinData = SkinUtil.getSkinData(SkinUtil.curSkin);
        setScale(skinData.scale);
        lodLevel = LodLevel.resolve(skinData.allowLod ?? true);
        antialiasing = skinData.antialiasing ? Preferences.getPref('antialiasing') : false;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (lifeTime > 0) lifeTime -= elapsed; 
        else if (alive) {
            if (alpha > 0)  alpha -= elapsed * alphaSpeed;
            else            kill();
        }
    }

    public function start(time:Float = 1, speed:Float = 1) {
        lifeTime = time;
        alphaSpeed = speed;
        alpha = 1.0;
    }

    public function jump(randomness:Float = 1) {
        acceleration.y = FlxG.random.float(200 * randomness, 300 * randomness);
        velocity.y = FlxG.random.float(-140 * randomness, -160 * randomness);
        velocity.x = FlxG.random.float(-5 * randomness, 5 * randomness);
    }
}