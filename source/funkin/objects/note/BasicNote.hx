package funkin.objects.note;

import openfl.Vector;
import funkin.objects.note.Sustain.TestNote;
import funkin.graphics.SmartSprite;

class BasicNote extends SmartSprite implements INoteData {
    public var strumTime:Float = 0.0;
    public var noteData:Int = 0;
    public var noteSpeed:Float = 1.0;
    public var targetStrum:NoteStrum;
    public var parentNote:TestNote;
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
        initVariables();
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

    public var mustHit:Bool = true;
    public var altAnim:String = "";
    public var hitHealth:Vector<Float>;
    public var missHealth:Vector<Float>;
    public var hitMult:Float = 1.0;

    inline function initVariables() {
        hitHealth = new Vector<Float>(2, true, [0.025, 0.0125]);
        missHealth = new Vector<Float>(2, true, [0.0475, 0.02375]);
    }

    public var noteType(default, set):String = "default";
    inline function set_noteType(value:String) {
        final typeJson:NoteTypeJson = NoteUtil.getTypeJson(value);
        mustHit = typeJson.mustHit;
        altAnim = typeJson.altAnim;

        for (i in 0...2) {
            hitHealth[i] = typeJson.hitHealth[i];
            missHealth[i] = typeJson.missHealth[i];
        }

        hitMult = FlxMath.bound(typeJson.hitMult, 0.01, 1);
        changeSkin(typeJson.skin);
        
        return noteType = value;
    }

    public function changeNoteType(value:String) {
        if (noteType != value)
            noteType = value;
    }
}