package api.action.creator;

import sys.FileSystem;
import haxe.io.Path;

using StringTools;

class ActionCreator {
	public static function create(?actionsPath:String) {
		Sys.stdout().writeString('What template (hx | js)?  ');
		var tplType = Sys.stdin().readLine().toString();
		var name = '';
		while (name.trim() == '') {
			Sys.stdout().writeString('Action name?  ');
			name = Sys.stdin().readLine().toString();
		}
		Sys.stdout().writeString('Action description?  ');
		var description = Sys.stdin().readLine().toString();

		name = ~/\s+/g.replace(name, '-').toLowerCase();
		var splittedName = name.split('-');
		var className = '';
		for (s in splittedName) {
			className += s.charAt(0).toUpperCase() + s.substr(1);
		}

		var tplFiles:Map<String, String> = null;
		if (tplType == 'hx')
			tplFiles = Macros.getHxTemplate();
		else if (tplType == 'js')
			tplFiles = Macros.getJsTemplate();

		if (tplFiles != null) {
			if (actionsPath == null)
				actionsPath = Path.directory(Sys.programPath());

			var directory = Path.join([FileSystem.fullPath(actionsPath), name]);
			FileSystem.createDirectory(directory);

			var filename;
			var fileContent;
			for (key => value in tplFiles) {
				filename = key;
				if (key.endsWith('.hx')) {
					filename = className + '.hx';
				}

				fileContent = value.replace('::className::', className).replace('::name::', name).replace('::description::', description);

				sys.io.File.saveContent(directory + '/$filename', fileContent);
			}

			Sys.stdout().writeString('Creating [$name] action from template [$tplType] in [$directory]');
		} else {
			Sys.stdout().writeString('Could not found the [$tplType] template.');
		}
	}
}
