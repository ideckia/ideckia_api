package api;

typedef TRichString = {
	var ?bold:Bool;
	var ?italic:Bool;
	var ?underline:Bool;
	var ?size:UInt;
	var ?color:String;
	var ?text:String;
}

class Utils {
	public static function extractTRichStrings(text:String):Array<TRichString> {
		var extracted = [];
		var detected;
		var detectorRreg = ~/\{([^}]*)\}/g;
		var extractorEreg = ~/\{([^:]*):/g;

		while (detectorRreg.match(text)) {
			detected = detectorRreg.matched(0);
			var value;
			var rs:TRichString = {};
			while (extractorEreg.match(detected)) {
				value = extractorEreg.matched(1);
				if (value == 'b')
					rs.bold = true;
				if (value == 'i')
					rs.italic = true;
				if (value == 'u')
					rs.underline = true;
				if (StringTools.startsWith(value, 'color.')) {
					rs.color = StringTools.replace(value, 'color.', '');
				}
				if (StringTools.startsWith(value, 'size.')) {
					rs.size = Std.parseInt(StringTools.replace(value, 'size.', ''));
				}
				detected = extractorEreg.matchedRight();
			}
			rs.text = StringTools.replace(detected, '}', '');
			extracted.push(rs);
			text = detectorRreg.matchedRight();
		}

		return extracted;
	}
}
