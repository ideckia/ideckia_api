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

	@:noCompletion public static function t(textId:String, ?args:Array<Dynamic>) {
		return translations.t(core.getCurrentLang(), textId, args);
	}
}

abstract TranslateText(String) to String from String {
	inline public function new(id)
		this = id;

	public inline function t(?args:Array<Dynamic>) {
		return Translate.t(this, args);
	}
}
