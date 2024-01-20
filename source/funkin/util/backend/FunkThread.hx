package funkin.util.backend;

#if sys
import sys.thread.FixedThreadPool;
import sys.thread.Thread;
#end

/*
    Still figuring this shit out lol
    TODO reuse threads instead of creating and killing threads all the time
*/

class FunkThread { 
    #if sys
    static var threadPool:FixedThreadPool = new FixedThreadPool(4);
    
    public static function run(task:Void->Void) {
        threadPool.run(task);
    }
    
    #else

    public static function run(task:Void->Void) {
        task();
    }

    #end
    
    /*static var threadPool:ThreadPool;

    @:noCompletion
    private static function __initPool() {
        threadPool = new ThreadPool();
    }

    public static function runThread(func:Void->Void) {
        if (threadPool == null) __initPool();

        threadPool.queue(function () {
            func();
        });

        //threadPool.doWork();
    }*/
    
    /*static var threadsMap:Map<Int, Thread> = [];

    public static inline function get(id:Int = 0):Null<Thread> {
        return threadsMap.get(id);
    }

    public static inline function exists(id:Int = 0):Bool {
        return threadsMap.exists(id);
    }
    
    public static function runThread(func:Dynamic, id:Int = 0) {
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
    }*/
}