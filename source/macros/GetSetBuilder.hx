package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class GetSetBuilder
{
    public static macro function build(buildFields:Array<String>, fieldName:String):Array<Field>
    {
        var classFields:Array<Field> = Context.getBuildFields();
        //var field:Field = findField(classFields, fieldName);

        for (f in buildFields) {
            classFields.push(makeField(f, "get", "set"));
            classFields.push(makeGetter('get_$f', fieldName, f));
            classFields.push(makeSetter('set_$f', fieldName, f));
        }

        return classFields;
    }

    public static macro function buildGet(getFields:Array<String>, fieldName:String):Array<Field>
    {
        var classFields:Array<Field> = Context.getBuildFields();
        //var field:Field = findField(classFields, fieldName);

        for (f in getFields) {
            classFields.push(makeField(f, "get", "never"));
            classFields.push(makeGetter('get_$f', fieldName, f));
        }

        return classFields;
    }

    /*
    static function findField(fields:Array<Field>, name:String):Field {
        for (field in fields) {
            if (field.name == name)
                return field;
        }
        return null;
    }
    */

    static function makeField(fieldName:String, get:String, set:String):Field
    {   
        return {
            name: fieldName,
            access: [APublic],
            kind: FProp(get, set, macro :Dynamic),
            pos: Context.currentPos()
        }
    }

    static function makeGetter(getterName:String, field:String, fieldName:String):Field
    {
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

    static function makeSetter(setterName:String, field:String, fieldName:String):Field
    {
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