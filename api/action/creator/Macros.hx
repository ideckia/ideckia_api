package api.action.creator;

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
#end

typedef TplFile = {
	var isDir:Bool;
	var path:String;
	var content:String;
}

class Macros {
	#if macro
	static function getTemplate(templateType:String):ExprOf<Array<TplFile>> {
		// get the current fields of the class
		var fields:Array<Field> = Context.getBuildFields();

		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(FileSystem.fullPath(posInfos.file));

		// get the current class information.
		var ref:ClassType = Context.getLocalClass().get();
		var templatePath:String = Path.join([directory, 'tpl', templateType]);

		if (FileSystem.exists(templatePath) && FileSystem.isDirectory(templatePath)) {
			var templateFiles:Array<Expr> = [];
			extractTplFilesRec(templatePath, '.', templateFiles);

			var readme = 'readme.md';
			var content = sys.io.File.getContent(Path.join([directory, 'tpl', readme]));
			var readmeTpl = {isDir: false, path: readme, content: content};
			templateFiles.push(macro $v{readmeTpl});

			// return as expression
			return macro $a{templateFiles};
		} else {
			return macro null;
		}
	}

	static function extractTplFilesRec(baseDir:String, relDir:String, files:Array<Expr>) {
		var absPath, relPath, isDir, value, absDir = baseDir + '/' + relDir;
		for (f in FileSystem.readDirectory(absDir)) {
			absPath = absDir + '/$f';
			relPath = relDir + '/$f';
			isDir = FileSystem.isDirectory(absPath);
			value = {
				isDir: isDir,
				path: relPath,
				content: (isDir) ? null : sys.io.File.getContent(absPath)
			};
			files.push(macro $v{value});
			if (isDir)
				extractTplFilesRec(baseDir, relPath, files);
		}
	}
	#end

	public static macro function getHxTemplate():ExprOf<Array<TplFile>> {
		return getTemplate('hx');
	}

	public static macro function getJsTemplate():ExprOf<Array<TplFile>> {
		return getTemplate('js');
	}
}
