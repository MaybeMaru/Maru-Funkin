package funkin.states.editors.chart;

import flixel.util.FlxArrayUtil;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIDropDownMenu;

class EventTab extends SpriteGroup
{
    public function new(?X:Float, ?Y:Float, ?values:Array<Dynamic>) {
        super(X,Y);
        if (values != null)
            createUI(values);
    }

    public var curValues:Array<Dynamic> = [];
    public var getValuesArray:Array<()->Dynamic> = [];

    public var curUIelements:Array<FlxSprite> = [];
    public var updateFunc:(Int, Dynamic)->Void;

    function addUI(object:FlxSprite) {
        curUIelements.push(object);
        add(object);
    }

    public function createUI(values:Array<Dynamic>) {
        clearGroup();
        curValues = values.copy();

        var i:Int = 1;
        for (v in values) {
            final id:Int = i-1;
            final X = (i <= 12 ? 0 : 1) * 125;
            final Y = (i <= 12 ? id : id-12) * 30;
            switch (Type.typeof(v)) {
                case TInt | TFloat:
                    final stepper = new QuickStepper(X, Y,v);
                    stepper.callback = () -> updateFunc(id, stepper.value);
                    getValuesArray.push(() -> return stepper.value);
                    addUI(stepper);

                case TBool:
                    final checkbox = new FlxUICheckBox(X, Y, null, null, " ");
                    checkbox.checked = v;
                    checkbox.callback = () -> updateFunc(id, checkbox.checked);
                    getValuesArray.push(() -> return checkbox.checked);
                    addUI(checkbox);

                case TClass(Array):
                    final dropdown = new FlxUIDropDownMenu(X, Y, FlxUIDropDownMenu.makeStrIdLabelArray(v, true), function(_value:String) {
                        final value = v.copy()[Std.parseInt(_value)];
                        updateFunc(id, value);
                    });
                    dropdown.selectedLabel = v[0];
                    getValuesArray.push(() -> return dropdown.selectedLabel);
                    addUI(dropdown);

                default: //TClass(String)
                    final input = new FlxUIInputText(X, Y, 100, Std.string(v), 8);
                    ChartTabs.instance.focusList.push(input);
                    input.callback = (var1, var2) -> updateFunc(id, input.text);
                    getValuesArray.push(() -> return input.text);
                    addUI(input);
            }
            //add(new FlxText(_X,_Y - 15, 0, 'Value $i:'));
            sort(FlxSort.byY, FlxSort.DESCENDING);
            i++;
            if (i > 24) break; // Why would you need more you psycho?
        }

        scrollFactor.set();
    }

    public function setValues(values:Array<Dynamic>) {
        for (i in 0...values.length) {
            final obj = curUIelements[i];
            switch(Type.typeof(obj)) {
                case TClass(FlxUIDropDownMenu): cast(obj, FlxUIDropDownMenu).selectedLabel = Std.string(values[i]);
                case TClass(FlxUIInputText): cast(obj, FlxUIInputText).text = Std.string(values[i]);
                case TClass(FlxUICheckBox): cast(obj, FlxUICheckBox).checked = cast(values[i], Bool);
                case TClass(QuickStepper): cast(obj, QuickStepper).value = cast(values[i], Float);
                default:
            }
        }
    }

    public function getValues():Array<Dynamic> {
        final array:Array<Dynamic> = [];
        getValuesArray.fastForEach((func, i) -> array.push(func()));
        return array;
    }

    public function clearGroup() {
        curUIelements.clear();
        getValuesArray.clear();

        var focus = ChartTabs.instance.focusList;
        members.fastForEach((member, i) -> {
            if (member is FlxUIInputText) {
                if (focus.indexOf(cast member) != -1) {
                    focus.remove(cast member);
                }
            }            
            member.destroy();
        });

        members.clear();
        clear();
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