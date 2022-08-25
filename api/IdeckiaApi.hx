package api;

typedef IdeckiaAction = api.action.IdeckiaAction;

// Client messages
enum abstract ClientMsgType(String) {
	var click;
	var longPress;
}

enum abstract Caller(String) {
	var client;
	var editor;
}

typedef ClientMsg = {
	var type:ClientMsgType;
	var whoami:Caller;
	var ?itemId:UInt;
}

// Server messages
enum abstract ServerMsgType(String) {
	var layout;
	var editorData;
}

enum abstract TextPosition(String) from String to String {
	var top;
	var center;
	var bottom;
}

typedef ServerMsg<T> = {
	var type:ServerMsgType;
	var data:T;
}

typedef ItemState = {
	var ?text:String;
	var ?textSize:UInt;
	var ?textColor:String;
	var ?textPosition:TextPosition;
	var ?icon:String;
	var ?bgColor:String;
}

typedef ClientLayout = {
	var rows:UInt;
	var columns:UInt;
	var items:Array<{
		> ItemState, var id:UInt;
	}>;
	var ?fixedItems:Array<{
		> ItemState, var id:UInt;
	}>;
}

typedef PropDescriptor = {
	var name:String;
	var defaultValue:String;
	var type:String;
	var ?isShared:Bool;
	var ?description:String;
	var ?values:Array<String>;
}

typedef PresetAction = {
	var name:String;
	var props:Any;
}

typedef ActionDescriptor = {
	var ?id:UInt;
	var name:String;
	var ?description:String;
	var ?props:Array<PropDescriptor>;
	var ?presets:Array<PresetAction>;
}

#if macro
typedef Promise<T> = Dynamic<T>;
#else
typedef Promise<T> = js.lib.Promise<T>;
#end

typedef IdeckiaServer = {
	var log:{
		var error:(v:Dynamic) -> Void;
		var debug:(v:Dynamic) -> Void;
		var info:(v:Dynamic) -> Void;
	}
	var dialog:api.dialog.Dialog;
	var updateClientState:(props:ItemState) -> Void;
}

abstract RichString(String) to String {
	public inline function new(v)
		this = v;

	public inline function toString():String
		return this;

	public inline function bold()
		return new RichString('{b:$this}');

	public inline function italic()
		return new RichString('{i:$this}');

	public inline function underline()
		return new RichString('{u:${this}}');

	public inline function size(size:Float)
		return new RichString('{size.$size:$this}');

	public inline function color(color:String)
		return new RichString('{color.$color:$this}');
}
