package api.data;

import api.IdeckiaApi.Translations;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class Translate {
	static public var INVALID_CHARS = ~/[^A-Za-z0-9_]/g;

	static public function build():Array<Field> {
		var currentFields = Context.getBuildFields();

		var translations = getTranslations();

		if (translations == null)
			return currentFields;

		var textsLang = getDefinedValueWithDefault('language', 'en');
		if (!translations.exists(textsLang))
			textsLang = translations.keys().next();

		for (t in translations.get(textsLang)) {
			currentFields.push({
				name: INVALID_CHARS.replace(t.id, '_'),
				access: [APublic, AStatic, AInline],
				pos: Context.currentPos(),
				kind: FVar(macro :String, macro $v{t.id})
			});
		}

		return currentFields;
	}

	@:noCompletion public static function tr(textId:String, ?args:Array<Dynamic>) {
		var translations = getTranslations();
		var language = getDefinedValueWithDefault('language', 'en');
		return translations.tr(language, textId, args);
	}

	static function getTranslations() {
		var translationsPath = getDefinedValueWithDefault('translationsPath', 'lang');
		try {
			return @:privateAccess api.data.Data._getTranslations(translationsPath);
		} catch (e:haxe.Exception) {
			Context.error(e.message, Context.currentPos());
			return null;
		}
	}

	static function getDefinedValueWithDefault(definedName:String, defaultValue:String) {
		var definedTranslationsPath = Context.definedValue(definedName);
		return (definedTranslationsPath == null) ? defaultValue : definedTranslationsPath;
	}
}
