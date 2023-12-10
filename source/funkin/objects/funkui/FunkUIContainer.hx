package funkin.objects.funkui;

class FunkUIContainer extends FourSideSprite{
    private var __group:FlxGroup;
    
    public var displacement:FlxPoint = FlxPoint.get();
    
    public function new(?X:Float, ?Y:Float, Width:Int = 500, Height:Int = 500) {
        __group = new FlxGroup();
        super(X, Y, Width,Height,0xff212325);
    }

    function __updatePositions() {
        for (i in 0...__group.members.length) {
            final object:Dynamic = __group.members[i];
            object.setUIPosition(displacement.x + object.ogX + x, displacement.y + object.ogY + y);
        }
    }

    public function setDisplacement(X:Float = 0, Y:Float = 0) {
        displacement.set(X,Y);
        __updatePositions();
    }

    override function set_x(value:Float):Float {
        super.set_x(x = value);
        __updatePositions();
        return value;
    }

    override function set_y(value:Float):Float {
        super.set_y(y = value);
        __updatePositions();
        return value;
    }

    public function add(object:IFunkUIObject) {
        object.setUIPosition(displacement.x + object.ogX + x, displacement.y + object.ogY + y);
        __group.add(cast object);
    }

    override function draw() {
        super.draw();
        __group.draw();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        __group.update(elapsed);
    }

    override function destroy() {
        super.destroy();
        __group = FlxDestroyUtil.destroy(__group);
        displacement = FlxDestroyUtil.put(displacement);
    }
}