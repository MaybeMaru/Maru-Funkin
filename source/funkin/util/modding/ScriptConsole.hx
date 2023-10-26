package funkin.util.modding;

import flixel.system.FlxAssets;
import flixel.util.FlxArrayUtil;

enum TraceType {
    NONE;
    ADD;
    ERROR;
    WARNING;
}

class ConsolePrint extends FlxText {
    final icon:FlxSprite;

    public function new() {
        icon = new FlxSprite().loadGraphic(Paths.image("options/console"), true, 16, 16);
        icon.offset.x = 16;
        icon.animation.add("ico", [0,1,2], 0);
        icon.animation.play("ico");
        icon.antialiasing = false;
        
        super(26, 50, FlxG.width/2.25, "", 12);
        offset.y = 1.5;
        antialiasing = false;
        font = FlxAssets.FONT_DEFAULT;
        alpha = 0.001;

        this.camera = icon.camera = CoolUtil.getTopCam();
    }

    static var typeMap:Map<TraceType, {frame:Int, color:FlxColor}> = [
        ADD => {frame: 0, color: FlxColor.LIME},
        ERROR => {frame: 1, color: FlxColor.RED},
        WARNING => {frame: 2, color: FlxColor.YELLOW}
    ];

    public function init(txt:String, type:TraceType) {
        setPosition(26,50);
        time = 7;
        alpha = 1;
        text = txt;
        color = FlxColor.WHITE;
        
        if (icon.visible = (type != NONE)) {
            final _data = typeMap.get(type);
            color = _data.color;
            icon.alpha = 1;
            icon.animation.curAnim.curFrame = _data.frame;
        }
    }

    override function draw() {
        super.draw();
        if (icon.visible) icon.draw();
    }

    var time:Float = 0;
    override function update(elapsed) {
        icon.setPosition(x,y);
        super.update(elapsed);
        if (ScriptConsole?.instance?.show ?? false && time > 0) {
            time -= elapsed;
            this.alpha = icon.alpha = Math.max(time, 0.00001);
            if (time <= 0) {
                kill();
            }
        }
    }
}

class ScriptConsole extends FlxTypedSpriteGroup<Dynamic> {
    public var show:Bool = false;
    var targetX:Float = 0;
    final bg:FlxSprite;
    public static var instance:ScriptConsole = null;
    
    public function new():Void {
        super();
        instance = this;
        scrollFactor.set();
        camera = CoolUtil.getTopCam();
        
        bg = new FlxSprite().makeGraphic(Std.int(FlxG.width/2.25), FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.8;
        add(bg);

        bg._dynamic.update = function () {
            if (FlxG.keys.justPressed.F1) {
                show = !show;
                targetX = show ? 0 : -width;
            }
            if (x != targetX) {
                x = CoolUtil.coolLerp(x, targetX, 0.25);
                x = Math.abs(x - targetX) < 1 ? targetX : x;
            }
        }

        x = targetX = -bg.width;
        
        printQueue();
    }

    public function print(txt:String, type:TraceType) {
        for (i in this) {
            if (i is ConsolePrint) {
                i.y += 16;
                if (i.y >= 650) {
                    i.kill();
                }
            }
        }
        
        final _print:ConsolePrint = this.recycle(ConsolePrint);
        _print.init(txt,type);
        add(_print);
    }

    static var printQueueList:Array<{text:String,type:TraceType}> = [];
    inline public static function addQueue(text:String, type:TraceType) {
        printQueueList.push({text:text,type:type});
    }

    function printQueue() {
        for (i in printQueueList) {
            print(i.text,i.type);
        }
        FlxArrayUtil.clearArray(printQueueList);
    }
}