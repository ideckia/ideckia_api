import haxe.macro.Context;

using StringTools;

class NoLocalLibs {
	public static function check() {
		if (!Context.defined('--no-local-libs'))
			return;

		var content;
		var libPath;
		for (f in sys.FileSystem.readDirectory('./haxe_libraries')) {
			content = sys.io.File.getContent('./haxe_libraries/$f');

			for (line in content.split('\n')) {
				if (line.startsWith('-cp') || line.startsWith('--class-path')) {
					libPath = line.replace('-cp', '').replace('--class-path', '').trim();
					if (!libPath.startsWith("${HAXE_LIBCACHE}")) {
						Context.fatalError('Undesired local library dependency found for library [${f.replace('.hxml', '')}]', Context.currentPos());
					}
				}
			}
		}
	}
}
