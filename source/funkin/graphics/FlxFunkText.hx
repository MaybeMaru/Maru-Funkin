package funkin.graphics;

import openfl.geom.ColorTransform;
import flixel.system.FlxAssets;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import openfl.text.TextFormat;
import openfl.text.TextField;

using flixel.util.FlxColorTransformUtil;

// rappergf >:3

enum TextStyle {
    NONE;
    OUTLINE(size:Float, ?quality:Int, ?color:FlxColor);
    SHADOW(offset:FlxPoint, ?color:FlxColor);
}

@:access(openfl.text.TextField)
class FlxFunkText extends FlxSpriteExt {
    public var text(default, set):String = "";
    inline function set_text(value:String) {
        if (value != text) {
            textField.text = value;
            _regen = true;
        }
        return text = value;
    }

    public var length(get, never):Int;
    inline function get_length() {
        return text.length;
    }

    public var size(default, set):Int = 16;
    inline function set_size(value:Int) {
        if (value != textFormat.size) {
            textFormat.size = value;
            updateFormat();
        }
        return value;
    }

    static inline function getFont(value:String) {
        final _font = (value.startsWith("assets/") || value.startsWith("mods/")) ? value : Paths.font(value);
        return Paths.exists(_font, FONT) ? (_font.startsWith("assets/") ? OpenFlAssets.getFont(_font).fontName : _font) : FlxAssets.FONT_DEFAULT;
    }

    public var font(default, set):String = "vcr";
    inline function set_font(value:String = "vcr") {
        if (font != value) {
            textFormat.font = getFont(value);
            font = textFormat.font;
            updateFormat();
        }
        return value;
    }

    
    public var startSelection:Int = -1;    
    public var endSelection:Int = -1;
    public var selected(get, never):Bool;
    function get_selected() {
        return startSelection != -1 && endSelection != -1 && !(startSelection == 0 && endSelection == 0);//(startSelection != -1) && (endSelection ?? -1) != -1) && (startSelection != 0 && endSelection != 0);
    }

    inline public function setSelection(start:Int, end:Int) {
        if ((start != startSelection) || (end != endSelection)) {
            startSelection = start;
            endSelection = end;
            _regen = true;
        }
    }

    inline public function deselect() {
        if (selected) {
            startSelection = -1;
            endSelection = -1;
            _regen = true;
        }
    }

    inline function updateFormat() {
        textField.defaultTextFormat = textFormat;
        textField.setTextFormat(textFormat);
        _regen = true;
    }

    public var textWidth(get, never):Float;
    public var textHeight(get, never):Float;
    inline function get_textWidth() return textField.__textEngine.textWidth;
    inline function get_textHeight() return textField.__textEngine.textHeight;

    public var wordWrap(default, set):Bool = false;
    function set_wordWrap(value:Bool):Bool {
        if (wordWrap != value) {
            textField.wordWrap = value;
            _regen = true;
        }
        return wordWrap = value;
    }

    private var _regen:Bool = false;    
    function drawTextField() {
        var matrix = CoolUtil.matrix;
        inline matrix.setTo(1, 0, 0, 1, textField.x, textField.y);

        if (selected) {
            textField.setSelection(startSelection, endSelection);
            textField.__dirty = true;
			textField.__setRenderDirty();
        }

        var rect = CoolUtil.rectangle;
        inline rect.setTo(0, 0, pixels.width, pixels.height);

        pixels.fillRect(rect, 0x00000000);
        pixels.draw(textField, matrix, null, null, null, antialiasing);
    }

    public var alignment(default, set):String = "left";
    function set_alignment(value:String) {
        alignment = alignment.toLowerCase().trim();
        if (alignment != value) {
            alignment = value;
            switch (alignment) {
                case "right": textFormat.align = RIGHT;
                case "center" | "middle": textFormat.align = CENTER;
                default: textFormat.align = LEFT;
            }
            updateFormat();
        }
        return value;
    }
    
    var textField:TextField;
    var textFormat:TextFormat;

    @:noCompletion
    inline public function getTextField():TextField {
        return textField;
    }

    override function destroy() {
        super.destroy();
        textField = null;
        textFormat = null;
        styleColor = null;

        switch (style) {
            case SHADOW(offset, color): offset.put();
            default:
        }

        style = null;
    }

    public function new(X:Float = 0, Y:Float = 0, Text:String = "", ?canvasRes:FlxPoint, ?size:Int) {
        super(X,Y);
        textField = new TextField();
        styleColor = new ColorTransform();

        if (canvasRes == null) {
            setCanvasSize(FlxG.width, FlxG.height);
        }
        else {
            setCanvasSize(Std.int(canvasRes.x), Std.int(canvasRes.y));
            canvasRes.putWeak();
            canvasRes = null;
        }

        textFormat = new TextFormat(getFont("vcr"), 16, 0xffffff);
        textField.defaultTextFormat = textFormat;

        text = Text;
        if (size != null) this.size = size;
    }

    public inline function setCanvasSize(width:Int, height:Int) {
        if (pixels == null || width != pixels.width || height != pixels.height) {
            textField.width = width;
            textField.height = height;
            makeGraphic(width, height, 0x00000000, true);
            _regen = true;
        }
    }

    // For hscript since enums are fucky wucky
    public function setStyle(type:String, ?values:Array<Dynamic>):TextStyle {
        if (values == null) values = [];
        return style = switch(type.toLowerCase().trim()) {
            case "outline": OUTLINE(values[0], values[1], values[2]);
            case "shadow": SHADOW(values[0], values[1]);
            default: NONE;
        }
    }

    var styleColor:ColorTransform;
    inline function setStyleColor(color:FlxColor) {
        styleColor.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, alpha);
    }

    public var style(default, set):TextStyle = NONE;
    private function set_style(?value:TextStyle):TextStyle {
        return style = (value == null) ? NONE :
        switch (value) {
            case OUTLINE(size, quality, color):
                var color:FlxColor = color ?? FlxColor.BLACK;
                setStyleColor(color);
                OUTLINE(size ?? 16, quality ?? 8, color);
            
            case SHADOW(offset, color):  
                var color:FlxColor = color ?? FlxColor.BLACK;
                setStyleColor(color);      
                SHADOW(offset ?? FlxPoint.get(8, 8), color);
            
            default: value;
        }
    }
    
    inline function sizeMult() {
        return size * 0.0625;
    }

    override function drawComplex(camera:FlxCamera) {
        switch (style) {
            case OUTLINE(size, quality, _):
                var point = CoolUtil.point;
                var transform = this.colorTransform;
                this.colorTransform = styleColor;

                point.copyFrom(offset);
                size *= sizeMult();

                final qualityDiv = CoolUtil.DOUBLE_PI / quality;
                for (i in 0...quality) {
                    final rads = i * qualityDiv;
                    offset.set(point.x, point.y);
                    offset.add(CoolUtil.cos(rads) * size, CoolUtil.sin(rads) * size);
                    __superDrawComplex(camera);
                }
                
                offset.copyFrom(point);
                this.colorTransform = transform;

            case SHADOW(offset, _):
                var point = CoolUtil.point;
                var transform = this.colorTransform;
                this.colorTransform = styleColor;

                point.copyFrom(this.offset);
                this.offset.add(offset.x * sizeMult(), offset.y * sizeMult());
                __superDrawComplex(camera);

                this.offset.copyFrom(point);
                this.colorTransform = transform;

            default:
        }
        
        __superDrawComplex(camera);
    }

    override function draw() {
        if (alpha != 0 && visible) {
            if (_regen) {
                drawTextField();
                _regen = false;
            }
            __superDraw();
        }
    }
}