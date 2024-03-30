package funkin.objects.note;

typedef EventData = {
    var description:String;
    var values:Array<Dynamic>;
    var image:String;
}

class EventUtil {
    public static var eventsMap:Map<String, EventData> = [];
	public static var eventsArray:Array<String> = [];

    static function getList() {
        final eventSort = CoolUtil.getFileContent(Paths.txt("events/events-sort", null)).split(",");
        final eventList = JsonUtil.getSubFolderJsonList('events', [PlayState?.SONG?.song ?? ""]);
        return CoolUtil.customSort(eventList, eventSort);
    }

    public static function initEvents():Void {
		eventsMap = new Map<String, EventData>();
		eventsArray = [];
		for (e in getList()) {
			eventsArray.push(e);
            getEventData(e);
        }
	}

    public static var DEFAULT_EVENT(default, never):EventData = {
		description: "This event has no description",
        values: [],
        image: "blankEvent"
	}

    public static function getEventData(event:String):EventData {
        if (eventsMap.exists(event)) return eventsMap.get(event);
		var eventJson:EventData = JsonUtil.getJson(event, 'events');
		eventJson = JsonUtil.checkJsonDefaults(DEFAULT_EVENT, eventJson);
        if (eventJson.values.length > 24) eventJson.values = eventJson.values.slice(0, 24); // 24 values cap
		eventsMap.set(event, eventJson);
		return eventJson;
    }
}

class Event {
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