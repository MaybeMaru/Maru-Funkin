package funkin.objects.note;

import flixel.graphics.frames.FlxFrame;
import funkin.graphics.FlxRepeatSprite;

class Sustain extends FlxRepeatSprite implements INoteData {
    public var noteData:Int = 0;
    
    public function new(noteData:Int = 0) {
        super();
        drawStyle = BOTTOM_TOP;
        alpha = 0.6;
        this.noteData = noteData % Conductor.NOTE_DATA_LENGTH;
        
        changeSkin("default");
    }

    var skinData:SkinMapData;

    public function changeSkin(value:String = "default") {
        skinData = NoteUtil.getSkinSprites(value, noteData);
        loadFromSprite(skinData.baseSprite);
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
            case 0: playAnim("hold" + CoolUtil.directionArray[noteData] + "-end");
            case 1: playAnim("hold" + CoolUtil.directionArray[noteData]);
        }
        return super.setupTile(tileX, tileY, frame);
    }

    override function applyCurOffset(forced:Bool = false) {
        // we dont need offsets for these
    }
}