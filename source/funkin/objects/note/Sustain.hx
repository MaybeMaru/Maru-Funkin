package funkin.objects.note;

import flixel.graphics.frames.FlxFrame;

class TestNote extends BasicNote {
    public function new(noteData:Int, strumTime:Float = 0.0, skin:String = "default", ?childNote:Sustain) {
        super(noteData, strumTime, skin); // Load skin
        this.childNote = childNote;
        isSustainNote = false;
    }

    override function updateSprites() {
        super.updateSprites();
        playAnim('scroll' + CoolUtil.directionArray[noteData]);
    }

    override function applyCurOffset(forced:Bool = false) {
        if (animation.curAnim != null) {
			if(existsOffsets(animation.curAnim.name)) {
				final animOffset:FlxPoint = new FlxPoint().copyFrom(animOffsets.get(animation.curAnim.name));
				if (!animOffset.isZero() || forced) {
					animOffset.x *= (flippedOffsets ? -1 : 1);
                    updateHitbox();
                    offset.add(animOffset.x, animOffset.y);
				}
			}
		}
    }

    public var canBeHit:Bool = false;
	public var wasGoodHit:Bool = false;
	public var willMiss:Bool = false;

	inline public function calcHit():Void {
		if (willMiss && !wasGoodHit) {
			canBeHit = false;
		}
		else {
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * hitMult) {
				if (strumTime < Conductor.songPosition + 0.5 * Conductor.safeZoneOffset * hitMult)
					canBeHit = true;
			}
			else {
				willMiss = canBeHit = true;
			}
		}
	}
}

class Sustain extends BasicNote {
    public var susLength:Float = 0.0;
    
    public function new(noteData:Int = 0, strumTime:Float = 0.0, susLength:Float = 0.0, skin:String = "default", ?parentNote:TestNote):Void {
        clipRect = FlxRect.get();
        super(noteData, strumTime, skin); // Load skin

        this.parentNote = parentNote;
        isSustainNote = true;
        drawStyle = BOTTOM_TOP;
        alpha = 0.6;
        
        yDisplace = NoteUtil.swagHeight * 0.5;
        this.susLength = susLength;
        setSusLength(susLength);
    }

    public inline function inSustain():Bool {
        return Conductor.songPosition >= strumTime && Conductor.songPosition <= (susLength + Conductor.stepCrochet);
    }

    public inline function updateSusLength():Float {
        return setSusLength(susLength);
    }

    public inline function setSusLength(mills:Float = 0.0):Float {
        repeatHeight = getMillPos(mills) + NoteUtil.swagHeight * 0.5;
        clipRect.height = repeatHeight;
        return repeatHeight;
    }

    public inline function setSusSecs(secs:Float = 0.0):Float {
        return setSusLength(secs * 1000);
    }

    override function updateSprites():Void {
        super.updateSprites();
        
        playAnim("hold" + CoolUtil.directionArray[noteData]);
        updateHitbox();
        offset.x -= NoteUtil.swagWidth * 0.5;
        offset.x += width * 0.5;

        final lastHeight = repeatHeight;
        setTiles(1, 1);
        origin.set(width * 0.5 / scale.x, 0);
        calcHeight = frameHeight;
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

    override function handleClipRect(tileFrame:FlxFrame, baseFrame:FlxFrame, tilePos:FlxPoint):Bool {
        clipRect.y = Math.min(clipRect.y, 0);
        return super.handleClipRect(tileFrame, baseFrame, tilePos);
    }

    override function applyCurOffset(forced:Bool = false):Void {
        // we dont need offsets for these
    }
}