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

typedef Action = {
	var ?id:ActionId;
	var name:String;
	var ?props:Any;
}

typedef ServerState = {
	> BaseState,
	var ?id:StateId;
	var ?actions:Array<Action>;
}

enum Kind {
	ChangeDir(toDir:DirName, state:ServerState);
	States(?index:Int, list:Array<ServerState>);
}

typedef ServerItem = {
	var ?id:ItemId;
	var ?kind:Kind;
}

typedef Dir = {
	> BaseState,
	var ?rows:UInt;
	var ?columns:UInt;
	var name:DirName;
	var items:Array<ServerItem>;
}

typedef Layout = {
	var rows:UInt;
	var columns:UInt;
	var ?sharedVars:Array<{key:String, value:Any}>;
	var ?textSize:UInt;
	var dirs:Array<Dir>;
	var ?icons:Array<{key:String, value:String}>;
}

typedef EditorData = {
	var layout:Layout;
	var actionDescriptors:Array<ActionDescriptor>;
}

abstract ActionId(UInt) {
	public inline function new(v)
		this = v;

	@:to function toRepresentation():Representation<UInt>
		return new Representation(this);

	public function toUInt():UInt
		return this;

	@:from static function ofRepresentation(rep:Representation<UInt>)
		return new ActionId(rep.get());
}

abstract ItemId(UInt) {
	public inline function new(v)
		this = v;

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
	public inline function new(v)
		this = v;

	@:to function toRepresentation():Representation<UInt>
		return new Representation(this);

	public function toUInt():UInt
		return this;

	@:from static function ofRepresentation(rep:Representation<UInt>)
		return new StateId(rep.get());
}
