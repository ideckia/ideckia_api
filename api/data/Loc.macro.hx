package api.data;

import api.IdeckiaApi.LocalizedTexts;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class Loc {
	static public var INVALID_CHARS = ~/[^A-Za-z0-9_]/g;

	static public function build():Array<Field> {
		var currentFields = Context.getBuildFields();

		var localizations = getlocalizations();

		if (localizations == null)
			return currentFields;

		var textsLocale = getDefinedValueWithDefault('locale', 'en_uk');
		if (!localizations.exists(textsLocale))
			textsLocale = localizations.keys().next();

		for (t in localizations.get(textsLocale)) {
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
		var localizations = getlocalizations();
		var locale = getDefinedValueWithDefault('locale', 'en_uk');
		return localizations.tr(locale, textId, args);
	}

	static function getlocalizations() {
		var localizationsPath = getDefinedValueWithDefault('localizationsPath', 'loc');
		try {
			return @:privateAccess api.data.Data._getLocalizations(localizationsPath);
		} catch (e:haxe.Exception) {
			// Context.error(e.message, Context.currentPos());
			return null;
		}
	}

	static function getDefinedValueWithDefault(definedName:String, defaultValue:String) {
		var definedlocalizationsPath = Context.definedValue(definedName);
		return (definedlocalizationsPath == null) ? defaultValue : definedlocalizationsPath;
	}
}
