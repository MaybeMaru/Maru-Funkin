package funkin.util.backend;

import funkin.util.song.formats.QuaFormat;
import funkin.util.song.formats.OsuFormat;
import funkin.states.editors.ModSetupState;

enum ZipFormat {
    OSU;
    QUAVER;
    STEPMANIA;
}

typedef UnZipType = {
    var getMap: (chart:String) -> Dynamic;
    var convert: (map:Dynamic) -> SwagSong;
    var title: String;
    var diff: String;
    var audio: String;
};

class SongZip {

    static var zipMap:Map<String, ZipFormat> = [
        "osz" => OSU,
        "qp" => QUAVER,
        "sm" => STEPMANIA,
        "ssc" => STEPMANIA
    ];

    static var removeQueue:Array<String> = []; // Files that will be deleted after zips are unzipped

    public static function init() {
        removeQueue = [];
        var zipArrays:Map<String, Array<String>> = [];

        for (i in zipMap.keys()) {
            var zipList:Array<String> = Paths.getModFileList('', i, false, true, false);
            for (i in 0...zipList.length) zipList[i] = zipList[i].replace("//", "/");
            zipArrays.set(i, zipList);
        }

        for (a in zipArrays.keys()) {
            final zipType = zipMap.get(a);
            for (i in zipArrays.get(a)) {
                final zipPath = Paths.getModPath('$i.$a');
                final modPath = Paths.getModPath(i);
                
                var zipEntries = UnZipper.getZipEntries(zipPath);
                var zipFiles = UnZipper.unzipFiles(zipEntries, modPath); // Unzip and get zip files
                ModSetupState.setupModFolder(i); // Setup folders
                removeQueue.push(zipPath);
                
                switch (zipType) {
                    case OSU: unzipFormat("osu", modPath, zipFiles);//unzipOsu(zipFiles, modPath);
                    case QUAVER: unzipFormat("qua", modPath, zipFiles);//unzipQuaver(zipFiles, modPath);
                    case STEPMANIA:
                }
            }
        }

        removeFilesFromQueue();
    }

    static var UNZIP_FORMAT:Map<String, UnZipType> = [
        "osu" => {
            getMap: function(chart) return cast new OsuFormat(chart),
            convert: function(map) return OsuFormat.convertSong("", map),
            title: "Title",
            diff: "Version",
            audio: "AudioFilename"
        },
        "qua" => {
            getMap: function(chart) return cast new QuaFormat(chart),
            convert: function(map) return QuaFormat.convertSong("", map),
            title: "Title",
            diff: "DifficultyName",
            audio: "AudioFile"
        }
    ];

    static function unzipFormat(format:String, modPath:String, zipFiles:Array<String>) {
        var _charts:Array<String> = [];
        for (i in zipFiles) {
            switch (i.split(".")[1]) {
                case "qua" | "osu": _charts.push(i);
                default: removeQueue.push(i);
            }
        }

        var formatUnzip = UNZIP_FORMAT.get(format);
        var _songDiffs:Map<String, Array<String>> = [];
        for (i in _charts) {
            var map = formatUnzip.getMap(i);
            final title = map.getVar(formatUnzip.title);
            final formatTitle = Song.formatSongFolder(title);
            
            final mapDiff = map.getVar(formatUnzip.diff);
            final mapAudio = '$modPath/${map.getVar(formatUnzip.audio)}';

            if (_songDiffs.exists(title)) _songDiffs.get(title).push(mapDiff);
            else _songDiffs.set(title, [mapDiff]);

            var chart = formatUnzip.convert(map);
            createSongFolder('$modPath/songs/$formatTitle', formatTitle, chart, mapAudio, mapDiff);
            removeQueue.push(i);
        }

        for (i in _songDiffs.keys()) {
            var weekJson:WeekJson = JsonUtil.copyJson(WeekSetup.DEFAULT_WEEK);
            weekJson.weekDiffs = CoolUtil.customSort(_songDiffs.get(i), ['easy', 'normal', 'hard']);
            weekJson.songList.songs = [i];
            saveJson(weekJson, '$modPath/data/weeks/${Song.formatSongFolder(i)}.json');
        }
    }
    
    static function saveJson(input:Dynamic, path:String) {
        final jsonString = FunkyJson.stringify(cast input, "\t");
        File.saveContent(path, jsonString);
    }

    static function createSongFolder(prefix:String, song:String, chart:SwagSong, audio:String, diff:String = 'hard') {
        for (i in ["charts", "audio"]) ModSetupState.createFolder('$prefix/$i', "");
        saveJson({song: Song.optimizeJson(chart)}, '$prefix/charts/$diff.json');
        final finalAudio = '$prefix/audio/Inst.ogg';
        if (!FileSystem.exists(finalAudio)) {
            if (audio.endsWith(".ogg")) {
                FileSystem.rename(audio, finalAudio); // Is an ogg, just rename it
            } else {
                audioToOgg(audio, finalAudio);
            }
        }
    }

    static public function audioToOgg(path:String, output:String) {
        ModSetupState.createFolder(output, "");
        Sys.command("assets/data/ffmpeg.exe", ['-y', '-loglevel', '0', '-i', path,
        '-c:a', 'libvorbis', '-b:a', '64k', '-map', 'a', output]);
        removeQueue.push(path);
    }

    static function removeFilesFromQueue() {
        for (i in removeQueue) {
            if (FileSystem.exists(i))
                FileSystem.deleteFile(i);
        }
    }
}