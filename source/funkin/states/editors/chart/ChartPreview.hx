package funkin.states.editors.chart;
import openfl.geom.Rectangle;

class ChartPreview extends FlxSprite {
    inline private static var NOTE_WIDTH:Int = 20;
    inline private static var NOTE_HEIGHT:Int = 2;
    inline private static var STRUMS_LENGTH:Int = 8;
    public var moveConductor:Bool = true;

    public function new (moveConductor:Bool = true):Void {
        super(50,100);
        makeGraphic(NOTE_WIDTH * STRUMS_LENGTH, NOTE_HEIGHT, FlxColor.GRAY);
        updateHitbox();
        antialiasing = false;
        this.moveConductor = moveConductor;
    }

    var SIZE_CALC:Float = 0;

    public function startDraw(?sections:Array<SwagSection>, secTime:Float = 0):Void {
        var notes:Array<Dynamic> = [];
        if (sections != null) {
            if (sections[0] != null)
                notes = moveConductor ? Song.sortSections(sections) : sections[0].sectionNotes;
        } else sections = [];

        SIZE_CALC = NOTE_HEIGHT / Conductor.crochet*4;

        var pCol:Int = (moveConductor ? 150 : 0);
        makeGraphic(NOTE_WIDTH*STRUMS_LENGTH, (moveConductor ? getSectionsLength(sections) : 1) * 16 * NOTE_HEIGHT, FlxColor.TRANSPARENT);
        updateHitbox();
        pixels.fillRect(new Rectangle(0,0, width * 1.5, height * 1.5), FlxColor.fromRGB(pCol,pCol,pCol,64));
        if (moveConductor) {
            drawSections(sections);
        }
        drawSong(secTime, notes);
        pixels.fillRect(new Rectangle(moveConductor ? width * 0.5 - NOTE_HEIGHT * 0.5 : width * 0.5 + NOTE_WIDTH, 0, NOTE_HEIGHT, height), FlxColor.fromRGB(0,0,0,50));
    }

    private function getSectionsLength(sections:Array<SwagSection>):Int {
        var lastFilled:Int = 0;
        for (i in 0...sections.length) {
            if (sections[i] != null) {
                if (sections[i].sectionNotes != null) {
                    if (sections[i].sectionNotes.length > 0)
                        lastFilled = i+1;
                }
            }
        }
        return lastFilled;
    }

    public function drawSections(sections:Array<SwagSection>):Void {
        var col = FlxColor.fromRGB(0,0,0,25);
        for (i in 0...sections.length) {
            if (sections[i] != null) {
                if (sections[i].sectionNotes != null) {
                    if (sections[i].sectionNotes.length > 0)
                        pixels.fillRect(new Rectangle(0, i * 16 * NOTE_HEIGHT - NOTE_HEIGHT, NOTE_WIDTH*STRUMS_LENGTH, NOTE_HEIGHT), col);
                }
            }
        }
    }

    public function drawSong(secTime:Float = 0, notes:Array<Dynamic>):Void {
        var conducPos = Conductor.songPosition;
        if (notes!=null) {
            for (i in 0...notes.length) {
                var note:Array<Dynamic> = notes[i];
                var pY:Float = (note[0] - secTime) * SIZE_CALC;
                var yDiff:Float = (note[0] - conducPos) * SIZE_CALC;
                
                // This is rly messy but bare with me
                if ((moveConductor && (yDiff < FlxG.height) && (yDiff > -100)) || !moveConductor) {
                   var noteColor = getNoteColor(note);
                    pixels.fillRect(new Rectangle(note[1]*NOTE_WIDTH, pY, NOTE_WIDTH, NOTE_HEIGHT), noteColor);
                    if (note[2] > 0) {
                        pixels.fillRect(new Rectangle(note[1] * NOTE_WIDTH + NOTE_WIDTH * 0.25, pY + NOTE_HEIGHT,
                        Std.int(NOTE_WIDTH * 0.5), Std.int(note[2] * SIZE_CALC)), FlxColor.fromRGB(noteColor.red, noteColor.green, noteColor.blue, Std.int(255*0.6)));
                    }
                }
            }
        }
    } 
    private static var DEFAULT_COLORS:Array<String> = ['0xffc24b99', '0xff00ffff', '0xff12fa05', '0xfff9393f'];
    private static var skinColorArray:Map<String, Array<String>> = [];
    private function getNoteColor(note:Array<Dynamic>):FlxColor {//:Array<Int> {
        var skin = NoteUtil.getTypeJson(NoteUtil.getTypeName(note[3])).skin;
        skin = (skin != null) ? skin : SkinUtil.curSkin;
        if (skinColorArray[skin] == null) {
            skinColorArray[skin] = DEFAULT_COLORS.copy();
            if (SkinUtil.getSkinData(skin) != null) {
                if (SkinUtil.getSkinData(skin).noteData != null) {
                    if (SkinUtil.getSkinData(skin).noteData.noteColorArray != null)
                        skinColorArray[skin] =  SkinUtil.getSkinData(skin).noteData.noteColorArray;
                }
            }
        }
        return FlxColor.fromString(skinColorArray[skin][Std.int(note[1]%4)]);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (moveConductor)
            offset.y = Conductor.songPosition * SIZE_CALC;
    }
}