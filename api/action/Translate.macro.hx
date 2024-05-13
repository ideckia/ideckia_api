package api.action;

import api.IdeckiaApi.Translations;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class Translate {
	static public function build():Array<Field> {
		var currentFields = Context.getBuildFields();

		var translations = getTranslations();
		var fieldName;
		for (l => texts in translations) {
			for (t in texts) {
				currentFields.push({
					name: t.id,
					access: [APublic, AStatic, AInline],
					pos: Context.currentPos(),
					kind: FVar(macro :Translate.TranslateText, macro new TranslateText($v{t.id}))
				});
			}
			break;
		}

		return currentFields;
	}

	@:noCompletion public static function tr(textId:String, ?args:Array<Dynamic>) {
		var translations = getTranslations();
		var definedLanguage = Context.definedValue("language");
		var language = (definedLanguage == null) ? 'en' : definedLanguage;
		return translations.tr(language, textId, args);
	}

	static function getTranslations() {
		var definedTranslatePath = Context.definedValue("definedTranslatePath");
		var translatePath = (definedTranslatePath == null) ? 'lang' : definedTranslatePath;
		return @:privateAccess api.action.Data._getTranslations(translatePath);
	}
}
