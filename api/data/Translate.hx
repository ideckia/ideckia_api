package api.data;

import api.IdeckiaApi.IdeckiaCore;

@:build(api.data.Translate.build())
class Translate {
	static var translations:api.IdeckiaApi.Translations;
	static var core:IdeckiaCore;

	@:noCompletion static public function load(core:IdeckiaCore, translationsDir:String) {
		Translate.core = core;
		translations = core.data.getTranslations(haxe.io.Path.join([js.Node.__dirname, translationsDir]));
	}

	@:noCompletion public static function tr(textId:String, ?args:Array<Dynamic>) {
		return core == null ? textId : translations.tr(core.data.getCurrentLang(), textId, args);
	}
}

abstract TranslateText(String) to String from String {
	inline public function new(id)
		this = id;

	public inline function tr(?args:Array<Dynamic>) {
		return Translate.tr(this, args);
	}
}
