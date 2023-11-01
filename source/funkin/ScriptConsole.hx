package funkin;

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

class ConsolePrint extends Sprite {
	private var icon:Bitmap;
    public var textField:TextField;
    public var nextPrint:ConsolePrint = null;

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

	public function new() {
		super();
		icon = new Bitmap();
        icon.x = -frameSize;
        icon.y = 2;
		addChild(icon);
		
		textField = new TextField();
        textField.multiline = true;
		textField.wordWrap = true;
        textField.width = Lib.current.stage.stageWidth / 2.3;
		textField.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 12, 0xFFFFFF);
        addChild(textField);
	}

    static var typeMap:Map<PrintType, {frame:Int, color:FlxColor}> = [
        ADD => {frame: 0, color: FlxColor.LIME},
        ERROR => {frame: 1, color: FlxColor.RED},
        WARNING => {frame: 2, color: FlxColor.YELLOW}
    ];

    var type = null;

	public function init(text:String, type:PrintType) {
		time = 7;
        textField.alpha = icon.alpha = 1;
        textField.text = text;
		x = 26;
        y = 50;

        if (this.type != type) {
            this.type = type;
            if (type == NONE) {
                icon.visible = false;
                setColor(FlxColor.WHITE);
            } else {
                final _data = typeMap.get(type);
                icon.visible = true;
                icon.bitmapData = iconFrames[_data.frame];
                setColor(_data.color);
            }
        }
	}

    function setColor(color:Int) {
        textField.textColor = color;
    }

    public var alive:Bool = true;
    public function kill() {
        time = 0;
        alive = visible = false;
    }

    public function revive() {
        alive = visible = true;
    }

    var time:Float = 0;
    public function update(elapsed:Float) {
        if (time > 0) {
            time -= elapsed;
            textField.alpha = icon.alpha = time;
            if (time <= 0) {
                kill();
            }
        }
    }
}

class ScriptConsole extends ResizableSprite {
	public static var show:Bool = false;
    private var targetX:Float = 0;
	public var bg:Shape;
	public var prints:Sprite;
	
	public function new() {
		super();
		bg = new Shape();
		bg.graphics.beginFill(0x000000, 0.8);
        bg.graphics.drawRect(0, 0, Math.ceil(Lib.current.stage.stageWidth / 2.25), Lib.current.stage.stageHeight);
        bg.graphics.endFill();
        addChild(bg);

		prints = new Sprite();
		addChild(prints);

		x = -bg.width;
        targetX = x;
		
        ConsolePrint.initFrames();
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
	}

    inline function forEachPrint(func:Dynamic, alive:Bool = false) {
        for (i in prints.__children) {
            if (i is ConsolePrint) {
                final _p = cast (i, ConsolePrint);
                if (alive == false || _p.alive == alive)
                    if (func(_p)) break;
            }
        } 
    }

    var _lastPrint:ConsolePrint = null;

	public function print(text:String, type:PrintType) {
        var _print = null; // Get dead prints
        forEachPrint(function (p:ConsolePrint) {
            if (!p.alive) {
                _print = p; // Reuse print
                _print.revive();
                return true;
            }
            return false;
        });
        
        if (_print == null) {
            _print = new ConsolePrint();
            prints.addChild(_print);
        }

		_print.init(text, type);
        if (_lastPrint != null) {
            _lastPrint.nextPrint = _print;
        }
        _lastPrint = _print;

        forEachPrint(function (p:ConsolePrint) {
            if (p != _print) {
                final movePrint:Float =  p?.nextPrint?.textField.textHeight ?? 16.0;
                p.y += movePrint;
                if (p.y >= 650) {
                    p.kill();
                }
            }
        }, true);
	}

    public function clear() {
        for (i in prints.__children) {
            if (i is ConsolePrint)
                cast (i, ConsolePrint).kill();
        }
    }

	var tmr:Float = 0;
	function update(event) {
		if (tmr <= 0) {
			if (FlxG.keys.justPressed.F1) {
				tmr = 0.1; // Fix spam issue
				show = !show;
                visible = true;
				targetX = show ? 0 : -width;
			}
		} else {
			tmr -= FlxG.elapsed;
		}

        if (show) {
            for (i in prints.__children) {
                if (i is ConsolePrint) {
                    final _p = cast (i, ConsolePrint);
                    if (_p.alive) _p.update(FlxG.elapsed);
                }
            }
        }

		if (x != targetX) {
			x = CoolUtil.coolLerp(x, targetX, 0.25);
			x = Math.abs(x - targetX) < 1 ? targetX : x;
		} else {
            visible = show;
        }
	}
}
