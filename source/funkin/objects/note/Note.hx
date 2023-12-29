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

	@:noCompletion
	static final __noteOffset:FlxPoint = FlxPoint.get();

    override function applyCurOffset(forced:Bool = false) {
        if (animation.curAnim != null) {
			if(existsOffsets(animation.curAnim.name)) {
				__noteOffset.copyFrom(animOffsets.get(animation.curAnim.name));
				if (!__noteOffset.isZero() || forced) {
					__noteOffset.x *= (flippedOffsets ? -1 : 1);
                    updateHitbox();
                    offset.add(__noteOffset.x, __noteOffset.y);
				}
			}
		}
    }

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (targetStrum != null)
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