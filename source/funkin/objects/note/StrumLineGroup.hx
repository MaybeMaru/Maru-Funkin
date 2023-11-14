package funkin.objects.note;

class StrumLineGroup extends FlxTypedGroup<NoteStrum> {
    public var initPos:Array<FlxPoint> = [];
    public static var strumLineY:Float = 50;
    
    var startX:Float = 0;
    var offsetY:Float = 0;

    public function new(p:Int = 0, skipIntro:Bool = false, lanes:Int = Conductor.NOTE_DATA_LENGTH) {
        super(9);
        startX = NoteUtil.swagWidth * 0.666 + (FlxG.width / 2) * p;
        offsetY = Preferences.getPref('downscroll') ? 10 : -10;
        var isPlayer:Bool = p == 1;

        for (i in 0...lanes) {
			var strumNote = addStrum(i, skipIntro);
			ModdingUtil.addCall('generateStrum', [strumNote, isPlayer]);
		}
    }

    public static var DEFAULT_CONTROL_CHECKS(default, never):Array<Dynamic> = [
        function (type) return Controls.getKey('NOTE_LEFT$type'),
        function (type) return Controls.getKey('NOTE_DOWN$type'),
        function (type) return Controls.getKey('NOTE_UP$type'),
        function (type) return Controls.getKey('NOTE_RIGHT$type'),
    ];

    static var seperateWidth(default, never) = NoteUtil.swagWidth + 5;

    public function insertStrum(position:Int = 0, skipIntro:Bool = true) {
        if (members.length >= 9) return null; // STOP
        for (i in position...members.length) {
            var strum = members[i];
            if (strum == null) continue;
            strum.x += seperateWidth;
            strum.ID++;
        }
        return addStrum(position, skipIntro);
    }

    public function addStrum(noteData:Int = 0, skipIntro:Bool = true) {
        if (members.length >= 9) return null; // STOP
        var strumX:Float =  startX + seperateWidth * noteData;
		var strumNote:NoteStrum = new NoteStrum(strumX, strumLineY, noteData);
		strumNote.ID = noteData;
		strumNote.updateHitbox();
		strumNote.scrollFactor.set();
        add(strumNote);
        initPos.push(strumNote.getPosition());
			
		if (!skipIntro) {
			strumNote.alpha = 0;
			strumNote.y += offsetY;
		}

        if (noteData < DEFAULT_CONTROL_CHECKS.length) {
            strumNote.controlFunction = DEFAULT_CONTROL_CHECKS[noteData];
        }

        return strumNote;
    }

    override function destroy() {
        super.destroy();
        FlxDestroyUtil.putArray(initPos);
    }
}