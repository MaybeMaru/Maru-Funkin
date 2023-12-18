package funkin.objects.note;

import flixel.graphics.frames.FlxFrame;

class Sustain extends BasicNote {
    public var susLength:Float = 0.0;
    
    public function new(noteData:Int = 0, strumTime:Float = 0.0, susLength:Float = 0.0, skin:String = "default", ?parentNote:Note) {
        super(noteData, strumTime, skin); // Load skin

        this.parentNote = parentNote;
        isSustainNote = true;
        drawStyle = BOTTOM_TOP;
        alpha = 0.6;
        
        this.susLength = susLength;
        setSusLength(susLength);

        //clipRect = new FlxRect(0,0,0,0);
    }

    function updateSusLength() {
        setSusLength(susLength);
    }

    function setSusLength(mills:Float = 0.0) {
        repeatHeight = getMillPos(mills) + NoteUtil.swagHeight * 0.5;
    }

    override function updateSprites() {
        super.updateSprites();
        updateHitbox();

        final holdFrame = animation.getByName("hold" + CoolUtil.directionArray[noteData]).frames[0];
        final holdWidth = frames.getByIndex(holdFrame).frame.width * scale.x;
        offset.x -= (NoteUtil.swagWidth * 0.5) - (holdWidth * scale.x * 0.5);

        final lastHeight = repeatHeight;
        setTiles(1, 1);
        repeatHeight = lastHeight;
    }

    override function setupTile(tileX:Int, tileY:Int, baseFrame:FlxFrame) {
        switch (tileY) {
            case 0: playAnim("hold" + CoolUtil.directionArray[noteData] + "-end");  // Tail
            case 1: playAnim("hold" + CoolUtil.directionArray[noteData]);           // Piece
        }
        return super.setupTile(tileX, tileY, frame);
    }

    override function applyCurOffset(forced:Bool = false) {
        // we dont need offsets for these
    }
}