package api.action.creator;

import api.action.creator.Macros.TplFile;
import api.internal.ServerApi;
import sys.FileSystem;
import haxe.io.Path;

using StringTools;

class ActionCreator {
	public static var TEMPLATES_LIST = Macros.getTemplatesList();

	public static function create(createActionDef:CreateActionDef, logInfo:(data:Dynamic, ?posInfos:Null<haxe.PosInfos>) -> Void) {
		return new js.lib.Promise((resolve, reject) -> {
			var name = ~/\s+/g.replace(createActionDef.name, '-').toLowerCase();
			var description = createActionDef.description;
			var splittedName = name.split('-');
			var className = '';
			for (s in splittedName) {
				className += s.charAt(0).toUpperCase() + s.substr(1);
			}

			var isHxTpl = false;
			var tplFiles:Array<TplFile> = null;
			var tplDirectory = createActionDef.tplDirectory;
			var tplName = createActionDef.tplName.toLowerCase();
			if (tplDirectory == 'embed') {
				switch createActionDef.tplName {
					case 'haxe':
						isHxTpl = true;
						tplFiles = Macros.getHxTemplate();
					case 'javascript':
						tplFiles = Macros.getJsTemplate();
					default:
				};
			} else {
				tplFiles = Macros.getTemplate(tplDirectory, createActionDef.tplName);
			}

			var actionPath = createActionDef.destPath;
			if (actionPath == null || actionPath == '')
				actionPath = Path.directory(Sys.programPath());

			var directory = Path.join([FileSystem.fullPath(actionPath), name]);
			if (FileSystem.exists(directory)) {
				reject('Already exists an action with the name [$name].');
				return;
			}

			logInfo('Creating new action [$directory]');
			FileSystem.createDirectory(directory);

			var fileContent;
			for (tplFile in tplFiles) {
				if (tplFile.path.endsWith('.hx')) {
					tplFile.path = Path.join([Path.directory(tplFile.path), '$className.hx']);
				}
				if (tplFile.path.startsWith('./_')) {
					tplFile.path = tplFile.path.replace('./_', '.');
				}

				if (tplFile.isDir) {
					FileSystem.createDirectory(directory + '/${tplFile.path}');
				} else {
					fileContent = tplFile.content.replace('::className::', className).replace('::name::', name).replace('::description::', description);
					sys.io.File.saveContent(directory + '/${tplFile.path}', fileContent);
				}
			}

			logInfo('Created [$name] action from template [$tplName] in [$directory]');

			if (isHxTpl) {
				logInfo('Trying to install ideckia_api using lix: executing "lix install gh:ideckia/ideckia_api"');
				Sys.command('cd ' + directory + ' && lix install gh:ideckia/ideckia_api');
			}

			resolve(directory);
		});
	}
}
