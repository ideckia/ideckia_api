package api.action;

import api.IdeckiaApi.IdeckiaCore;

@:build(api.action.Translate.build())
class Translate {
	static var translations:api.IdeckiaApi.Translations;
	static var core:IdeckiaCore;

	@:noCompletion static public function load(core:IdeckiaCore, translationsDir:String) {
		Translate.core = core;
		translations = api.action.Data.getTranslations(translationsDir);
	}

	@:noCompletion public static function tr(textId:String, ?args:Array<Dynamic>) {
		return core == null ? textId : translations.tr(core.getCurrentLang(), textId, args);
	}
}

abstract TranslateText(String) to String from String {
	inline public function new(id)
		this = id;

	public inline function tr(?args:Array<Dynamic>) {
		return Translate.tr(this, args);
	}
}
