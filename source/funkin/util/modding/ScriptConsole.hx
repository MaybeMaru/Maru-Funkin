package funkin.util.modding;

class ScriptConsole extends FlxTypedSpriteGroup<Dynamic> {
    private var traceTextArray:Array<ConsoleTrace> = [];
    public static var listToAdd:Array<Dynamic> = [];
    public var show:Bool = false;
    private var targetX:Float = 0;
    var bgThing:FlxSprite;

    public function new():Void {
        super();
        bgThing = new FlxSprite().makeGraphic(Std.int(FlxG.width/2.25), FlxG.height, 0xff0d0d0d);
        cameras = [CoolUtil.getTopCam()];
        scrollFactor.set();
        bgThing.alpha = 0.8;
        add(bgThing);
        x -= width;
        traceTextArray = [];
    }

    public function consoleTrace(text:String, color:Int = 0xffffffff):Void {
        for (member in traceTextArray) {
            if (member.alive) {
                member.y += member.height;
                if (member.y >= FlxG.height/1.1)
                    removeMember(member);
            }
        }
        var newTrace:ConsoleTrace = recycle(ConsoleTrace);
        newTrace.text = "";
        newTrace.init(text,color);
        traceTextArray.push(newTrace);
        add(newTrace);
    }

    function removeMember(member:ConsoleTrace):Void {
        member.kill();
        traceTextArray.remove(member);
    }

    public static function addToTraceList(text:String, color:Int = 0xffffffff):Void {
        var shit:Array<Dynamic> = [text, color];
        listToAdd.push(shit);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        targetX = show ? 0 : -width;
        x = CoolUtil.coolLerp(x, targetX, 0.25);

        if (listToAdd[0] != null) {
            while (listToAdd.length > 0) {
                consoleTrace(listToAdd[0][0], listToAdd[0][1]);
                listToAdd.remove(listToAdd[0]);
            }
        }

        if (show) {
            for (member in traceTextArray) {
                member.alphaTime -= elapsed*2;
                member.alpha = member.alphaTime;
                if (member.alpha <= 0)
                    removeMember(member);
            }
        }
    }
}

class ConsoleTrace extends FlxText {
    inline static var time:Float = 10;
    public var alphaTime:Float = time;
    public function new() {
        super(20,50,Std.int(FlxG.width/2.25),"",10);
        antialiasing = false;
    }
    public function init(text:String, color:Int) {
        setPosition(20,50);
        this.text = text;
        this.color = color;
        alpha = 1;
        alphaTime = time;
    }
}