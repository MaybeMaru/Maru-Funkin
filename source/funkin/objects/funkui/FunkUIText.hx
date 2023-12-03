package funkin.objects.funkui;

class FunkUIText extends FlxFunkText {
    public function new(?X:Float, ?Y:Float, Text:String, ?Width:Float, ?Height:Int) {
        super(X,Y,Text,FlxPoint.weak(Width ?? FlxG.width, Height ?? 20), 16);
        font = "roboto";
    }
}