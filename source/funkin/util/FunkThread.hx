package funkin.util;

//#if sys
import sys.thread.Thread;
//#end

/*
    Still figuring this shit out lol
    TODO reuse threads instead of creating and killing threads all the time
*/

class FunkThread {
    static var threadsMap:Map<Int, Thread> = [];

    public static inline function get(id:Int = 0):Null<Thread> {
        return threadsMap.get(id);
    }

    public static inline function exists(id:Int = 0):Bool {
        return threadsMap.exists(id);
    }
    
    public static function runThread(func:Dynamic, id:Int = 0) {
        //#if sys
        var thread:Null<Thread> = null;
        if (exists(id)) {
            thread = get(id);
            thread.events.runPromised(() -> {
                func();
            });
            thread.events.promise();
        } else {
            thread = Thread.createWithEventLoop(() -> {
                func();
            });
            thread.events.promise();
            threadsMap.set(id, thread);
        }
        return thread;
        /*#else
        func();
        return null;
        #end*/
    }
}