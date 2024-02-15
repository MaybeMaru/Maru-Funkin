package funkin.objects.note;

class StrumLineGroup extends FlxTypedSpriteGroup<NoteStrum> {
    public var initPos:Array<FlxPoint> = [];
    public static var strumLineY:Float = 50;
    
    var startX:Float = 0;
    var offsetY:Float = 0;

    public function new(p:Int = 0, skipIntro:Bool = false, lanes:Int = Conductor.NOTE_DATA_LENGTH) {
        super(9);
        startX = NoteUtil.swagWidth * 0.666 + (FlxG.width * 0.5) * p;
        offsetY = Preferences.getPref('downscroll') ? 10 : -10;
        
        final isPlayer:Bool = p == 1;
        for (i in 0...lanes) {
			final strumNote = addStrum(i, skipIntro);
			ModdingUtil.addCall('generateStrum', [strumNote, isPlayer]);
		}
    }

    public static final DEFAULT_CONTROL_CHECKS:Array<(InputType)->Bool> = [
        function (t:InputType) return Controls.getKey('NOTE_LEFT', t),
        function (t:InputType) return Controls.getKey('NOTE_DOWN', t),
        function (t:InputType) return Controls.getKey('NOTE_UP', t),
        function (t:InputType) return Controls.getKey('NOTE_RIGHT', t),
    ];

    static var seperateWidth(default, never) = NoteUtil.swagWidth + 5;

    public function insertStrum(position:Int = 0, skipIntro:Bool = true) {
        if (members.length >= 9) return null; // STOP
        for (i in position...members.length) {
            final strum = members[i];
            if (strum == null) continue;
            strum.x += seperateWidth;
            strum.ID++;
        }
        return addStrum(position, skipIntro);
    }

    public function addStrum(noteData:Int = 0, skipIntro:Bool = true) {
        if (members.length >= 9) return null; // STOP
        final strumX:Float =  startX + seperateWidth * noteData;
		final strumNote:NoteStrum = new NoteStrum(strumX, strumLineY, noteData);
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
        initPos = FlxDestroyUtil.putArray(initPos);
    }
}