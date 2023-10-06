package funkin.util.backend;

import funkin.util.song.formats.OsuFormat;
import funkin.states.editors.ModSetupState;

enum ZipFormat {
    OSU;
    QUAVER;
    STEPMANIA;
}

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
            var zipType = zipMap.get(a);
            for (i in zipArrays.get(a)) {
                final zipPath = Paths.getModPath('$i.$a');
                final modPath = Paths.getModPath(i);
                
                var zipEntries = UnZipper.getZipEntries(zipPath);
                var zipFiles = UnZipper.unzipFiles(zipEntries, modPath); // Unzip and get zip files
                ModSetupState.setupModFolder(i); // Setup folders
                removeQueue.push(zipPath);
                
                switch (zipType) {
                    case OSU: unzipOsu(zipFiles, modPath);
                    case QUAVER:
                    case STEPMANIA:
                }
            }
        }

        removeFilesFromQueue();
    }

    static function unzipOsu(zipFiles:Array<String>, modPath:String) {
        var _audios:Array<String> = [];
        var _charts:Array<String> = [];
        
        for (i in zipFiles) {
            switch (i.split(".")[1]) {
                case "mp3" | "wav": _audios.push(i);
                case "osu": _charts.push(i);
                default: removeQueue.push(i);
            }
        }

        var _songs:Array<String> = [];

        for (i in _charts) {
            var osuChart = OsuFormat.convertSong(i);
            final formatSong = Song.formatSongFolder(osuChart.song);
            createSongFolder('$modPath/songs/$formatSong', formatSong, osuChart, _audios[0]);
            _songs.push(osuChart.song);
            removeQueue.push(i);
        }

        // This is REALLY bad but i just wanna get it done as a experiment
        var weekJson:WeekJson = JsonUtil.copyJson(WeekSetup.DEFAULT_WEEK);
        weekJson.weekDiffs = ["hard"];
        weekJson.songList.songs = _songs.copy();

        final weekName = Song.formatSongFolder(modPath.split("mods/")[1]);
        saveJson(weekJson, '$modPath/data/weeks/$weekName.json');
    }

    static function saveJson(input:Dynamic, path:String) {
        final jsonString = FunkyJson.stringify(cast input, "\t");
        File.saveContent(path, jsonString);
    }

    static function createSongFolder(prefix:String, song:String, chart:SwagSong, audio:String) {
        for (i in ["charts", "audio"]) ModSetupState.createFolder('$prefix/$i', "");
        saveJson({song: Song.optimizeJson(chart)}, '$prefix/charts/hard.json');
        final finalAudio = '$prefix/audio/Inst.ogg';
        if (audio.endsWith(".ogg")) {
            FileSystem.rename(audio, finalAudio); // Is an ogg, just rename it
        } else {
            audioToOgg(audio, finalAudio);
        }
    }

    static public function audioToOgg(path:String, output:String) {
        ModSetupState.createFolder(output, "");
        Sys.command("assets/data/ffmpeg.exe", ['-y', '-loglevel', '0', '-i', path,
        '-c:a', 'libvorbis', '-b:a', '320k', '-map', 'a', output]);
        removeQueue.push(path);
    }

    static function removeFilesFromQueue() {
        for (i in removeQueue) {
            if (FileSystem.exists(i))
                FileSystem.deleteFile(i);
        }
    }
}