package funkin.states.options.items;

class SpriteButton extends FlxSpriteGroup
{
    public var clickCallback:Void->Void = null;
    private var btnText:Alphabet;
    private var btnSpr:FunkinSprite;

    public function new(X:Float, Y:Float, btnName:String = 'balls', ?clickCallback:Void->Void, baseSpr:String = 'buttonSprite'):Void {
        super(X,Y);
        if (clickCallback != null) this.clickCallback = clickCallback;

        btnSpr = new FunkinSprite('options/$baseSpr', [0,0], [0,0]);
        if (btnSpr.animated) {
            btnSpr.addAnim('loop','buttonSprite',24,true);
            btnSpr.playAnim('loop');
        }
        btnSpr.setGraphicSize(Std.int(btnSpr.width*0.5));
        btnSpr.updateHitbox();
        btnSpr.x -= btnSpr.width/40;
        btnSpr.y -= btnSpr.height/4;
        btnSpr.scale.y *= 1.2;
        btnSpr.scale.x *= 1.2;
        add(btnSpr);

        btnText = new Alphabet(0,0,btnName,false);
        add(btnText);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        color = FlxColor.interpolate(color, FlxColor.WHITE, elapsed*8);

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(btnSpr))
            onButtonClick();
    }

    function onButtonClick():Void {
        CoolUtil.playSound('scrollMenu');
        color = FlxColor.YELLOW;
        if (clickCallback != null) clickCallback();
    }
}