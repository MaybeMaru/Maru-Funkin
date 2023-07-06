package funkin.graphics.note;

class NoteStrum extends FlxSpriteUtil {
    public var noteData:Int = 0;
	public var swagWidth:Float = 100;
	public var swagHeight:Float = 100;
	public var staticTime:Float = 0;
	public var curSkin:String = '';

	public function new(x:Float = 0, y:Float = 0, noteData:Int = 0):Void {
		super(x,y);
		this.noteData = noteData;
		loadSkin();
	}

	public function loadSkin(?skin:String):Void {
		skin = skin == null ? SkinUtil.curSkin : skin;
		if (curSkin != skin) {
			animOffsets = new Map<String, FlxPoint>();
			curSkin = skin;
			loadJsonInput(SkinUtil.getSkinData(skin).strumData, 'skins/$skin');
			getWidth();
		}
	}

	public function getWidth():Void	{	//For centered notes
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
		if (animation.curAnim != null) {
			updateHitbox();
			centerOffsets();
			var getAnim = animOffsets.get(animation.curAnim.name);
			if (getAnim != null) {
				offset.x += getAnim.x;
				offset.y += getAnim.y;
			}
		}
	}

	public function playStrumAnim(anim:String = 'static', forced:Bool = false, ?data:Int) {
		data = (data == null) ? noteData : data;
		playAnim('$anim${CoolUtil.directionArray[data]}', forced);
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