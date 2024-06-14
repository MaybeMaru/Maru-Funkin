package funkin.util.frontend.modifiers;

import funkin.objects.note.BasicNote;

class ScriptModifier extends BasicModifier
{
    public function new(name:String, eachNote:Bool, defaultValues:Array<Dynamic>) {
        this.defaultValues = defaultValues;
        super(name, eachNote);
    }

    public var strumNote:(NoteStrum, BasicNote)->Void;
    public var strumUpdate:(NoteStrum, Float, Float)->Void;
    public var strumStep:(NoteStrum, Int)->Void;
    public var strumBeat:(NoteStrum, Int)->Void;
    public var strumSection:(NoteStrum, Int)->Void;

    override function manageStrumNote(strum:NoteStrum, note:BasicNote) {
        if (strumNote != null)
            strumNote(strum, note);
    }

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, timeElapsed:Float) {
        if (strumUpdate != null)
            strumUpdate(strum, elapsed, timeElapsed);
    }

    override function manageStrumStep(strum:NoteStrum, step:Int) {
        if (strumStep != null)
            strumStep(strum, step);
    }
    
    override function manageStrumBeat(strum:NoteStrum, beat:Int) {
        if (strumBeat != null)
            strumBeat(strum, beat);
    }

    override function manageStrumSection(strum:NoteStrum, section:Int) {
        if (strumSection != null)
            strumSection(strum, section);
    }

    var defaultValues:Array<Dynamic>;

    override function getDefaultValues() {
        return defaultValues.copy();
    }
}