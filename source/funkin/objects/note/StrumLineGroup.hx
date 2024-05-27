package funkin.objects.note;

class StrumLineGroup extends TypedSpriteGroup<NoteStrum>
{
    public static var strumLineY:Float = 50;

    public var initPos:Array<FlxPoint> = [];
    
    var startX:Float = 0;
    var offsetY:Float = 0;

    public function new(p:Int = 0, lanes:Int = Conductor.NOTE_DATA_LENGTH) {
        super(9);
        startX = NoteUtil.noteWidth * 0.666 + (FlxG.width * 0.5) * p;
        offsetY = Preferences.getPref('downscroll') ? 10 : -10;
        
        final isPlayer:Bool = p == 1;
        for (i in 0...lanes) {
			final strumNote = addStrum(i);
			ModdingUtil.addCall('generateStrum', [strumNote, isPlayer]);
		}
    }

    public static final DEFAULT_CONTROL_CHECKS:Array<InputType->Bool> = [
        (t:InputType) -> return Controls.getKey('NOTE_LEFT', t),
        (t:InputType) -> return Controls.getKey('NOTE_DOWN', t),
        (t:InputType) -> return Controls.getKey('NOTE_UP', t),
        (t:InputType) -> return Controls.getKey('NOTE_RIGHT', t)
    ];

    static inline var seperateWidth:Int = NoteUtil.noteWidth + 5;

    public function insertStrum(position:Int = 0) {
        if (members.length >= 9)
            return null; // STOP
        
        for (i in position...members.length) {
            if (members[i] == null)
                continue;
            
            members[i].x += seperateWidth;
            members[i].ID++;
        }

        return addStrum(position);
    }

    public function introStrums() {
        members.fastForEach((strum, i) -> {
            strum.alpha = 0;
			strum.y += offsetY;
            FlxTween.tween(strum, {y: strum.y - offsetY, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * strum.noteData)});
        });
    }

    public function checkStrums():Void {
        members.fastForEach((strum, i) -> {
			if (strum.animation.curAnim != null) // Lil null check
			{
				if (strum.getControl(JUST_PRESSED)) if (!strum.animation.curAnim.name.startsWith('confirm'))
					strum.playStrumAnim('pressed');
				
				if (!strum.getControl())
					strum.playStrumAnim('static');
			}
		});
    }

    public function checkCharSinging(char:Character):Void {
        if (char == null) return;
        if (char.animation.curAnim == null) return;

        if (char.holdTimer > (Conductor.stepCrochetMills * Conductor.STEPS_PER_BEAT))
        {
            final name:String = char.animation.curAnim.name;
            
            // Character is over-singing
            if (name.startsWith('sing')) if (!name.endsWith('miss'))
            {
                var isHolding:Bool = false;
                members.fastForEach((strum, i) ->
                {
                    if (strum.animation.curAnim != null) if (strum.animation.curAnim.name.startsWith('confirm')) {
                        isHolding = true;
                        break;
                    }
                });
    
                if (!isHolding)
                    char.restartDance();
            }
        }
    }

    public function addStrum(noteData:Int = 0)
    {
        if (members.length >= 9) // STOP
            return null;
        
        var x:Float = startX + seperateWidth * noteData;
		var strum:NoteStrum = new NoteStrum(x, strumLineY, noteData);
        initPos.push(strum.getPosition());
		strum.scrollFactor.set();
        add(strum);

        if (noteData < DEFAULT_CONTROL_CHECKS.length) {
            strum.controlFunction = DEFAULT_CONTROL_CHECKS[noteData];
        }

        return strum;
    }

    override function destroy() {
        super.destroy();
        initPos = FlxDestroyUtil.putArray(initPos);
    }
}