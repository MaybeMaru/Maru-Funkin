package funkin;

import haxe.ds.Vector;
import openfl.geom.Point;
import openfl.display.BitmapData;
import flixel.system.FlxAssets;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Shape;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

enum PrintType {
    NONE;
    ADD;
    ERROR;
    WARNING;
}

class Print extends Sprite {
	var icon:Bitmap;
    public var textField:TextField;

    static inline var frameSize:Int = 16;
    static var iconFrames:Array<BitmapData> = [];
    public static function initFrames() {
        final bmp = AssetManager.getRawBitmap(Paths.image("options/console", null, true));
        for (i in 0...3) {
            final frame = new BitmapData(frameSize,frameSize,true,FlxColor.TRANSPARENT);
            frame.copyPixels(bmp, new Rectangle(i*frameSize,0,frameSize,frameSize), new Point(0,0));
            iconFrames.push(frame);
        }
    }

    static var typeMap:Map<PrintType, {frame:Int, color:FlxColor}> = [
        ADD => {frame: 0, color: FlxColor.LIME},
        ERROR => {frame: 1, color: FlxColor.RED},
        WARNING => {frame: 2, color: FlxColor.YELLOW}
    ];

	public function new() {
		super();
		icon = new Bitmap();
        icon.x = -frameSize;
        icon.y = 2;
		addChild(icon);
		
		textField = new TextField();
        textField.multiline = true;
		textField.wordWrap = true;
        textField.width = (Lib.current.stage.stageWidth / 2.3) - 50;
		textField.defaultTextFormat = new TextFormat(Paths.font("roboto"), 14, 0xFFFFFF);
        addChild(textField);

        x = 26;
        y = 50;
	}

    public var type(default, set):PrintType = NONE;
    inline function set_type(value:PrintType):PrintType {
        switch (value) {
            case NONE:
                icon.visible = false;
                color = FlxColor.WHITE;
            default:
                icon.visible = true;
                icon.bitmapData = iconFrames[typeMap[value].frame];
                color = typeMap[value].color;
        }
        return type = value;
    }

    public var text(default, set):String = "";
    inline function set_text(value:String):String {
        return text = textField.text = value;
    }

    public var color(default, set):Int = FlxColor.WHITE;
    inline function set_color(value:Int):Int {
        return color = textField.textColor = value;
    }

    public var timer:Float = 7.0;
    inline public function resetTimer() {
        timer = 7.0;
        alpha = 1;
    }

    inline public function hide() {
        timer = 0.0;
        alpha = 0;
    }

    public function update(e:Float) {
        if (timer > 0) {
            timer -= e;
            alpha = timer;
        }
    }
}

typedef PrintData = {text:String, type:PrintType, lines:Int};

class ScriptConsole extends ResizableSprite {
	public static var show:Bool = false;
    private var targetX:Float = 0;
	public var bg:Shape;

    var prints:Vector<Print>;
    var printCache:Vector<PrintData>;
    static final printsLength:Int = 38;
	
	public function new() {
		super();
		bg = new Shape();
		bg.graphics.beginFill(0x000000, 0.8);
        bg.graphics.drawRect(0, 0, Math.ceil(Lib.current.stage.stageWidth / 2.25), Lib.current.stage.stageHeight);
        bg.graphics.endFill();
        addChild(bg);

		x = -bg.width;
        targetX = x;
		
        Print.initFrames();
        printCache = new Vector<PrintData>(printsLength, {text: "", type: NONE, lines: 1});
        prints = new Vector<Print>(printsLength, null);
        for (i in 0...printsLength) {
            final print = new Print();
            prints[i] = print;
            addChild(print);
        }
	}

    public function print(p:Dynamic, type:PrintType = NONE) {
        // Move last prints down
        for (i in 0...printsLength-1) {
            final id:Int = printsLength-i-1;

            final print = prints[id];
            final lastPrint = prints[id-1];

            print.text = lastPrint.text;
            print.type = lastPrint.type;
            print.alpha = lastPrint.alpha;
            print.timer = lastPrint.timer;
        }

        // Display the new print
        final text:String = Std.string(p);
        prints[0].text = text;
        prints[0].type = type;
        prints[0].resetTimer();

        // Move down all the prints
        var Y = 50;
        for (i in 0...printsLength) {
            prints[i].y = Y;
            if (Y > 620) {
                prints[i].hide();
            }
            Y += prints[i].textField.numLines * 16;
        }
    }

    public function clear() {
        for (i in 0...printsLength) {
            prints[i].hide();
        }
    }

	var tmr:Float = 0;
	public function update(elapsed:Float) {
        if (tmr <= 0) { // Show / hide console
			if (FlxG.keys.justPressed.F1) {
				tmr = 0.1; // Fix spam issue
				show = !show;
                visible = true;
				targetX = show ? 0 : -width;
			}
		} else {
			tmr -= elapsed;
		}

        if (show) {
            for (i in 0...printsLength) {
                prints[i].update(elapsed);
            }
        }

		if (x != targetX) { // Lerp console x
			x = CoolUtil.coolLerp(x, targetX, 0.25);
			x = Math.abs(x - targetX) < 1 ? targetX : x;
		} else {
            visible = show;
        }
	}
}
