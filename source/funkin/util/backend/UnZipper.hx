package funkin.util.backend;

import haxe.io.Path;
import haxe.zip.Entry;
import haxe.zip.Uncompress;
import haxe.zip.Reader;
import sys.io.File;

/*
    Credits to part of this code to the Yoshi Crafter engine devs!!
    I was way too dumb to figure out haxe zip by myself!!
*/

class UnZipper {
    public static function unzipInPath(zipPath:String, destPath:String) {
        return unzipFiles(getZipEntries(zipPath), destPath);
    }
    
    public static function getZipEntries(path:String) {
        var zipData = openZip(path);

        var zip = zipData.reader;
        var file = zipData.file;
        var fields = zip.read();

        if (file != null)
            file.close();

        return fields;
    }

    public static function unzipFiles(entries:List<Entry>, destPath:String) {
        var _files:Array<String> = [];
        var tempIndex:Int = 0; // Used for invalid file names

        for(_ => field in entries) {
            final isFolder = field.fileName.endsWith("/") && field.fileSize == 0;
            if (isFolder) {
                FileSystem.createDirectory('$destPath/${field.fileName}');
            } 
            else {
                var split = [for(e in field.fileName.split("/")) e.trim()];
                split.pop();
                FileSystem.createDirectory('$destPath/${split.join("/")}');

                var data = unzip(field);
                var filePath = '$destPath/${field.fileName}';

                try {
                    File.saveBytes(filePath, data);
                }
                catch (e) // Slap-on fix
                {
                    filePath = '$destPath/__tempFile${tempIndex++}.' + Path.extension(field.fileName);
                    File.saveBytes(filePath, data);
                }
                
                _files.push(filePath);
            }
        }
        return _files;
    }

    public static function unzip(f:Entry) {
		if (!f.compressed)
			return f.data;
		var c = new haxe.zip.Uncompress(-15);
		var s = haxe.io.Bytes.alloc(f.fileSize);
		var r = c.execute(f.data, 0, s, 0);
		c.close();
		if (!r.done || r.read != f.data.length || r.write != f.fileSize)
			throw "Invalid compressed data for " + f.fileName;
		f.compressed = false;
		f.dataSize = f.fileSize;
		f.data = s;
		return f.data;
	}

    public static function openZip(zipPath:String) {
        var file = File.read(zipPath);
        var reader = new Reader(file);
        return {
            reader: reader,
            file: file
        }
    }
}