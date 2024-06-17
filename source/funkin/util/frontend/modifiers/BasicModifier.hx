package funkin.util.frontend.modifiers;

import funkin.objects.note.BasicNote;

class BasicModifier
{
    public var name(default, null):String;
    public var eachNote(default, null):Bool;
    public var data:Array<Dynamic>;

    public function new(name:String, eachNote:Bool) {
        this.name = name;
        this.eachNote = eachNote;
        this.data = getDefaultValues();
    }

    // For each strum note (that isnt a sustain)
    public function manageStrumNote(strum:NoteStrum, note:BasicNote) {}

    // Called every frame
    public function manageStrumUpdate(strum:NoteStrum, elapsed:Float, beat:Float) {}

    // Called every song step
    public function manageStrumStep(strum:NoteStrum, step:Int) {}

    // Called every song beat
    public function manageStrumBeat(strum:NoteStrum, beat:Int) {}
    
    // Called every song section
    public function manageStrumSection(strum:NoteStrum, section:Int) {}

    public function getDefaultValues():Array<Dynamic> {
        return [];
    }

    // BACKEND UTIL

    inline function beatRads(beat:Float, snap:Float) {
        return beat * ((0.25 / snap) * FunkMath.PI);
    }

    inline function scale(value:Float) {
        return value * ((NoteUtil.noteWidth + NoteUtil.noteHeight) / 4);
    }

    inline function scaleWidth(value:Float) {
        return value * (NoteUtil.noteWidth / 2);
    } 
    
    inline function scaleHeight(value:Float) {
        return value * (NoteUtil.noteHeight / 2);
    } 
}