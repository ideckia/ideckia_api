package api.action.creator;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

typedef TplFile = {
	var isDir:Bool;
	var path:String;
	var content:String;
}

class Macros {
	public static macro function getHxTemplate():ExprOf<Array<TplFile>> {
		return getTemplateMacro('tpl_haxe');
	}

	public static macro function getJsTemplate():ExprOf<Array<TplFile>> {
		return getTemplateMacro('tpl_javascript');
	}

	public static macro function getTemplatesList():ExprOf<Array<String>> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(FileSystem.fullPath(posInfos.file));
		var tplDirectory = Path.join([directory, 'templates']);

		var templates = [
			for (tpl in FileSystem.readDirectory(tplDirectory))
				if (StringTools.startsWith(tpl, 'tpl_')
					&& FileSystem.isDirectory(tplDirectory + '/$tpl')) macro $v{StringTools.replace(tpl, 'tpl_', '')}
		];
		return macro $a{templates};
	}

	public static function getTemplate(baseDirectory:String, templateType:String):Array<TplFile> {
		var templatePath:String = Path.join([baseDirectory, templateType]);

		var templateFiles:Array<TplFile> = [];
		if (FileSystem.exists(templatePath) && FileSystem.isDirectory(templatePath)) {
			extractTplFilesRec(templatePath, '.', templateFiles);
		}

		return templateFiles;
	}

	static function extractTplFilesRec(baseDir:String, relDir:String, files:Array<TplFile>) {
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
			files.push(value);
			if (isDir)
				extractTplFilesRec(baseDir, relPath, files);
		}
	}

	#if macro
	static function getTemplateMacro(templateType:String):ExprOf<Array<TplFile>> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var directory = Path.directory(FileSystem.fullPath(posInfos.file));
		var tplDirectory = Path.join([directory, 'templates']);

		var templateFiles = getTemplate(tplDirectory, templateType);

		if (templateFiles.length == 0) {
			return macro null;
		} else {
			var macroTemplates:Array<Expr> = [
				for (tf in templateFiles)
					macro $v{tf}
			];
			inline function addFile(filename:String) {
				var content = sys.io.File.getContent(Path.join([tplDirectory, filename]));
				var fileTpl = {isDir: false, path: filename, content: content};
				macroTemplates.push(macro $v{fileTpl});
			}

			addFile('readme.md');
			addFile('presets.json');
			addFile('test_action.js');

			var locDir = 'loc';
			var locFile = 'en_UK.json';
			var locDirTpl = {isDir: true, path: locDir, content: null};
			var locFileTpl = {
				isDir: false,
				path: Path.join([locDir, locFile]),
				content: sys.io.File.getContent(Path.join([tplDirectory, 'loc', locFile]))
			};
			macroTemplates.push(macro $v{locDirTpl});
			macroTemplates.push(macro $v{locFileTpl});

			return macro $a{macroTemplates};
		}
	}
	#end
}
