package api.cmd.creator;

import sys.FileSystem;
import haxe.io.Path;

using StringTools;

class CmdCreator {
	public static function create(?commandsPath:String) {
		Sys.stdout().writeString('What template (hx | js)?  ');
		var tplType = Sys.stdin().readLine().toString();
		Sys.stdout().writeString('Command name?  ');
		var name = Sys.stdin().readLine().toString();
		var correctName = name.charAt(0).toUpperCase() + name.substr(1);

		var tplFiles:Map<String, String> = null;
		if (tplType == 'hx')
			tplFiles = Macros.getHxTemplate();
		else if (tplType == 'js')
			tplFiles = Macros.getJsTemplate();

		if (tplFiles != null) {
			if (commandsPath == null)
				commandsPath = Path.directory(Sys.programPath());

			var directory = Path.join([FileSystem.fullPath(commandsPath), name.toLowerCase()]);
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

			Sys.stdout().writeString('Creating [$name] command from template [$tplType] in [$directory]');
		} else {
			Sys.stdout().writeString('Could not found the [$tplType] template.');
		}
	}
}
