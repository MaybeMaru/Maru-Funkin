package funkin.objects.note;

class StrumLineGroup extends FlxTypedGroup<NoteStrum> {
    public var initPos:Array<FlxPoint> = [];
    public static var strumLineY:Float = 50;

    public function new(p:Int = 0, skipIntro:Bool = false, lanes:Int = Conductor.NOTE_DATA_LENGTH) {
        super();
        var startX:Float = NoteUtil.swagWidth * 0.666 + (FlxG.width / 2) * p;
		var offsetY:Float = Preferences.getPref('downscroll') ? 10 : -10;
        var isPlayer:Bool = p == 1;

        for (i in 0...lanes) {
			var strumX:Float =  startX + (NoteUtil.swagWidth + 5) * i;
			var strumNote:NoteStrum = new NoteStrum(strumX, strumLineY, i);
			strumNote.ID = i;
			strumNote.updateHitbox();
			strumNote.scrollFactor.set();
            add(strumNote);
            initPos.push(strumNote.getPosition());
			
			if (!skipIntro) {
				strumNote.alpha = 0;
				strumNote.y += offsetY;
			}

			ModdingUtil.addCall('generateStrum', [strumNote, isPlayer]);
		}
    }
}