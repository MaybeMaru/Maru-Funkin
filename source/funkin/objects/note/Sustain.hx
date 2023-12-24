package funkin.objects.note;

import flixel.graphics.frames.FlxFrame;

class Sustain extends BasicNote {
    public var susLength:Float = 0.0;
    
    public function new(noteData:Int = 0, strumTime:Float = 0.0, susLength:Float = 0.0, skin:String = "default", ?parent:Note):Void {
        clipRect = FlxRect.get();
        super(noteData, strumTime, skin); // Load skin

        this.parent = parent;
        isSustainNote = true;
        drawStyle = BOTTOM_TOP;
        alpha = 0.6;
        
        yDisplace = NoteUtil.swagHeight * 0.5;
        this.susLength = susLength;
        setSusLength(susLength);
    }

    override function set_noteSpeed(value:Float):Float {
        noteSpeed = value;
        updateSusLength();
        return value;
    }

    public var autoFlip:Bool = true; // If to flip the sustain at a certain angle
    override function set_approachAngle(value:Float):Float {
        if (autoFlip) flipX = value % 360 >= 180;
        return approachAngle = angle = value;
    }

    inline public static var MISS_COLOR:Int = 0xffc8c8c8;

    public var pressed:Bool = false;
    public var startedPress:Bool = false;
    public var missedPress(default, set):Bool = false;
    inline function set_missedPress(value:Bool) {
        color = (value && mustHit) ? MISS_COLOR : FlxColor.WHITE;
        return missedPress = value;
    }

    public var percentLeft(default, null):Float = 0.0;

    public function pressSustain() {
        pressed = false;
        if (Conductor.songPosition >= strumTime) {
            pressed = true;
            final susY:Float = getMillPos(strumTime - Conductor.songPosition);
            percentLeft = repeatHeight / -susY;
            clipRect.y = susY;
            offset.y = susY * getCos();
            if (susY <= -repeatHeight) {
                kill();
            }
        }
    }

    public inline function inSustain():Bool {
        return Conductor.songPosition >= strumTime && Conductor.songPosition <= (susLength + Conductor.stepCrochet);
    }

    public inline function updateSusLength():Float {
        return setSusLength(susLength);
    }

    public inline function setSusLength(mills:Float = 0.0):Float {
        repeatHeight = getMillPos(mills) + (NoteUtil.swagHeight * 0.5);
        clipRect.height = repeatHeight;
        return repeatHeight;
    }

    public inline function setSusSecs(secs:Float = 0.0):Float {
        return setSusLength(secs * 1000);
    }

    override function set_targetStrum(value:NoteStrum):NoteStrum {
        if (value != null) {
            updateHitbox();
            offset.y = 0;
            offset.x -= value.width * 0.5 - width * 0.5;
        }
        return targetStrum = value;
    }

    override function updateSprites():Void {
        super.updateSprites();
        
        playAnim("hold" + CoolUtil.directionArray[noteData]);
        playAnim("hold" + CoolUtil.directionArray[noteData] + "-end");
        targetStrum = targetStrum;

        final lastHeight = repeatHeight;
        setTiles(1, 1);
        origin.set(width * 0.5 / scale.x, 0);
        //calcHeight = frameHeight;
        repeatHeight = lastHeight;
        clipRect.width = repeatWidth;
    }

    override function setupTile(tileX:Int, tileY:Int, baseFrame:FlxFrame):FlxPoint {
        switch (tileY) {
            case 0: playAnim("hold" + CoolUtil.directionArray[noteData] + "-end");  // Tail
            case 1: playAnim("hold" + CoolUtil.directionArray[noteData]);           // Piece
        }
        return super.setupTile(tileX, tileY, frame);
    }

    override function applyCurOffset(forced:Bool = false):Void {
        // we dont need offsets for these
    }
}