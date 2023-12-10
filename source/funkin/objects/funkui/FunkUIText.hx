package funkin.objects.funkui;

class FunkUIText extends FlxFunkText {
    public function new(?X:Float, ?Y:Float, Text:String, ?Width:Float, ?Height:Int, ?Size:Int) {
        super(X,Y,Text,FlxPoint.weak(Width ?? FlxG.width, Height ?? 20), Size ?? 15);
        font = "roboto";
    }
}