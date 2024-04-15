package funkin.objects.note;

import funkin.objects.note.BasicNote.INoteData;

typedef ModchartValues = {
	var startX:Float;
	var startY:Float;

	var sinOff:Float;
	var sinSize:Float;
	var cosOff:Float;
	var cosSize:Float;
}

class NoteStrum extends FlxSpriteExt implements INoteData {
    public var noteData:Int = 0;
	public var modchart:ModchartValues;
	
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

		modchart = {
			startX: 0.0,
			startY: 0.0,

			sinOff: 0.0,
			sinSize: 50.0,
			cosOff: 0.0,
			cosSize: 50.0
		}
	}

	override function destroy() {
		super.destroy();
		modchart = null;
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

	public dynamic function applyOffsets():Void {
		var curAnim = animation.curAnim;
		if (curAnim != null) {
			updateHitbox();
			centerOffsets();
			var animOffset = animOffsets.get(curAnim.name);
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