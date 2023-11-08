package funkin.objects.note;

class NoteStrum extends FlxSpriteExt implements INoteData {
    public var noteData:Int = 0;
	public var swagWidth:Float = 110;
	public var swagHeight:Float = 110;
	public var staticTime:Float = 0;
	public var curSkin:String = '';

	public var controlFunction:Dynamic = null;
	public function getControl(type:String = "") {
		if (controlFunction == null) return false;
		return controlFunction(type);
	}

	public function new(x:Float = 0, y:Float = 0, noteData:Int = 0):Void {
		super(x,y);
		this.noteData = noteData;
		loadSkin();
	}

	public function loadSkin(?skin:String):Void {
		skin = skin ?? SkinUtil.curSkin;
		if (curSkin != skin) {
			animOffsets = new Map<String, FlxPoint>();
			curSkin = skin;
			loadJsonInput(SkinUtil.getSkinData(skin).strumData, 'skins/$skin');
			getWidth();
		}
	}

	inline function getWidth():Void	{ // For centered notes
		var lastAnim:Null<String> = animation.curAnim != null ? animation.curAnim.name.split(CoolUtil.directionArray[noteData])[0] : null;
		updateHitbox();
		playStrumAnim('static');
		swagWidth = width;
		swagHeight = height;
		if (lastAnim != null) {
			playStrumAnim(lastAnim);
		}
	}

	public function applyOffsets():Void {
		if (animation.curAnim == null) return;
		updateHitbox();
		centerOffsets();
		final getAnim = animOffsets.get(animation.curAnim.name);
		if (getAnim != null) {
			final scaleOff = getScaleDiff();
			offset.add(getAnim.x * scaleOff.x, getAnim.y * scaleOff.y);
		}
	}

	public function playStrumAnim(anim:String = 'static', forced:Bool = false, ?data:Int) {
		playAnim('$anim${CoolUtil.directionArray[data ?? noteData]}', forced);
		applyOffsets();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (staticTime > 0) {
			staticTime-=elapsed;
			if (staticTime <= 0) {
				playStrumAnim('static');
				staticTime = 0;
			}
		}
	}
}