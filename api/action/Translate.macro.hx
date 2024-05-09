package api.action;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class Translate {
	static public function build():Array<Field> {
		var currentFields = Context.getBuildFields();

		var defPath = Context.definedValue("langPath");
		var path = (defPath == null) ? 'lang' : defPath;
		var translations = @:privateAccess api.action.Data._getTranslations(path);
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
}
