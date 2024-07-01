package funkin.objects;

import openfl.display.Sprite;

#if hxvlc
import hxvlc.openfl.Video;
#elseif web
import openfl.net.NetStream;
import openfl.net.NetConnection;
import openfl.media.Video;
#end

class FunkVideo extends Sprite implements IFlxDestroyable
{
    public var onComplete:()->Void;

    var video: #if (hxvlc || web) Video; #else Dynamic; #end

    #if web
    var netStream:NetStream;
    #end

    public function new() {
        super();

        #if hxvlc
        video = new Video(FlxSprite.defaultAntialiasing);
        video.onEndReached.add(endVideo);
        addChild(video);

        video.onOpening.add(() -> {
            if (!FlxG.signals.postUpdate.has(postUpdate))
                FlxG.signals.postUpdate.add(postUpdate);
        });
        
        #elseif web
        video = new Video();
        addChild(video);

		var netConnection:NetConnection = new NetConnection();
		netConnection.connect(null);
		
        netStream = new NetStream(netConnection);
		
        netStream.client = {onMetaData: (e) -> {
            video.attachNetStream(netStream);
		    video.width = FlxG.width;
		    video.height = FlxG.height;

            if (!FlxG.signals.postUpdate.has(postUpdate))
                FlxG.signals.postUpdate.add(postUpdate);
        }};

		netConnection.addEventListener('netStatus', (e) -> {
            if (e.info.code == 'NetStream.Play.Complete')
                endVideo();
        });
        #end    
        
		FlxG.addChildBelowMouse(this);
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
        if (video != null)
            video.dispose();
        #elseif web
        FlxG.state.visible = true;
        if (netStream != null) {
            netStream.dispose();
            netStream = null;
        }
        #end

        if (video != null)
            video = null;

        if (FlxG.signals.postUpdate.has(postUpdate))
            FlxG.signals.postUpdate.remove(postUpdate);

        if (FlxG.game.contains(this))
            FlxG.game.removeChild(this);
    }

    // Stole this from hxvlc to be safe when FlxVideo becomes deprecated lmao
    function postUpdate() {
        video.width = FlxG.scaleMode.gameSize.x;
        video.height = FlxG.scaleMode.gameSize.y;

        var volume:Float = FlxG.sound.muted ? 0 : FlxG.sound.volume;

        #if hxvlc
        video.volume = Std.int(volume * 100);
        #elseif web
        @:privateAccess
        netStream.__video.volume = volume;
        #end
    }
}