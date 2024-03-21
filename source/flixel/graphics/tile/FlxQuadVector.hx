package flixel.graphics.tile;

import openfl.Vector;
#if cpp
import cpp.NativeArray.unsafeSet;
#end

class FlxRectVector extends FlxQuadVector
{
    var vector:Vector<Float>;

    public function new() {
        super();

        vector = new Vector<Float>();
        #if cpp
        untyped __cpp__('{0}->_hx___array = {1}', vector, this.array);
        #else
        @:privateAccess {
            final floatVector = vector.toFloatVector(0, false, null);
            floatVector.__array = this.array;
            vector = floatVector;
        }
        #end
    }

    override public function dispose():Void {
        vector = null;
        super.dispose();
    }

    public inline function toVector():Vector<Float> {
        return vector;
    }
}

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

    public function dispose():Void {
        array = null;
        index = 0;
        length = 0;
    }

    var index(default, null):Int;
    public var length(default, null):Int;

    public inline function push(a:Float):Void {
        pushData(a, a, a, a);
    }

    public inline function pushData(a:Float, b:Float, c:Float, d:Float):Void
    {
        if ((length - index) > 3)
        {
            #if cpp
            unsafeSet(array, index, a);
            unsafeSet(array, index + 1, b);
            unsafeSet(array, index + 2, c);
            unsafeSet(array, index + 3, d);
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
        if (index != 0)
        {
            if (length > index) {
                array.splice(index, length);
                length = index + 1;
            }

            index = 0;
        }
    }
}