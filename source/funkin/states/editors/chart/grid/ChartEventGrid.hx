package funkin.states.editors.chart.grid;

class ChartEventGrid extends ChartGridBase<ChartEvent>
{
    public function new() {
        super(1);
    }

    override function equalObjectData(event:ChartEvent, data:Array<Dynamic>) {
        if (FunkMath.isZero(event.strumTime - data[0]))
            return event;

        return null;
    }

    override function drawObject(event:Array<Dynamic>):ChartEvent {
        var strumTime:Float = event[0];
        return drawPackedObject(strumTime, [event]);
    }

    public function drawPackedObject(strumTime:Float = 0, events:Array<Array<Dynamic>>):ChartEvent {
        final gridY = grid.y + Math.floor(ChartingState.getTimeY(strumTime - sectionTime));

        final event:ChartEvent = group.recycle(ChartEvent);
        event.init(strumTime, events, CoolUtil.point.set(grid.x, gridY));
        group.add(event);
        
        return event;
    }

    var packedEvents:Map<Int, Array<Array<Dynamic>>> = [];

    public override function drawSectionData(?section:SectionJson, clip:Bool = false, ?pushArray:Array<ChartEvent>) {        
        if (section == null)
            return;

        packedEvents.clear();

        // Pack events with the same strumtime
        section.sectionEvents.fastForEach((event, i) -> {
            var time = Math.floor(event[0]);

            if (!packedEvents.exists(time)) {
                packedEvents.set(time, []);
            }
            
            var array = packedEvents.get(time);
            array.push(event);
        });

        var clipTime:Float = clip ? ChartingState.getSecTime(sectionIndex - 1) + Conductor.sectionCrochet * 0.625 : 0;
        var hasArray:Bool = pushArray != null;

        for (time => events in packedEvents) {
            if (time >= clipTime)
            {
                var event = drawPackedObject(time, events);
                if (hasArray) {
                    pushArray.push(event);
                }
            }
        }
    }
}