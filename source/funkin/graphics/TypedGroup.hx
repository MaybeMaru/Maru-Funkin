package funkin.graphics;

import flixel.FlxBasic;

// Just flixel groups with unsafe gets for performance

typedef Group = TypedGroup<FlxBasic>;

class TypedGroup<T:FlxBasic> extends FlxTypedGroup<T>
{
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
typedef SpriteGroup = TypedSpriteGroup<FlxSprite>;
typedef DynamicSpriteGroup = TypedSpriteGroup<Dynamic>;

class TypedSpriteGroup<T:FlxSprite> extends FlxObject {
	public var group:TypedGroup<T>; // Group containing everything
	override inline function get_camera():FlxCamera return group.camera;
    override inline function set_camera(Value:FlxCamera):FlxCamera return group.camera = Value;
	override inline function get_cameras():Array<FlxCamera> return group.cameras;
	override inline function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera> return group.cameras = Value;

	public var members(get, never):Array<T>;
	inline function get_members():Array<T> return group.members;
	inline function add(basic:T):T return group.add(basic);

	public var offset(default, null):FlxPoint;
	public var origin(default, null):FlxPoint;
	var _cos(default, null):Float = 1.0;
	var _sin(default, null):Float = 0.0;

	override function set_angle(value:Float):Float {
		if (angle != value) {
			var rads:Float = value * CoolUtil.TO_RADS;
			_cos = CoolUtil.cos(rads);
			_sin = CoolUtil.sin(rads);
		}
		return angle = value;
	}

	public var alpha:Float = 1.0;
	public var color(default, set):FlxColor = FlxColor.WHITE;

	function set_color(value:FlxColor):FlxColor {
		if (value != color) {
			for (basic in members)
				basic.color = value;
		}
		return color = value;
	}

	override function get_width():Float {
		var w:Float = 0.0;
		for (member in members) {
			if (member == null || !member.alive) continue;
			
			var value = member.x + member.width;
			if (value > w) w = value;
		}
		return w;
	}

	override function get_height():Float {
		var h:Float = 0.0;
		for (member in members) {
			if (member == null || !member.alive) continue;
			
			var value = member.y + member.height;
			if (value > h) h = value;
		}
		return h;
	}

	public function new (X:Float = 0, Y:Float = 0, ?maxSize:Int) {
		super();
		group = new TypedGroup<T>(maxSize);
		offset = FlxPoint.get();
		origin = FlxPoint.get();
	}

	override function destroy() {
		super.destroy();
		offset = FlxDestroyUtil.put(offset);
		origin = FlxDestroyUtil.put(origin);
	}

	override function draw() {
		@:privateAccess {
			final oldDefaultCameras = FlxCamera._defaultCameras;
			if (group.cameras != null) FlxCamera._defaultCameras = group.cameras;

			var point = CoolUtil.point;
			point.set(x, y);
			point.subtract(offset.x, offset.y);
	
			for (basic in members) {
				var basicX = basic.x; var basicY = basic.y; var basicAngle = basic.angle; var basicAlpha = basic.alpha;
				CoolUtil.positionWithTrig(basic, basic.x - origin.x, basic.y - origin.y, _cos, _sin);
				
				basic.x += point.x;
				basic.y += point.y;
				basic.angle += angle;
				basic.alpha *= alpha;

				if (basic != null && basic.exists && basic.visible) {
					basic.draw();
				}

				basic.x = basicX;
				basic.y = basicY;
				basic.angle = basicAngle;
				basic.alpha = basicAlpha;
			}
	
			FlxCamera._defaultCameras = oldDefaultCameras;
		}
	}
}

/*
class BaseTypedSpriteGroup<T:FlxSprite> extends TypedGroup<T>
{
	public var x(default, set):Float = 0.0;
	public var y(default, set):Float = 0.0;
	public var offset(default, null):FlxPoint;
	public var scrollFactor(default, null):FlxPoint;

	public inline function setPosition(X:Float = 0, Y:Float = 0) {
		x = X;
		y = Y;
	}

	public inline function screenCenter(axes:FlxAxes = XY) {
		if (axes.x) x = (FlxG.width - width) * .5;
		if (axes.y) y = (FlxG.height - height) * .5;
		return this;
	}

	public var alpha:Float = 1.0;
	public var color(default, set):FlxColor = FlxColor.WHITE;

	function set_color(value:FlxColor):FlxColor {
		if (value != color) {
			for (basic in members)
				basic.color = value;
		}
		return color = value;
	}

	public var angle(default, set):Float = 0.0;
	public var origin(default, null):FlxPoint;
	var _cos(default, null):Float = 1.0;
	var _sin(default, null):Float = 0.0;

	function set_angle(value:Float):Float {
		if (angle != value) {
			var rads:Float = value * CoolUtil.TO_RADS;
			_cos = CoolUtil.cos(rads);
			_sin = CoolUtil.sin(rads);
		}
		return angle = value;
	}

	public var width(get, set):Float;
	public var height(get, set):Float;
	
	function get_width():Float {
		var w:Float = 0.0;
		for (member in members) {
			if (member == null || !member.alive) continue;
			
			var value = member.x + member.width;
			if (value > w) w = value;
		}
		return w;
	}

	function get_height():Float {
		var h:Float = 0.0;
		for (member in members) {
			if (member == null || !member.alive) continue;
			
			var value = member.y + member.height;
			if (value > h) h = value;
		}
		return h;
	}

	public function new(X:Float = 0.0, Y:Float = 0.0, ?maxSize:Int):Void {
		super(maxSize);
		setPosition(X, Y);
		offset = FlxPoint.get();
		origin = FlxPoint.get();
		scrollFactor = new FlxCallbackPoint(function (point:FlxPoint) {
			for (basic in members) {
				basic.scrollFactor.set(point.x, point.y);
			}
		});

		scrollFactor.set(1, 1);
	}

	override function destroy() {
		super.destroy();
		offset = FlxDestroyUtil.put(offset);
		origin = FlxDestroyUtil.put(origin);
		scrollFactor = FlxDestroyUtil.destroy(scrollFactor);
	}

	override function draw():Void {
		@:privateAccess {
			final oldDefaultCameras = FlxCamera._defaultCameras;
			if (cameras != null) FlxCamera._defaultCameras = cameras;

			var point = CoolUtil.point;
			point.set(x, y);
			point.subtract(offset.x, offset.y);
	
			for (basic in members) {
				var basicX = basic.x; var basicY = basic.y; var basicAngle = basic.angle; var basicAlpha = basic.alpha;
				CoolUtil.positionWithTrig(basic, basic.x - origin.x, basic.y - origin.y, _cos, _sin);
				
				basic.x += point.x;
				basic.y += point.y;
				basic.angle += angle;
				basic.alpha *= alpha;

				if (basic != null && basic.exists && basic.visible) {
					basic.draw();
				}

				basic.x = basicX;
				basic.y = basicY;
				basic.angle = basicAngle;
				basic.alpha = basicAlpha;
			}
	
			FlxCamera._defaultCameras = oldDefaultCameras;
		}
	}
}*/