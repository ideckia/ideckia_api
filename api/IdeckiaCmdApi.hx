package api;

typedef IdeckiaCmd = api.cmd.IdeckiaCmd;

// Client messages
enum abstract ClientMsgType(String) {
    var click;
    var getCommands;
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
    var commandDescriptors;
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
        >ItemState,
        var id:UInt;
    }>;
}

typedef PropDescriptor = {
    var name:String;
    var defaultValue:String;
    var type:String;
    var ?description:String;
    var ?values:Array<String>;
}

typedef CmdDescriptor = {
    var ?id:UInt;
    var name:String;
    var ?props:Array<PropDescriptor>;
}

typedef IdeckiaServer = {
    var log:{
        var debug:(v:Dynamic) -> Void;
        var info:(v:Dynamic) -> Void;
        var warn:(v:Dynamic) -> Void;
        var error:(v:Dynamic) -> Void;
    }
    var sendToClient:(props:ItemState) -> Void;
    var props:(key:String) -> String;
}