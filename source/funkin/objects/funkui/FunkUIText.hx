package funkin.objects.funkui;

class FunkUIText extends FlxFunkText {
    public function new(?X:Float, ?Y:Float, Text:String, ?Width:Float) {
        super(X,Y,Text,FlxPoint.weak(Width ?? FlxG.width, 20), 16);
        font = "roboto";
    }
}