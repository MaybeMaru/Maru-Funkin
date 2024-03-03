package funkin.substates;

class PromptSubstate extends MusicBeatSubstate {
    var acceptFunction:()->Void;
    var acceptRequirement:()->Bool;
    
    public function new(text:String, ?acceptFunction:()->Void, ?acceptRequirement:()->Bool, textScale:Float = 0.75) {
        super();
        this.acceptFunction = acceptFunction;
        this.acceptRequirement = acceptRequirement;

        var bg = new FlxSpriteExt().makeRect(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        var prompBox = new FlxSpriteExt().makeRect(1200, 500, 0xFFFAFD6D);
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

        if (getKey('BACK', JUST_PRESSED)) {
            close();
            CoolUtil.playSound("cancelMenu");
            return;
        }

        if (canClick && (acceptRequirement == null ? getKey('ACCEPT', JUST_PRESSED) : acceptRequirement())) {
            if (acceptFunction != null) {
                acceptFunction();
                close();
            }
        }
    }
}