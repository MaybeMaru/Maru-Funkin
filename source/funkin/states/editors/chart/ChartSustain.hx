package funkin.states.editors.chart;

class ChartSustain extends FlxSpriteGroup {
    /*var sustain:Note;
    var sustainEnd:Note;

    public function new():Void {
        super();
        scrollFactor.set(1,1);
        sustain = new Note();
        sustainEnd = new Note();
        add(sustain);
        add(sustainEnd);
    }

    public function setupSus(note:Note, length:Float = 0, ?gridData:Array<Int>):Void {
        setPosition(note.x,note.y);
        gridData = (gridData != null) ? gridData : [40,40*Conductor.STEPS_SECTION_LENGTH];
        
        if (note.curSkin != sustain.curSkin) {
            sustain.loadSkin(note.curSkin);
            sustainEnd.loadSkin(note.curSkin);
        }

        sustain.setPosition(note.x,note.y);
        sustainEnd.setPosition(note.x,note.y);
        var holdAnim:String = 'hold${CoolUtil.directionArray[note.noteData]}';
        sustain.playAnim(holdAnim, true);
        sustainEnd.playAnim('$holdAnim-end', true);
        sustain.updateHitbox();
        sustainEnd.updateHitbox();

        drawSus(length, gridData);
        x += note.width/2 - width/2;
        y += gridData[0]/2;
        color = note.color;
    }

    public function drawSus(length:Float = 0, gridData:Array<Int>):Void {
        var leScale = SkinUtil.getSkinData(sustainEnd.curSkin).noteData.scale;
        switch (sustainEnd.curSkin) {
            case 'pixel':   leScale = Std.int(leScale/2.5);
        }

        var leHeight:Int = Std.int(FlxMath.remapToRange(length, 0, Conductor.stepCrochet * Conductor.STEPS_SECTION_LENGTH, 0, gridData[1]) + gridData[0]/2);
        var leSize:Int = Std.int(gridData[0]/2);
        var scaledSize:Int = Std.int(leSize*leScale);

        sustainEnd.setGraphicSize(scaledSize);
        sustainEnd.updateHitbox();
        switch (sustainEnd.curSkin) {
            case 'pixel':   leHeight -= Std.int(scaledSize/4);
            default:        leHeight -= scaledSize;
        }
        sustainEnd.y += leHeight;

        sustain.setGraphicSize(scaledSize, leHeight);
        sustain.updateHitbox();

        alpha = 0.6;
    }

	/*var colorList:Array<Int> = (PlayState.isPixel) ? CoolUtil.pixelNoteColorArray : CoolUtil.noteColorArray;
    var susColor:Int = colorList[daNoteData%4];
    var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2) - 4,
    note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * Conductor.STEPS_SECTION_LENGTH, 0, gridBG.height)), susColor);
    curRenderedSustains.add(sustainVis);*/
}