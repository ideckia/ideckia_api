package api.action.creator;

import api.action.creator.Macros.TplFile;
import sys.FileSystem;
import haxe.io.Path;

using StringTools;

class ActionCreator {
	public static function create(?actionsPath:String) {
		var tplType = '';
		while (tplType != 'hx' && tplType != 'js') {
			Sys.stdout().writeString('Select template (hx | js):  ');
			tplType = Sys.stdin().readLine().toString();
		}

		var name = '';
		while (name.trim() == '') {
			Sys.stdout().writeString('Action name:  ');
			name = Sys.stdin().readLine().toString();
		}

		Sys.stdout().writeString('Action description:  ');
		var description = Sys.stdin().readLine().toString();

		name = ~/\s+/g.replace(name, '-').toLowerCase();
		var splittedName = name.split('-');
		var className = '';
		for (s in splittedName) {
			className += s.charAt(0).toUpperCase() + s.substr(1);
		}

		var tplFiles:Array<TplFile> = null;
		if (tplType == 'hx')
			tplFiles = Macros.getHxTemplate();
		else if (tplType == 'js')
			tplFiles = Macros.getJsTemplate();

		if (actionsPath == null)
			actionsPath = Path.directory(Sys.programPath());

		var directory = Path.join([FileSystem.fullPath(actionsPath), name]);
		FileSystem.createDirectory(directory);

		var fileContent;
		for (tplFile in tplFiles) {
			if (tplFile.path.endsWith('.hx')) {
				tplFile.path = Path.directory(tplFile.path) + '/$className.hx';
			}

			if (tplFile.isDir) {
				FileSystem.createDirectory(directory + '/${tplFile.path}');
			} else {
				fileContent = tplFile.content.replace('::className::', className).replace('::name::', name).replace('::description::', description);
				sys.io.File.saveContent(directory + '/${tplFile.path}', fileContent);
			}
		}

		Sys.println('Created [$name] action from template [$tplType] in [$directory]');

		if (tplType == 'hx') {
			Sys.println('Trying to install ideckia_api using lix: executing "lix install gh:ideckia/ideckia_api"');
			Sys.command('cd ' + directory + ' && lix install gh:ideckia/ideckia_api');
		}
	}
}
