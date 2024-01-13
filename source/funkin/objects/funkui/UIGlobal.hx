package funkin.objects.funkui;

class UIGlobal {
    public static var lastObject(default, set):IUIObject = null;

    @:noCompletion
    private static function set_lastObject(value:IUIObject):IUIObject {
        if (value != lastObject) {
            if (lastObject is DropDown) {
                cast(lastObject, DropDown).closeDropDown();
            }
        }
        return lastObject = value;
    }
}