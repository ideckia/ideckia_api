package api.dialog;

typedef DialogTypes = {}

typedef FileFilter = {
	var ?name:String;
	var patterns:Array<String>;
}

typedef ColorDef = {
	var red:UInt;
	var green:UInt;
	var blue:UInt;
}

typedef WindowOptions = {
	var ?height:UInt;
	var ?width:UInt;
	var ?windowIcon:String;
	var ?dialogIcon:String;
	var ?okLabel:String;
	var ?cancelLabel:String;
	var ?extraData:Any; // Keep a door open for any extra data needed by an implementation
}

typedef IdValue<T> = {
	var id:String;
	var value:T;
}

@:forward
abstract Color(ColorDef) {
	public inline function new(cd)
		this = cd;

	@:to
	public inline function toString():String
		return "0x" + StringTools.hex((this.red << 16) | (this.green << 8) | this.blue, 6);

	@:from
	static public function fromInt(s:Int) {
		if (s == null)
			return new Color({
				red: 0,
				green: 0,
				blue: 0
			});
		return new Color({
			red: (s & 0xff0000) >>> 16,
			green: (s & 0x00ff00) >>> 8,
			blue: s & 0x0000ff,
		});
	}

	@:from
	static public function fromString(s:String) {
		if (s == null)
			return new Color({
				red: 0,
				green: 0,
				blue: 0
			});
		if (s.indexOf("rgb(") == 0) {
			var ereg = ~/rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)/;

			if (ereg.match(s)) {
				return new Color({
					red: Std.parseInt(ereg.matched(1)),
					green: Std.parseInt(ereg.matched(2)),
					blue: Std.parseInt(ereg.matched(3))
				});
			}
		} else if (s.indexOf("#") == 0) {
			return fromInt(Std.parseInt("0x" + s.substring(1, s.length)));
		} else if (s.indexOf("0x") == 0) {
			return fromInt(Std.parseInt(s));
		}

		return new Color({
			red: 0,
			green: 0,
			blue: 0
		});
	}
}
