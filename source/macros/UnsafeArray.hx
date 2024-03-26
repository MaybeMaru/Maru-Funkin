package macros;

class UnsafeArray<T>
{
    inline public static function unsafeGet<T>(array:Array<T>, index:Int):T {
        #if cpp
        return cpp.NativeArray.unsafeGet(array, index);
        #else
        return array[index];
        #end
    }

    inline public static function unsafeSet<T>(array:Array<T>, index:Int, value:T):Void {
        #if cpp
        untyped array.__unsafe_set(index, value);
        #else
        array[index] = value;
        #end
    }
}