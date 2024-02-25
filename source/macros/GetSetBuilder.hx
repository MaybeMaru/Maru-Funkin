package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class GetSetBuilder
{
    public static macro function build(fields:Array<String>, field:String):Array<Field> {
        var classFields:Array<Field> = Context.getBuildFields();

        for (fieldName in fields) {
            classFields.push(makeField(fieldName, "get", "set"));
            classFields.push(makeGetter('get_$fieldName', field, fieldName));
            classFields.push(makeSetter('set_$fieldName', field, fieldName));
        }

        return classFields;
    }

    public static macro function buildGet(fields:Array<String>, field:String):Array<Field> {
        var classFields:Array<Field> = Context.getBuildFields();

        for (fieldName in fields) {
            classFields.push(makeField(fieldName, "get", "never"));
            classFields.push(makeGetter('get_$fieldName', field, fieldName));
        }

        return classFields;
    }

    static function makeField(fieldName:String, get:String, set:String):Field {
        return {
            name: fieldName,
            access: [APublic],
            kind: FProp(get, set, macro :Dynamic),
            pos: Context.currentPos()
        }
    }

    static function makeGetter(getterName:String, field:String, fieldName:String):Field {
        return {
            name: getterName,
            access: [APublic, AInline],
            kind: FFun({
                args: [],
                expr: macro {
                    return this.$field.$fieldName;
                }
            }),
            pos: Context.currentPos()
        }
    }

    static function makeSetter(setterName:String, field:String, fieldName:String):Field {
        return {
            name: setterName,
            access: [APublic, AInline],
            kind: FFun({
                args: [{name: "value"}],
                expr: macro {
                    return this.$field.$fieldName = value;
                }
            }),
            pos: Context.currentPos()
        }
    }
}