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
				var point = CoolUtil.point;
				point.copyFrom(animOffsets.get(animation.curAnim.name));
				if (!point.isZero() || forced) {
                    if (flippedOffsets) point.x = -point.x;
					updateHitbox();
                    offset.add(point.x, point.y);
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