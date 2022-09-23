package api.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class Macros {
	public static function addExposeMetadata(exposeName:ExprOf<String>) {
		var meta = Context.getLocalClass().get().meta;

		// add @:keep metadata
		meta.add(':keep', [], Context.currentPos());
		// add @:expose(exposeName) metadata
		meta.add(':expose', [exposeName], Context.currentPos());

		return Context.getBuildFields();
	}
}
