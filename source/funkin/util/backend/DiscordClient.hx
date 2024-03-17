package funkin.util.backend;

#if DISCORD_ALLOWED
import Sys.sleep;
import discord_rpc.DiscordRpc;
#end

class DiscordClient
{
	static final icon:String = "funkin";
	static final largeText:String = "Friday Night Funkin'";

	public function new()
	{
		#if DISCORD_ALLOWED
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "1168666530788163705", // 814588678700924999
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			//trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if DISCORD_ALLOWED
		DiscordRpc.shutdown();
		#end
	}
	
	static function onReady()
	{
		#if DISCORD_ALLOWED
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: icon,
			largeImageText: largeText
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if DISCORD_ALLOWED
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		#if DISCORD_ALLOWED
		var startTimestamp:Float = hasStartTimestamp ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: icon,
			largeImageText: largeText,
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});
		#end
	}
}
