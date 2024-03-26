package macros;

import haxe.macro.Expr;
//import haxe.macro.Context;

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

  // Make sure the array doesnt compile into dynamic
  //final type = Context.toComplexType(Context.typeof(iterableExpr));

  // Build the expression this macro call changes into:
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