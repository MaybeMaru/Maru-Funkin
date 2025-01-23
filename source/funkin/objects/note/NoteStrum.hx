package funkin.objects.note;

import funkin.util.frontend.modifiers.BasicModifier;
import funkin.objects.note.BasicNote.INoteData;

class NoteStrum extends FlxSpriteExt implements INoteData
{
    public var noteData:Int8 = 0;
	public var modifiers:Map<String, BasicModifier> = [];
	public var initPos:FlxPoint;
	public var centerOffset:FlxPoint;

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

	public function new(x:Float = 0, y:Float = 0, noteData:Int8 = 0):Void {
		super(x,y);
		initPos = FlxPoint.get(x, y);
		centerOffset = FlxPoint.get();
		this.noteData = noteData;
		ID = noteData;
		scaleOffset = true;
		loadSkin();
	}

	override function destroy() {
		super.destroy();
		modifiers = null;
		controlFunction = null;
		initPos = FlxDestroyUtil.put(initPos);
		centerOffset = FlxDestroyUtil.put(centerOffset);
	}

	public function loadSkin(?skin:String):Void {
		skin ??= SkinUtil.curSkin;
		if (curSkin != skin) {
			animOffsets.clear();
			curSkin = skin;
			loadJsonInput(SkinUtil.getSkinData(skin).strumData, 'skins/$skin');
			getWidth();
			applyCurOffset(true);
		}
	}

	// For centered notes
	public inline function getWidth():Void	{
		var lastAnim:Null<String> = null;
		if (animation.curAnim != null) {
			var name = animation.curAnim.name;
			lastAnim = name.split(CoolUtil.directionArray[noteData])[0];
		}
		
		playStrumAnim('static');
		updateHitbox();
		swagWidth = width;
		swagHeight = height;

		centerOffsets();
		centerOffset.copyFrom(offset);

		if (lastAnim != null) {
			playStrumAnim(lastAnim);
		}
	}

	public inline function playStrumAnim(anim:String = 'static', forced:Bool = false, ?data:Int) {
		data ??= noteData;
		playAnim(anim + CoolUtil.directionArray[data], forced);
	}

	public var xModchart:Float = 0.0;
    public var yModchart:Float = 0.0;

	override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		result = super.getScreenPosition(result, camera);
		result.add(xModchart, yModchart);
		result.subtract(centerOffset.x, centerOffset.y);
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