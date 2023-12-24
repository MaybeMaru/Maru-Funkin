package funkin.objects.note;

class Note extends BasicNote {
    public function new(noteData:Int = 0, strumTime:Float = 0.0, skin:String = "default", ?child:Sustain) {
        super(noteData, strumTime, skin); // Load skin
        this.child = child;
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

	override function update(elapsed:Float) {
		super.update(elapsed);
		calcHit();
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