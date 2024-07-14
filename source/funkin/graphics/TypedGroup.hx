package funkin.graphics;

import flixel.FlxBasic;
#if (flixel >= "5.7.0")
import flixel.group.FlxContainer.FlxTypedContainer;
#end

// Just flixel groups with unsafe gets for performance

typedef Group = TypedGroup<FlxBasic>;

@:access(flixel.FlxCamera)
class TypedGroup<T:FlxBasic> extends #if (flixel >= "5.7.0") FlxTypedContainer<T>  #else FlxTypedGroup<T> #end
{
	public inline function setNull(object:T):Void
	{
		var index:Int = members.indexOf(object);
		if (index != -1)
			members.unsafeSet(index, null);
	}

	public function insertTop(object:T):Void
	{
		var index:Int = members.length;
		while (index > 0) {
			index--;
			if (members[index] == null) {
				members.unsafeSet(index, object);
				return;
			}
		}

		members.push(object);
	}

	public function insertBelow(object:T):Void
	{
		var index:Int = 0;
		final l:Int = members.length;
		while (index < l) {
			if (members[index] == null) {
				members.unsafeSet(index, object);
				return;
			}
			index++;
		}

		members.unshift(object);
	}

	override function forEachAlive(func:T -> Void, recurse:Bool = false):Void
	{
		members.fastForEach((basic, i) -> {
			if (basic != null) if (basic.exists) if (basic.alive)
				func(basic);
		});
	}

	override public function draw():Void
	{
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null)
			FlxCamera._defaultCameras = _cameras;

		members.fastForEach((basic, i) -> {
			if (basic != null) if (basic.exists) if (basic.visible)
				basic.draw();
		});

		FlxCamera._defaultCameras = oldDefaultCameras;
	}

	override public function update(elapsed:Float):Void
	{
		members.fastForEach((basic, i) -> {
			if (basic != null) if (basic.exists) if (basic.active)
				basic.update(elapsed);
		});
	}
}

typedef SpriteGroup = TypedSpriteGroup<FlxSprite>;

class TypedSpriteGroup<T:FlxSprite> extends FlxTypedSpriteGroup<T>
{
	#if (flixel < "5.7.0")
	public function new(x:Float = 0, y:Float = 0, maxSize:Int = 0) {
		super(x, y, maxSize);
		group.destroy();
		group = new TypedGroup<T>(maxSize);
		_sprites = cast group.members;
	}
	#else
	override function initGroup(maxSize:Int):Void
	{
		@:bypassAccessor
		group = new TypedGroup<T>(maxSize);
	}
	#end
}