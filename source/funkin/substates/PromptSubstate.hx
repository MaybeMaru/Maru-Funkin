package funkin.substates;

class PromptSubstate extends MusicBeatSubstate
{
    var acceptFunction:()->Void;
    var acceptRequirement:()->Bool;
    
    public function new(text:String, ?acceptFunction:()->Void, ?acceptRequirement:()->Bool, textScale:Float = 0.75)
    {
        super(false, 0x98000000);
        this.acceptFunction = acceptFunction;
        this.acceptRequirement = acceptRequirement;

        var prompBox = new FlxSpriteExt().makeRect(1200, 500, 0xFFFAFD6D);
        prompBox.scrollFactor.set();
        prompBox.screenCenter();
        add(prompBox);

        var prompText:Alphabet = new Alphabet(0, prompBox.y + 75, text);
        prompText.scrollFactor.set();
        prompText.scale.scale(textScale, textScale);
        prompText.alignment = CENTER;
        prompText.screenCenter(X);
        add(prompText);

        camera = CoolUtil.getTopCam();
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

        if (canClick) if (acceptRequirement != null ? acceptRequirement() : getKey('ACCEPT', JUST_PRESSED)) {
            if (acceptFunction != null) acceptFunction();
            close();
        }
    }
}