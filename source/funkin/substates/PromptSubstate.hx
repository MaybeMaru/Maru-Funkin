package funkin.substates;

class PromptSubstate extends MusicBeatSubstate {
    var acceptFunction:Dynamic = null;
    var acceptRequirement:Dynamic = null;
    
    public function new(text:String, ?acceptFunction:Dynamic, ?acceptRequirement:Dynamic, textScale:Float = 0.8) {
        super();
        this.acceptFunction = acceptFunction;
        this.acceptRequirement = acceptRequirement;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

        var prompBox:FlxSprite = new FlxSprite().makeGraphic(1200, 500, 0xFFFAFD6D);
        prompBox.screenCenter();
        add(prompBox);

        var prompText:Alphabet = new Alphabet(FlxG.width * 0.5 ,prompBox.y + 75, text, true, 0, textScale);
        prompText.alignment = CENTER;
        add(prompText);

        camera = CoolUtil.getTopCam();
        for (i in [bg,prompBox,prompText]) i.scrollFactor.set();
    }

    var startTimer:Float = 0.15;
    var canClick:Bool = false;

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (startTimer > 0) {
            startTimer -= elapsed;
            if (startTimer <= 0) canClick = true;
        }

        if (getKey('BACK-P')) {
            close();
            CoolUtil.playSound("cancelMenu");
            return;
        }

        if (canClick && (acceptRequirement == null ? getKey('ACCEPT-P') : acceptRequirement())) {
            if (acceptFunction != null) {
                acceptFunction();
                close();
            }
        }
    }
}