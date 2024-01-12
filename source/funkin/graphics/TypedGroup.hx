package funkin.graphics;

import flixel.FlxBasic;

// Just flixel groups with unsafe gets for performance

typedef Group = TypedGroup<FlxBasic>;

class TypedGroup<T:FlxBasic> extends FlxTypedGroup<T>  {
    @:noCompletion
	override inline function get_camera():FlxCamera {
        @:privateAccess
		return (_cameras == null || _cameras.length == 0) ? FlxCamera._defaultCameras[0] : _cameras[0];
	}

	@:noCompletion
    override inline function set_camera(Value:FlxCamera):FlxCamera {
		if (_cameras == null) _cameras = [Value];
		else _cameras[0] = Value;
		return Value;
	}

    @:noCompletion
	override inline function get_cameras():Array<FlxCamera> {
        @:privateAccess
		return (_cameras == null) ? FlxCamera._defaultCameras : _cameras;
	}

	@:noCompletion
	override inline function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera> {
		return _cameras = Value;
	}

    override inline function getFirstNull():Int {
        return members.indexOf(null);
    }
}