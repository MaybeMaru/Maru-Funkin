package funkin.objects.note;

import funkin.util.frontend.ModchartManager.ModchartData;
import funkin.objects.note.BasicNote.INoteData;

class NoteStrum extends FlxSpriteExt implements INoteData
{
    public var noteData:Int = 0;
	public var modchart:ModchartData;
	
	public var swagWidth:Float = 110;
	public var swagHeight:Float = 110;
	public var staticTime:Float = 0;
	public var curSkin:String = '';

	public var controlFunction:InputType->Bool;
	public var strumActive:Bool = true;
	
	public function getControl(inputType:InputType = PRESSED):Bool {
		if (strumActive) if (controlFunction != null)
			return controlFunction(inputType);
		
		return false;
	}

	public function new(x:Float = 0, y:Float = 0, noteData:Int = 0):Void {
		super(x,y);
		this.noteData = noteData;
		loadSkin();
	}

	override function destroy() {
		super.destroy();
		modchart = null;
		controlFunction = null;
	}

	public function loadSkin(?skin:String):Void {
		skin ??= SkinUtil.curSkin;
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

	dynamic public function applyOffsets():Void {
		if (animation.curAnim != null) {
			updateHitbox();
			centerOffsets();
			var animOffset = animOffsets.get(animation.curAnim.name);
			if (animOffset != null) {
				var scaleDiff = getScaleDiff();
				offset.add(animOffset.x * scaleDiff.x, animOffset.y * scaleDiff.y);
			}
		}
	}

	public inline function playStrumAnim(anim:String = 'static', forced:Bool = false, ?data:Int) {
		playAnim(anim + CoolUtil.directionArray[data ?? noteData], forced);
		applyOffsets();
	}

	public var xModchart:Float = 0.0;
    public var yModchart:Float = 0.0;

	override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		result = super.getScreenPosition(result, camera);
		result.add(xModchart, yModchart);
		return result;
	}

	override public function update(elapsed:Float):Void {
		__superUpdate(elapsed);

		if (staticTime > 0) {
			staticTime -= elapsed;
			if (staticTime <= 0) {
				playStrumAnim('static');
				staticTime = 0;
			}
		}
	}
}