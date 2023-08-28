package funkin.states.editors.chart;

import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;

class EventTab extends FlxTypedSpriteGroup<Dynamic> {
    public function new(?X:Float, ?Y:Float, ?values:Array<Dynamic>) {
        super(X,Y);
        if (values != null)
            setValues(values);
    }

    public var curValues:Array<Dynamic> = [];
    public var getValuesArray:Array<Dynamic> = [];

    public var updateFunc:Dynamic = null;

    public function setValues(values:Array<Dynamic>) {
        clearGroup();
        curValues = values.copy();

        var i:Int = 1;
        for (v in values) {
            var id:Int = i-1;
            var _X = (i <= 12 ? 0 : 1)*125;
            var _Y = (i <= 12 ? id : id-12)*30;
            var type = Type.typeof(v);
            switch (type) {
                case TInt | TFloat:
                    var stepper = new QuickStepper(_X,_Y,v);
                    stepper.callback = function()
                        if (updateFunc != null) updateFunc(id, stepper.value);
                    getValuesArray.push(function () return stepper.value);
                    add(stepper);

                case TBool:
                    var checkbox = new FlxUICheckBox(_X, _Y, null, null, " ");
                    checkbox.checked = v;
                    checkbox.callback = function()
                        if (updateFunc != null) updateFunc(id, checkbox.checked);
                    getValuesArray.push(function () return checkbox.checked);
                    add(checkbox);

                default: //TClass(String)
                    var input = new FlxUIInputText(_X, _Y, 100, Std.string(v), 8);
                    ChartingState.instance.tabs.focusList.push(input);
                    input.callback = function(var1, var2)
                        if (updateFunc != null) updateFunc(id, input.text);
                    getValuesArray.push(function () return input.text);
                    add(input);
            }
            //add(new FlxText(_X,_Y - 15, 0, 'Value $i:'));
            i++;
            if (i > 24) break; // Why would you need more you psycho?
        }

        scrollFactor.set();
    }

    public function getValues():Array<Dynamic> {
        var array:Array<Dynamic> = [];
        for (i in getValuesArray)
            array.push(i());
        return array;
    }

    public function clearGroup() {
        var focusList = ChartingState.instance.tabs.focusList;
        for (i in this) {
            if (focusList.contains(i)) focusList.remove(i);
            remove(i);
            i.destroy();
        }
    }
}

class QuickStepper extends FlxUINumericStepper {
    public function new(X:Float,Y:Float,_value:Float) {
        super(X,Y,1,_value);
    }

    public var callback:Dynamic = null;

    override function _doCallback(event_name:String) {
        super._doCallback(event_name);
        if (event_name == FlxUINumericStepper.CHANGE_EVENT) {
            if (callback != null) callback();
        }
    }
}