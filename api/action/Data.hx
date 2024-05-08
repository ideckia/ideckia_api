package api.action;

import api.IdeckiaApi.Translations;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

class Data {
	public static macro function embedContent(filename:String):ExprOf<String> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		return macro $v{_getContent(Path.join([directory, filename]))};
	}

	public static macro function embedJson(filename:String):ExprOf<Dynamic> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		return macro $v{_getJson(Path.join([directory, filename]))};
	}

	public static macro function embedTranslations(translationDir:String):ExprOf<Translations> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		return macro $v{_getTranslations(Path.join([directory, translationDir]))};
	}

	public static macro function embedBytes(filename:String):ExprOf<haxe.io.Bytes> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		return macro $v{_getBytes(Path.join([directory, filename]))};
	}

	public static macro function embedBase64(filename:String):ExprOf<String> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(posInfos.file);
		return macro $v{_getBase64(Path.join([directory, filename]))};
	}

	#if !macro
	public static function getContent(filename:String) {
		return _getContent(Path.join([js.Node.__dirname, filename]));
	}

	public static function getJson(filename:String) {
		return _getJson(Path.join([js.Node.__dirname, filename]));
	}

	public static function getTranslations(translationDir:String):Translations {
		return getTranslationsAbsolute(Path.join([js.Node.__dirname, translationDir]));
	}

	public static function getTranslationsAbsolute(translationAbsoluteDir:String):Translations {
		return _getTranslations(translationAbsoluteDir);
	}

	public static function getBytes(filename:String) {
		return _getBytes(Path.join([js.Node.__dirname, filename]));
	}

	public static function getBase64(filename:String) {
		return _getBase64(Path.join([js.Node.__dirname, filename]));
	}
	#end

	static function _getContent(filePath:String) {
		return if (sys.FileSystem.exists(filePath)) {
			sys.io.File.getContent(filePath);
		} else {
			null;
		}
	}

	static function _getTranslations(translationsDir:String):Translations {
		var translations:Translations = new Map();
		if (sys.FileSystem.exists(translationsDir) && sys.FileSystem.isDirectory(translationsDir)) {
			for (langFile in sys.FileSystem.readDirectory(translationsDir)) {
				var transContent = haxe.Json.parse(sys.io.File.getContent(translationsDir + '/$langFile'));
				translations.set(StringTools.replace(langFile.toLowerCase(), '.json', ''), transContent);
			}
		}

		return translations;
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
