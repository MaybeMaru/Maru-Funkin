package funkin.objects.funkui;

interface IFunkUIObject {
	public var ogX:Float;
	public var ogY:Float;
	public function setUIPosition(X:Float, Y:Float):Void;
}