package api.action.creator;

import sys.FileSystem;
import haxe.io.Path;

using StringTools;

class ActionCreator {
	public static function create(?actionsPath:String) {
		Sys.stdout().writeString('What template (hx | js)?  ');
		var tplType = Sys.stdin().readLine().toString();
		Sys.stdout().writeString('Action name?  ');
		var name = Sys.stdin().readLine().toString();
		var correctName = name.charAt(0).toUpperCase() + name.substr(1);

		var tplFiles:Map<String, String> = null;
		if (tplType == 'hx')
			tplFiles = Macros.getHxTemplate();
		else if (tplType == 'js')
			tplFiles = Macros.getJsTemplate();

		if (tplFiles != null) {
			if (actionsPath == null)
				actionsPath = Path.directory(Sys.programPath());

			var directory = Path.join([FileSystem.fullPath(actionsPath), name.toLowerCase()]);
			FileSystem.createDirectory(directory);

			var filename;
			var fileContent;
			for (key => value in tplFiles) {
				filename = key;
				if (key.endsWith('.hx')) {
					filename = correctName + '.hx';
				}

				fileContent = value.replace('::name::', correctName).replace('::lowerName::', name.toLowerCase());

				sys.io.File.saveContent(directory + '/$filename', fileContent);
			}

			Sys.stdout().writeString('Creating [$name] action from template [$tplType] in [$directory]');
		} else {
			Sys.stdout().writeString('Could not found the [$tplType] template.');
		}
	}
}
