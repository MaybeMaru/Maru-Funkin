package hscript;

class UsingHandler {
	public static function init() {}
}

/*package hscript;

import Type.ValueType;
import haxe.macro.ComplexTypeTools;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Printer;
import haxe.macro.Compiler;

using StringTools;

class UsingHandler {
	public var usedClass:Class<Dynamic>;
	public var className:String;

	public function new(className:String, usedClass:Class<Dynamic>) {
		this.className = className;
		this.usedClass = usedClass;
	}

	public static function init() {
		Compiler.addGlobalMetadata('flixel', '@:build(hscript.UsingHandler.build())');
		Compiler.addGlobalMetadata('openfl.display.BlendMode', '@:build(hscript.UsingHandler.build())');
	}

	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var clRef = Context.getLocalClass();
		if (clRef == null) return fields;
		var cl = clRef.get();

		// cl.name.startsWith("Flx") &&
		if (cl.name.endsWith("_Impl_") && cl.params.length <= 0 && !cl.meta.has(":multiType") && !cl.meta.has("_HSC")) {
			var metas = cl.meta.get();

			var shadowClass = macro class {

			};
			shadowClass.kind = TDClass();
			shadowClass.params = switch(cl.params.length) {
				case 0:
					null;
				case 1:
					[
						{
							name: "T",
						}
					];
				default:
					[for(k=>e in cl.params) {
						name: "T" + Std.int(k+1)
					}];
			};
			shadowClass.name = '${cl.name.substr(0, cl.name.length - 6)}_HSC';

			var imports = Context.getLocalImports().copy();
			setupMetas(shadowClass, imports);

			for(f in fields)
				switch(f.kind) {
					case FFun(fun):
						if (f.access.contains(AStatic)) {
							if (fun.expr != null)
								shadowClass.fields.push(f);
						}
					case FProp(get, set, t, e):
						if (get == "default" && (set == "never" || set == "null"))
							shadowClass.fields.push(f);
					case FVar(t, e):
						if (f.access.contains(AStatic) || cl.meta.has(":enum") || f.name.toUpperCase() == f.name) {
							var name:String = f.name;
							var enumType:String = cl.name;
							var pack = cl.module.split(".");
							pack.pop();
							var complexType:ComplexType = t != null ? t : (name.contains("REGEX") ?
							TPath({
								name: "EReg",
								pack: []
							}) : TPath({
								name: cl.name.substr(0, cl.name.length - 6),
								pack: pack}));
							var field:Field = {
								pos: f.pos,
								name: f.name,
								meta: f.meta,
								kind: FVar(complexType, {
									pos: Context.currentPos(),
									expr: ECast(e, complexType)
								}),
								doc: f.doc,
								access: [APublic, AStatic]
							}

							shadowClass.fields.push(field);
						}
					default:
				}

			Context.defineModule(cl.module, [shadowClass], imports);
		}

		return fields;
	}

	static function fixStdTypes(type:ComplexType) {
		switch(type) {
			case TPath({name: "StdTypes"}):
				var a:TypePath = type.getParameters()[0];
				a.name = a.sub;
				a.sub = null;
			default:
		}
		return type;
	}

	public static function setupMetas(shadowClass:TypeDefinition, imports) {
		shadowClass.meta = [{
			name: ':dox',
			pos: Context.currentPos(),
			params: [
				{
					expr: EConst(CIdent("hide")),
					pos: Context.currentPos()
				}
			]
		}];
		var module = Context.getModule(Context.getLocalModule());
		for(t in module) {
			switch(t) {
				case TInst(t, params):
					if (t != null) {
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				case TEnum(t, params):
					if (t != null) {
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				case TType(t, params):
					if (t != null) {
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				case TAbstract(t, params):
					if (t != null) {
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				default:
					// not needed?
			}
		}
	}

	public static function processModule(shadowClass:TypeDefinition, module:String, n:String) {
		if (n.endsWith("_Impl_"))
			n = n.substr(0, n.length - 6);
		if (module.endsWith("_Impl_"))
			module = module.substr(0, module.length - 6);

		shadowClass.meta.push(
			{
				name: ':access',
				params: [
					Context.parse(fixModuleName(module.endsWith('.${n}') ? module : '${module}.${n}'), Context.currentPos())
				],
				pos: Context.currentPos()
			}
		);
	}


	//public static function getModuleName(path:Type) {
	//	switch(path) {
	//		case TPath(name, pack):// | TDClass(name, pack):
	//			var str = "";
	//			for(p in pack) {
	//				str += p + ".";
	//			}
	//			str += name;
	//			return str;
	//
	//		default:
	//	}
	//	return "INVALID";
	//}

	public static function fixModuleName(name:String) {
		return [for(s in name.split(".")) if (s.charAt(0) == "_") s.substr(1) else s].join(".");
	}
	public static function processImport(imports:Array<ImportExpr>, module:String, n:String) {
		if (n.endsWith("_Impl_"))
			n = n.substr(0, n.length - 6);
		module = fixModuleName(module);
		if (module.endsWith("_Impl_"))
			module = module.substr(0, module.length - 6);

		imports.push({
			path: [for(m in module.split(".")) {
				name: m,
				pos: Context.currentPos()
			}],
			mode: INormal
		});
	}

	public static function cleanExpr(expr:Expr, oldFunc:String, newFunc:String) {
		if (expr == null) return;
		if (expr.expr == null) return;
		switch(expr.expr) {
			case EConst(c):
				switch(c) {
					case CIdent(s):
						if (s == oldFunc)
							expr.expr = EConst(CIdent(newFunc));
					case CString(s, b):
						if (s == oldFunc)
							expr.expr = EConst(CString(s, b));
					default:
						// nothing
				}
			case EField(e, field):
				if (field == oldFunc && e != null) {
					switch(e.expr) {
						case EConst(c):
							switch(c) {
								case CIdent(s):
									if (s == "super")
										expr.expr = EField(e, newFunc);
								default:

							}
						default:

					}
				}
			case EParenthesis(e):
				cleanExpr(e, oldFunc, newFunc);
			case EObjectDecl(fields):
				for(f in fields) {
					cleanExpr(f.expr, oldFunc, newFunc);
				}
			case EArrayDecl(values):
				for(a in values) {
					cleanExpr(a, oldFunc, newFunc);
				}
			case ECall(e, params):
				cleanExpr(e, oldFunc, newFunc);
			case EBlock(exprs):
				for(e in exprs)
					cleanExpr(e, oldFunc, newFunc);
			case EFor(it, expr):
				cleanExpr(it, oldFunc, newFunc);
				cleanExpr(expr, oldFunc, newFunc);
			case EIf(econd, eif, eelse):
				cleanExpr(econd, oldFunc, newFunc);
				cleanExpr(eif, oldFunc, newFunc);
				cleanExpr(eelse, oldFunc, newFunc);
			case EWhile(econd, e, normalWhile):
				cleanExpr(econd, oldFunc, newFunc);
				cleanExpr(e, oldFunc, newFunc);
			case ECast(e, t):
				cleanExpr(e, oldFunc, newFunc);
			case ECheckType(e, t):
				cleanExpr(e, oldFunc, newFunc);
			case ETry(e, catches):
				cleanExpr(e, oldFunc, newFunc);
				for(c in catches) {
					cleanExpr(c.expr, oldFunc, newFunc);
				}
			case EThrow(e):
				cleanExpr(e, oldFunc, newFunc);
			case ETernary(econd, eif, eelse):
				cleanExpr(econd, oldFunc, newFunc);
				cleanExpr(eif, oldFunc, newFunc);
				cleanExpr(eelse, oldFunc, newFunc);
			case ESwitch(e, cases, edef):
				cleanExpr(e, oldFunc, newFunc);
				for(c in cases) {
					cleanExpr(c.expr, oldFunc, newFunc);
				}
				cleanExpr(edef, oldFunc, newFunc);
			case EReturn(e):
				cleanExpr(e, oldFunc, newFunc);
			case EIs(e, t):
				cleanExpr(e, oldFunc, newFunc);
			case EVars(vars):
				for(v in vars) {
					cleanExpr(v.expr, oldFunc, newFunc);
				}
			case ENew(t, params):
				for(p in params) {
					cleanExpr(p, oldFunc, newFunc);
				}
			default:
		}
	}
}
#else
class UsingHandler {
	public var usedClass:Class<Dynamic>;
	public var className:String;
}
#end*/