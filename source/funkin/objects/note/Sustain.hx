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
    
    public function new(noteData:Int = 0, strumTime:Float = 0.0, susLength:Float = 0.0, skin:String = "default", ?parentNote:TestNote) {
        super(noteData, strumTime, skin); // Load skin

        this.parentNote = parentNote;
        isSustainNote = true;
        drawStyle = BOTTOM_TOP;
        alpha = 0.6;
        
        this.susLength = susLength;
        setSusLength(susLength);

        //clipRect = new FlxRect(0,0,0,0);
    }

    public inline function updateSusLength() {
        return setSusLength(susLength);
    }

    public inline function setSusLength(mills:Float = 0.0) {
        return repeatHeight = getMillPos(mills) + NoteUtil.swagHeight * 0.5;
    }

    public inline function setSusSecs(secs:Float = 0.0) {
        return setSusLength(secs * 1000);
    }

    override function updateSprites() {
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
    }

    override function setupTile(tileX:Int, tileY:Int, baseFrame:FlxFrame) {
        switch (tileY) {
            case 0: playAnim("hold" + CoolUtil.directionArray[noteData] + "-end");  // Tail
            case 1: playAnim("hold" + CoolUtil.directionArray[noteData]);           // Piece
        }
        return super.setupTile(tileX, tileY, frame);
    }

    override function applyCurOffset(forced:Bool = false) {
        // we dont need offsets for these
    }
}