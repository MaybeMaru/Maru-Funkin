package funkin.objects.note;

class Event {
    public var strumTime:Float = 0;
    public var name:String = "";
    public var values:Array<Dynamic> = [];
    public function new(strumTime:Float = 0, name:String = "", ?values:Array<Dynamic>) {
        this.strumTime = strumTime;
        this.name = name;
        this.values = (values != null ? values : []);
    }
}