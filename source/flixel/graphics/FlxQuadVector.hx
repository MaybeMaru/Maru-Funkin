package flixel.graphics;

class FlxQuadVector
{
    var array:Array<Float>;

    public function new() {
        array = new Array<Float>();
        index = 0;
        length = 0;
    }

    public inline function toArray():Array<Float> {
        return this.array;
    }

    public inline function dispose():Void {
        array = null;
        index = 0;
        length = 0;
    }

    var index(default, null):Int;
    var length(default, null):Int;

    public inline function push(a:Float):Void {
        pushData(a, a, a, a);
    }

    public inline function pushData(a:Float, b:Float, c:Float, d:Float):Void
    {
        if ((length - index) > 3)
        {
            #if cpp
            untyped __cpp__('{0}->__SetItem({1}, {2})', array, index, a);
            untyped __cpp__('{0}->__SetItem({1}, {2})', array, index + 1, b);
            untyped __cpp__('{0}->__SetItem({1}, {2})', array, index + 2, c);
            untyped __cpp__('{0}->__SetItem({1}, {2})', array, index + 3, d);
            #else
            array[index] = a;
            array[index + 1] = b;
            array[index + 2] = c;
            array[index + 3] = d;
            #end
        }
        else
        {
            array.push(a);
            array.push(b);
            array.push(c);
            array.push(d);
            
            length = (length + 4);
        }

        index = (index + 4);
    }

    public inline function reset():Void {
        /*if (index != length) {
            array.splice(index, length);
            this.length = index;
        }*/
        index = 0;
    }
}