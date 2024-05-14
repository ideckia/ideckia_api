package api.data;

import api.IdeckiaApi.Translations;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class Translate {
	static public function build():Array<Field> {
		var currentFields = Context.getBuildFields();

		var translations = getTranslations();
		var textsLang = getDefinedValueWithDefault('language', 'en');
		if (!translations.exists(textsLang))
			textsLang = translations.keys().next();

		for (t in translations.get(textsLang)) {
			currentFields.push({
				name: t.id,
				access: [APublic, AStatic, AInline],
				pos: Context.currentPos(),
				kind: FVar(macro :Translate.TranslateText, macro new TranslateText($v{t.id}))
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
		var translatePath = getDefinedValueWithDefault('definedTranslatePath', 'lang');
		try {
			return @:privateAccess api.data.Data._getTranslations(translatePath);
		} catch (e:haxe.Exception) {
			Context.error(e.message, Context.currentPos());
			return null;
		}
	}

	static function getDefinedValueWithDefault(definedName:String, defaultValue:String) {
		var definedTranslatePath = Context.definedValue(definedName);
		return (definedTranslatePath == null) ? defaultValue : definedTranslatePath;
	}
}
