package api.data;

import api.IdeckiaApi.LocalizedTexts;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

class Data {
	public static macro function embedContent(filename:String):ExprOf<String> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		var data = _getContent(Path.join([directory, filename]));
		if (data == null)
			Context.fatalError('Could not find the file [$filename]', haxe.macro.Context.currentPos());
		return macro $v{data};
	}

	public static macro function embedJson(filename:String):ExprOf<Dynamic> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		var data = _getJson(Path.join([directory, filename]));
		if (data == null)
			Context.fatalError('Could not find the file [$filename]', haxe.macro.Context.currentPos());
		return macro $v{data};
	}

	public static macro function embedLocalizations(localizationDir:String):ExprOf<LocalizedTexts> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		try {
			return macro $v{_getLocalizations(Path.join([directory, localizationDir]))};
		} catch (e:haxe.Exception) {
			Context.fatalError(e.message, haxe.macro.Context.currentPos());
			return macro null;
		}
	}

	public static macro function embedBytes(filename:String):ExprOf<haxe.io.Bytes> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		var data = _getBytes(Path.join([directory, filename]));
		if (data == null)
			Context.fatalError('Could not find the file [$filename]', haxe.macro.Context.currentPos());
		return macro $v{data};
	}

	public static macro function embedBase64(filename:String):ExprOf<String> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		var data = _getBase64(Path.join([directory, filename]));
		if (data == null)
			Context.fatalError('Could not find the file [$filename]', haxe.macro.Context.currentPos());
		return macro $v{data};
	}

	#if !macro
	public static inline function getContent(path:String) {
		return _getContent(path);
	}

	public static inline function getJson(path:String) {
		return _getJson(path);
	}

	public static inline function getLocalizations(path:String):LocalizedTexts {
		return _getLocalizations(path);
	}

	public static inline function getBytes(path:String) {
		return _getBytes(path);
	}

	public static inline function getBase64(path:String) {
		return _getBase64(path);
	}
	#end

	static function _getContent(filePath:String) {
		return if (sys.FileSystem.exists(filePath)) {
			sys.io.File.getContent(filePath);
		} else {
			null;
		}
	}

	static function _getLocalizations(localizationsDir:String):LocalizedTexts {
		var locTexts = new Map();
		if (sys.FileSystem.exists(localizationsDir) && sys.FileSystem.isDirectory(localizationsDir)) {
			for (locFile in sys.FileSystem.readDirectory(localizationsDir)) {
				var locContent = haxe.Json.parse(sys.io.File.getContent(localizationsDir + '/$locFile'));
				locTexts.set(StringTools.replace(locFile.toLowerCase(), '.json', ''), locContent);
			}
		} else {
			throw new haxe.Exception('Trying to get localizations for a non existing [$localizationsDir] directory.');
		}

		return new LocalizedTexts(locTexts);
	}

	static function _getJson(filePath:String) {
		return if (sys.FileSystem.exists(filePath)) {
			haxe.Json.parse(sys.io.File.getContent(filePath));
		} else {
			null;
		}
	}

	static function _getBytes(filePath:String) {
		return if (sys.FileSystem.exists(filePath)) {
			sys.io.File.getBytes(filePath);
		} else {
			null;
		}
	}

	static function _getBase64(filePath:String) {
		return if (sys.FileSystem.exists(filePath)) {
			haxe.crypto.Base64.encode(sys.io.File.getBytes(filePath));
		} else {
			null;
		}
	}
}
