package api;

typedef IdeckiaAction = api.action.IdeckiaAction;

// Client messages
enum abstract ClientMsgType(String) {
	var click;
	var longPress;
	var getEditorData;
	var getServerItem;
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
	var serverItem;
}

typedef ServerMsg<T> = {
	var type:ServerMsgType;
	var data:T;
}

typedef ItemState = {
	var ?text:String;
	var ?textSize:UInt;
	var ?textColor:String;
	var ?icon:String;
	var ?bgColor:String;
}

typedef ClientLayout = {
	var rows:UInt;
	var columns:UInt;
	var items:Array<{
		> ItemState, var id:UInt;
	}>;
}

typedef PropDescriptor = {
	var name:String;
	var defaultValue:String;
	var type:String;
	var ?description:String;
	var ?values:Array<String>;
}

typedef ActionDescriptor = {
	var ?id:UInt;
	var name:String;
	var ?description:String;
	var ?props:Array<PropDescriptor>;
}

#if macro
typedef Promise<T> = Dynamic<T>;
#else
typedef Promise<T> = js.lib.Promise<T>;
#end

enum abstract DialogType(String) {
	var Info = 'info';
	var Error = 'error';
	var Question = 'question';
	var Entry = 'entry';
	var FileSelect = 'fileselect';
}

typedef IdeckiaServer = {
	var log:{
		var error:(v:Dynamic) -> Void;
		var debug:(v:Dynamic) -> Void;
		var info:(v:Dynamic) -> Void;
	}
	var dialog:{
		var info:(text:String) -> Promise<String>;
		var error:(text:String) -> Promise<String>;
		var question:(text:String) -> Promise<String>;
		var entry:(text:String) -> Promise<String>;
		var fileselect:(text:String) -> Promise<String>;
	}
	var updateClientState:(props:ItemState) -> Void;
}
