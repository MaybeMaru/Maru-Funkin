package funkin.objects.alphabet;

class MenuAlphabet extends Alphabet
{
    public var targetY:Float = 0;
    public var forceX:Bool = true;
    public var startX:Float = 0;

    public function new(x:Float, y:Float, text:String, bold:Bool, targetY:Float):Void {
        super(x, y, text, bold);
        this.targetY = targetY;
        startX = x;
        snapPosition();
    }

    public inline function getTargetY() {
        return FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
    }

    public inline function lerpPosition() {
        x = forceX ? CoolUtil.coolLerp(x, (targetY * 20) + 90, 0.16) : startX;
        y = CoolUtil.coolLerp(y, (getTargetY() * 120) + (FlxG.height * 0.48), 0.16);
    }

    public inline function snapPosition() {
        x = forceX ? (targetY * 20) + 90 : startX;
        y = (getTargetY() * 120) + (FlxG.height * 0.48);
    }

    override function update(elapsed:Float):Void {
        lerpPosition();
        super.update(elapsed);
	}
}