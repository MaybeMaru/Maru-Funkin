package funkin.objects;

#if hxvlc
import hxvlc.flixel.FlxVideo;
#elseif web
import openfl.net.NetStream;
import openfl.net.NetConnection;
import openfl.media.Video;
#end

class FunkVideo implements IFlxDestroyable
{
    public var onComplete:()->Void;

    #if hxvlc
    var video:FlxVideo;
    #elseif web
    var video:Video;
    var netStream:NetStream;
    #end

    public function new() {
        #if hxvlc
        video = new FlxVideo(FlxSprite.defaultAntialiasing);
        video.onEndReached.add(endVideo);
        #elseif web
        video = new Video();
		video.x = video.y = 0;
		FlxG.addChildBelowMouse(video);

		var netConnection:NetConnection = new NetConnection();
		netConnection.connect(null);
		netStream = new NetStream(netConnection);
		netStream.client = {onMetaData: (e) -> {
            video.attachNetStream(netStream);
		    video.width = FlxG.width;
		    video.height = FlxG.height;
        }};
		netConnection.addEventListener('netStatus', (e) -> {
            if (e.info.code == 'NetStream.Play.Complete')
                endVideo();
        });
        #end        
    }

    var _loadedFile:String;

    public function load(path:String) {
        #if hxvlc
        video.load(path);
        #elseif web
        #end

        _loadedFile = path;
    }

    public function play() {
        #if hxvlc
        video.play();
        FlxG.state.visible = false;
        #elseif web
        netStream.play(_loadedFile);
        FlxG.state.visible = false;
        #else
        ModdingUtil.warningPrint("Videos are not allowed on this build.");
        endVideo();
        #end
    }

    public function endVideo() {        
        destroy();

        if (onComplete != null)
            onComplete();
    }

    public function destroy() {
        #if hxvlc
        FlxG.state.visible = true;
        if (video != null) {
            video.dispose();
            video = null;
        }
        #elseif web
        FlxG.state.visible = true;
        if (netStream != null) {
            netStream.dispose();
            netStream = null;
        }
        if (video != null) {
            if (FlxG.game.contains(video))
                FlxG.game.removeChild(video);
    
            video = null;
        }
        #end
    }
}