package funkin.util.frontend.modifiers;

import funkin.objects.note.BasicNote;

class ScriptModifier extends BasicModifier
{
    public function new(name:String, eachNote:Bool, defaultValues:Array<Dynamic>) {
        this.defaultValues = defaultValues;
        super(name, eachNote);
    }

    public var modInit:(Array<Dynamic>)->Void;
    public var strumNote:(NoteStrum, BasicNote, Array<Dynamic>)->Void;
    public var strumUpdate:(NoteStrum, Float, Float, Array<Dynamic>)->Void;
    public var strumStep:(NoteStrum, Int, Array<Dynamic>)->Void;
    public var strumBeat:(NoteStrum, Int, Array<Dynamic>)->Void;
    public var strumSection:(NoteStrum, Int, Array<Dynamic>)->Void;

    override function init() {
        if (modInit != null)
            modInit(data);
    }

    override function manageStrumNote(strum:NoteStrum, note:BasicNote) {
        if (strumNote != null)
            strumNote(strum, note, data);
    }

    override function manageStrumUpdate(strum:NoteStrum, elapsed:Float, beat:Float) {
        if (strumUpdate != null)
            strumUpdate(strum, elapsed, beat, data);
    }

    override function manageStrumStep(strum:NoteStrum, step:Int) {
        if (strumStep != null)
            strumStep(strum, step, data);
    }
    
    override function manageStrumBeat(strum:NoteStrum, beat:Int) {
        if (strumBeat != null)
            strumBeat(strum, beat, data);
    }

    override function manageStrumSection(strum:NoteStrum, section:Int) {
        if (strumSection != null)
            strumSection(strum, section, data);
    }

    var defaultValues:Array<Dynamic>;

    override function getDefaultValues() {
        return defaultValues.copy();
    }
}