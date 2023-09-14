package funkin.util.song.formats;

/*
    Kinda made only to not have all engine converter stuff in Song.hx
*/

class FunkinFormat {
    //Fixes charts from other engines
	public static function engineCheck(?song:SwagSong):SwagSong {
		if (song == null) return null;

		//Get special engine variables ready if missing
		var specialFields:Array<Array<Dynamic>> = [
			['players', ['bf','dad','gf']]
		];
		for (field in specialFields) {
			if (!Reflect.hasField(song, field[0])) {
				Reflect.setField(song, field[0], field[1]);
			}
		}

		for (field in Reflect.fields(song)) {
			switch (field) {
				case 'gfVersion' | 'gf' | 'player3' | 'player2' | 'player1':
					var playerIndex:Int = 0;
					switch(field) {
						case 'player1': playerIndex = 0;
						case 'player2': playerIndex = 1;
						default:		playerIndex = 2;
					}
					var players:Array<String> = Reflect.field(song, 'players');
					players[playerIndex] = Reflect.field(song, field);
					Reflect.setField(song, 'players', players);
					Reflect.deleteField(song, field);
				case 'events':
					song = convertPsychChart(song);	
					Reflect.deleteField(song, field);
			}
		}
		return song;
	}
	
	public static function convertPsychChart(song:SwagSong) {
		var psychEvents:Array<Dynamic> = Reflect.field(song, 'events');
		if (psychEvents == null || psychEvents.length <= 0) return song;

		var events:Array<Array<Dynamic>> = [];
		for (e in psychEvents) {
			var eventTime = e[0];
			var _events:Array<Array<Dynamic>> = e[1];
			for (i in _events) events.push([eventTime, i[0], [i[1], i[2]]]);
		}

		for (i in events) {
			var eventSec = Song.getTimeSection(song, i[0]);
			Song.checkAddSections(song, eventSec);
			song.notes[eventSec] = Song.checkSection(song.notes[eventSec]);
			song.notes[eventSec].sectionEvents.push(i);
		}

		return song;
	}
}