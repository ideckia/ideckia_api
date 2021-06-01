package api;

typedef IdeckiaAction = api.action.IdeckiaAction;

// Client messages
enum abstract ClientMsgType(String) {
	var click;
	var getActions;
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
	var actionDescriptors;
	var serverItem;
}

typedef ServerMsg<T> = {
	var type:ServerMsgType;
	var data:T;
}

typedef ItemState = {
	var ?text:String;
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
	var ?props:Array<PropDescriptor>;
}

#if macro
typedef Promise<T> = Dynamic<T>;
#else
typedef Promise<T> = js.lib.Promise<T>;
#end

enum abstract DialogType(String) {
	var info;
	var error;
	var question;
	var entry;
}

typedef IdeckiaServer = {
	var log:(v:Dynamic) -> Void;
	var dialog:(type:DialogType, text:String) -> Promise<String>;
	var sendToClient:(props:ItemState) -> Void;
}
