package funkin.objects.note;

import funkin.graphics.SmartSprite;

class BasicNote extends SmartSprite {
    public var strumTime:Float = 0.0;
    public var noteData:Int = 0;
    public var noteSpeed:Float = 1.0;
    public var targetStrum:NoteStrum;
    public var parentNote:Note;
    public var childNote:Sustain;
    
    public var isSustainNote(default, set):Bool = false;
    inline function set_isSustainNote(value:Bool) {
        renderMode = value ? REPEAT : QUAD;
        return isSustainNote = value;
    }

    private var curSkinData:SkinMapData;
    public var skin(default, set):String = "default";
    inline function set_skin(?value:String) {
        skin = value ?? SkinUtil.curSkin;
        curSkinData = NoteUtil.getSkinSprites(skin, noteData);
        updateSprites();
        return skin;
    }

    public function changeSkin(?value:String) {
        if (value != skin)
            skin = value;
    }

    public function updateSprites() {
        loadFromSprite(curSkinData.baseSprite);
    }

    public var approachAngle:Float = 0;
    public var spawnMult:Float = 1.0;

    public function new(noteData:Int = 0, strumTime:Float = 0.0, skin:String = "default") {
        super();
        this.noteData = noteData;
        this.strumTime = strumTime;
        this.skin = skin;
        approachAngle = Preferences.getPref('downscroll') ? 180 : 0;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (targetStrum != null) {
            moveToStrum();
        }
    }

    inline public function moveToStrum() {
        final noteMove:Float = getMillPos(Conductor.songPosition - strumTime); // Position with strumtime
        y = targetStrum.y - (noteMove * getCos()); // Set Position
        x = targetStrum.x - (noteMove * -getSin());
    }

    inline public function getCos() {
        return FlxMath.fastCos(FlxAngle.asRadians(approachAngle));
    }

    inline public function getSin() {
        return FlxMath.fastSin(FlxAngle.asRadians(approachAngle));
    }

    // Converts song milliseconds to a position on screen
    inline public function getMillPos(mills:Float):Float {
        return mills * (0.45 * noteSpeed);
    }

    // Converts a position on screen to song milliseconds
    inline public function getPosMill(pos:Float):Float { 
        return pos / (0.45 * noteSpeed);
    }
}