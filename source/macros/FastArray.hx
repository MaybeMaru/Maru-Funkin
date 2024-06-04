package macros;

import haxe.macro.Expr;

macro function fastForEach(iterableExpr: Expr, callbackExpr: Expr) {
  // Extract variable names and expression from `callbackExpr`
  var loopExpr = null;
  var objectName = "";
  var indexName = "";

  // Check that `callbackExpr` is a two argument function
  switch(callbackExpr.expr) {
    case EFunction(kind, { args: args, expr: expr }) if(expr != null && args.length == 2): {
      loopExpr = if(kind == FArrow) {
        // Make sure automatic "return" is removed from lambda
        haxe.macro.ExprTools.map(expr, e -> switch(e.expr) {
          case EReturn(returnedExpr): returnedExpr;
          case _: e;
        });
      } else {
        expr;
      }
      objectName = args[0].name;
      indexName = args[1].name;
    }
    case _: throw "`callbackExpr` must be a function with two arguments!";
  }

  return macro {
    final iterable = $iterableExpr;
    final len = iterable.length;
    var $indexName = 0;
    while($i{indexName} < len) {
      final $objectName = iterable.unsafeGet($i{indexName});
      $loopExpr;
      $i{indexName}++;
    }
  }
}

@:unreflective
class FastArray<T>
{
    // Keeping this if i find a better method later down the line
    inline public static function unsafeGet<T>(array:Array<T>, index:Int):T {
        #if cpp
        return untyped array.__unsafe_get(index);
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

    inline public static function clear<T>(array:Array<T>) {
        #if web
        array.splice(0, array.length); // Splice is faster on html5 for whatever reason
        #else
        array.resize(0);
        #end
    }

    inline public static function removeAt<T>(array:Array<T>, index:Int) {
      #if cpp
      cpp.NativeArray.removeAt(array, index);
      #else
      array.splice(index, 1);
      #end
    }
}