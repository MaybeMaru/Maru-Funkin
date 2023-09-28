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

    public static inline function getThread(id:Int = 0):Null<Thread> {
        return threadsMap.get(id);
    }
    
    public static function runThread(func:Dynamic, id:Int = 0) {
        //#if sys
        if (threadsMap.exists(id)) {
            final thread = getThread(id);
            //if (thread.events.progress() == Now) thread.events.cancel(); ???
            thread.events.runPromised(() -> {
                func();
            });
            thread.events.promise();
            return thread;
        } else {
            final thread:Thread = Thread.createWithEventLoop(() -> {
                func();
            });
            thread.events.promise();
            threadsMap.set(id, thread);
            return thread;
        }
        /*#else
        func();
        return null;
        #end*/
    }
}