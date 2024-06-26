package api.internal;

using api.IdeckiaApi;

import tink.json.Representation;

interface Types {}
typedef BaseState = api.IdeckiaApi.ItemState;

typedef ClientItem = {
	> BaseState,
	var id:UInt;
}

enum abstract EditorMsgType(String) {
	var getEditorData;
	var saveLayout;
}

typedef EditorMsg = {
	var type:EditorMsgType;
	var whoami:Caller;
	var ?layout:Layout;
}

typedef ActionDef = {
	var ?id:ActionId;
	var enabled:Bool;
	var name:String;
	var ?status:ActionStatus;
	var ?props:Any;
}

typedef TemplateDef = {
	var tplName:String;
	var tplDirectory:String;
}

typedef CreateActionDef = {
	> TemplateDef,
	var name:String;
	var description:String;
	var ?destPath:String;
}

typedef CoreState = {
	> BaseState,
	var ?id:StateId;
	var ?actions:Array<ActionDef>;
}

enum Kind {
	ChangeDir(toDir:DirName, state:CoreState);
	States(?index:Int, list:Array<CoreState>);
}

typedef CoreItem = {
	var ?id:ItemId;
	var ?kind:Kind;
}

typedef Dir = {
	> BaseState,
	var ?rows:UInt;
	var ?columns:UInt;
	var ?bgColor:String;
	var name:DirName;
	var items:Array<CoreItem>;
}

typedef Layout = {
	var rows:UInt;
	var columns:UInt;
	var ?bgColor:String;
	var ?sharedVars:Array<{key:String, value:Any}>;
	var ?textSize:UInt;
	var dirs:Array<Dir>;
	var ?fixedItems:Array<CoreItem>;
	var ?icons:Array<{key:String, value:String}>;
}

typedef EditorData = {
	var layout:Layout;
	var actionDescriptors:Array<ActionDescriptor>;
}

abstract ActionId(UInt) {
	static var last = 0;

	public static function next()
		return new ActionId(last++);

	public inline function new(v) {
		if (v >= last)
			last = v + 1;
		this = v;
	}

	@:to function toRepresentation():Representation<UInt>
		return new Representation(this);

	public function toUInt():UInt
		return this;

	@:from static function ofRepresentation(rep:Representation<UInt>)
		return new ActionId(rep.get());
}

abstract ItemId(UInt) {
	static var last = 0;

	public static function next()
		return new ItemId(last++);

	public inline function new(v) {
		if (v >= last)
			last = v + 1;
		this = v;
	}

	@:to function toRepresentation():Representation<UInt>
		return new Representation(this);

	public function toUInt():UInt
		return this;

	@:from static function ofRepresentation(rep:Representation<UInt>)
		return new ItemId(rep.get());
}

abstract DirName(String) {
	public inline function new(v)
		this = v;

	@:to function toRepresentation():Representation<String>
		return new Representation(this);

	public function toString():String
		return this;

	@:from static function ofRepresentation(rep:Representation<String>)
		return new DirName(rep.get());
}

abstract StateId(UInt) {
	static var last = 0;

	public static function next()
		return new StateId(last++);

	public inline function new(v) {
		if (v >= last)
			last = v + 1;
		this = v;
	}

	@:to function toRepresentation():Representation<UInt>
		return new Representation(this);

	public function toUInt():UInt
		return this;

	@:from static function ofRepresentation(rep:Representation<UInt>)
		return new StateId(rep.get());
}
