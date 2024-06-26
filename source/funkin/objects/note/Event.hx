package funkin.objects.note;

import funkin.objects.note.BasicNote.ITimingObject;

typedef EventData = {
    var description:String;
    var values:Array<Dynamic>;
    var image:String;
}

class EventUtil
{
    public static var eventsMap:Map<String, EventData> = [];
	public static var eventsArray:Array<String> = [];

    static function getList():Array<String>
    {
        var song = PlayState.SONG?.song ?? "";
        song = Song.formatSongFolder(song);
        return JsonUtil.getSubFolderJsonList('events', [song]);
    }

    public static function initEvents():Void
    {
        eventsMap.clear();
        eventsArray.clear();
		getList().fastForEach((e, i) -> {
			eventsArray.push(e);
            getEventData(e);
        });
	}

    inline static public function getDefaultEvent():EventData {
        return {
            description: "This event has no description",
            values: [],
            image: "blankEvent"
        }
    }

    public static function getEventData(event:String):EventData
    {
        if (eventsMap.exists(event))
            return eventsMap.get(event);
		
        var eventJson:EventData = JsonUtil.getJson(event, 'events');
		eventJson = JsonUtil.checkJson(getDefaultEvent(), eventJson);
        if (eventJson.values.length > 24) // 24 values cap
            eventJson.values.resize(24);
		
        eventsMap.set(event, eventJson);
		return eventJson;
    }
}

class Event implements ITimingObject
{
    public var strumTime:Float = 0.0;
    public var name:String = "";
    public var values:Array<Dynamic> = [];
    
    public function new(strumTime:Float = 0, name:String = "", ?values:Array<Dynamic>) {
        set(strumTime, name, values);
    }

    public inline function set(strumTime:Float = 0, name:String = "", ?values:Array<Dynamic>):Event {
        this.strumTime = strumTime;
        this.name = name;
        this.values = values ?? [];
        return this;
    }
}