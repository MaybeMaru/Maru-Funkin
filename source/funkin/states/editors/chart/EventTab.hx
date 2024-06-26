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

        for (i in 0...values.length) {
            if (i > 23) {
                break;
            }

            makeUIElement(values[i], i);
        }

        sort(FlxSort.byY, FlxSort.DESCENDING);

        scrollFactor.set();
    }

    function makeUIElement(value:Dynamic, ID:Int)
    {
        var X = (ID < 12 ? 0 : 1) * 125;
        var Y = (ID < 12 ? ID : ID - 12) * 30;

        switch (Type.typeof(value))
        {
            case TInt | TFloat:
                var stepper = new QuickStepper(X, Y, value);
                stepper.callback = () -> updateFunc(ID, stepper.value);
                getValuesArray.push(() -> return stepper.value);
                addUI(stepper);

            case TBool:
                var checkbox = new FlxUICheckBox(X, Y, null, null, " ");
                checkbox.checked = value;
                checkbox.callback = () -> updateFunc(ID, checkbox.checked);
                getValuesArray.push(() -> return checkbox.checked);
                addUI(checkbox);

            case TClass(Array):
                var dropdown = new FlxUIDropDownMenu(X, Y, FlxUIDropDownMenu.makeStrIdLabelArray(value, true),
                (v:String) -> {
                    var item = value.copy()[Std.parseInt(v)];
                    updateFunc(ID, item);
                });
                dropdown.selectedLabel = value[0];
                getValuesArray.push(() -> return dropdown.selectedLabel);
                addUI(dropdown);

            case TClass(String):
                var value = Std.string(value);

                // Folder list
                if (value.startsWith("<list>")) {
                    var split = value.substring(6, value.length).split(":");
                    var folder = split[0];
                    var extension = split[1];

                    var list = Paths.quickFileList(folder, extension, false);
                    makeUIElement(list, ID);
                    return;
                }
            
                // Not a list so we make a input text
                var input = new FlxUIInputText(X, Y, 100, value, 8);
                ChartTabs.instance.focusList.push(input);
                input.callback = (var1, var2) -> updateFunc(ID, input.text);
                getValuesArray.push(() -> return input.text);
                addUI(input);
            
            default:
        }
    }

    public function setValues(values:Array<Dynamic>) {
        for (i in 0...values.length) {
            final obj = curUIelements[i];
            switch(Type.typeof(obj)) {
                case TClass(FlxUIDropDownMenu): cast(obj, FlxUIDropDownMenu).selectedLabel = Std.string(values[i]);
                case TClass(FlxUIInputText):    cast(obj, FlxUIInputText).text = Std.string(values[i]);
                case TClass(FlxUICheckBox):     cast(obj, FlxUICheckBox).checked = cast(values[i], Bool);
                case TClass(QuickStepper):      cast(obj, QuickStepper).value = cast(values[i], Float);
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