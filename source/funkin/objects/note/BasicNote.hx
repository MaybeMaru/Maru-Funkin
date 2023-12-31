package funkin.objects.note;

import haxe.ds.Vector;
import funkin.graphics.SmartSprite;

interface INoteData {
    public var noteData:Int;
}

class BasicNote extends SmartSprite implements INoteData {
    public var strumTime:Float = 0.0;
    public var noteData:Int = 0;
    public var mustPress:Bool = false;
    public var parent:Note;
    public var child:Sustain;

    public var targetStrum(default, set):NoteStrum;
    function set_targetStrum(value:NoteStrum):NoteStrum {
        return targetStrum = value;
    }

    public var noteSpeed(default, set):Float = 1.0;
    function set_noteSpeed(value:Float):Float {
        return noteSpeed = value;
    }
    
    public var isSustainNote(default, set):Bool = false;
    inline function set_isSustainNote(value:Bool):Bool {
        renderMode = value ? REPEAT : QUAD;
        return isSustainNote = value;
    }

    private var curSkinData:SkinSpriteData;
    public var skin(default, set):String = "default";
    inline function set_skin(?value:String) {
        skin = value ?? SkinUtil.curSkin;
        curSkinData = NoteUtil.getSkinSprites(skin);
        updateSprites();
        return skin;
    }

    public function changeSkin(?value:String):Void {
        if (value != skin)
            skin = value;
    }

    public function updateSprites():Void {
        loadFromSprite(curSkinData.baseSprite);
    }

    public var approachAngle(default, set):Float = 0;
    function set_approachAngle(value:Float):Float {
        if (approachAngle != value) calcApproachTrig(value);
        return approachAngle = value;
    }

    var _approachCos(default, null):Float = 1.0;
    var _approachSin(default, null):Float = 0.0;

    inline function calcApproachTrig(value:Float) {
        #if FAST_MATH
        _approachCos = FlxMath.fastCos(value * CoolUtil.TO_RADS);
        _approachSin = FlxMath.fastSin(value * CoolUtil.TO_RADS);
        #else
        _approachCos = Math.cos(value * CoolUtil.TO_RADS);
        _approachSin = Math.sin(value * CoolUtil.TO_RADS);
        #end
    }
    
    public var spawnMult:Float = 1.0;

    public function new(noteData:Int = 0, strumTime:Float = 0.0, skin:String = "default"):Void {
        super();
        initVariables();
        this.noteData = noteData;
        this.strumTime = strumTime;
        this.skin = skin;
        approachAngle = Preferences.getPref('downscroll') ? 180 : 0;
        moves = false; // Save on velocity calculation
    }

    public var moving:Bool = true;
    public var susLength:Float = 0.0;

    public function removeNote() {
        alive = exists = false;
        FlxG.signals.preUpdate.addOnce(function () {
            if (NotesGroup.instance != null) NotesGroup.instance.notes.remove(this, true);
            this.destroy();
        });
    }

    public var activeNote:Bool = true;

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        if (targetStrum != null) {
            if (moving) moveToStrum();
            activeNote = Conductor.songPosition < (strumTime + susLength + getPosMill(NoteUtil.swagHeight * 2));
        }
    }

    public var noteMove(default, null):Float = 0.0; // Distance position value between the note and the strum
    public var xDisplace:Float = 0.0;
    public var yDisplace:Float = 0.0;

    inline public function moveToStrum():Void {
        setPositionToStrum();
        noteMove = distanceToStrum(); // Position with strumtime
        y -= noteMove * _approachCos;
        x -= noteMove * -_approachSin;
    }

    inline public function setPositionToStrum() {
        y = targetStrum.y + yDisplace;
        x = targetStrum.x + xDisplace;
    }

    inline public function distanceToStrum():Float {
        return getMillPos(Conductor.songPosition - strumTime);
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

    inline function initVariables():Void {
        hitHealth = new Vector<Float>(2);
        hitHealth[0] = 0.025;
        hitHealth[1] = 0.0125;
        
        missHealth = new Vector<Float>(2);
        missHealth[0] = 0.0475;
        missHealth[1] = 0.02375;
    }

    public var noteType(default, set):String = "default";
    inline function set_noteType(value:String):String {
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

    public function changeNoteType(value:String):Void {
        if (noteType != value)
            noteType = value;
    }

    // Casts the basic note as a Note
    inline public function toNote():Note {
        return cast(this, Note);
    }
    
    // Casts the basic note as a Sustain
    inline public function toSustain():Sustain {
        return cast(this, Sustain);
    }
}