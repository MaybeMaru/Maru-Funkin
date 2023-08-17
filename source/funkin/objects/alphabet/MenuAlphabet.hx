package funkin.objects.alphabet;

class MenuAlphabet extends Alphabet {
        //  Some variables you may need for special menus
    public var strID:String = '';
    public var intID:Int = 0;

    public var targetY:Float = 0;
    public var forceX:Bool = true;
    public var startX:Float = 0;

    public function new(x:Float = 0, y:Float = 0, text:String = "coolswag", bold:Bool = true, textWidth:Int = 0, textScale:Float = 1):Void {
        super(x, y, text, bold, textWidth, textScale);
        startX = x;
        setTargetPos();
    }

    public function setTargetPos(snap:Bool = true):Void {
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
        x = (snap) ? (forceX ? (targetY * 20) + 90 : startX)  : (forceX ? CoolUtil.coolLerp(x, (targetY * 20) + 90, 0.16) : startX);
        y = (snap) ? ((scaledY * 120) + (FlxG.height * 0.48)) : (CoolUtil.coolLerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16));
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        setTargetPos(false);
	}
}