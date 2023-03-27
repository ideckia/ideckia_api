package api;

typedef IdeckiaAction = api.action.IdeckiaAction;

// Client messages
enum abstract ClientMsgType(String) {
	var click;
	var longPress;
	var gotoDir;
}

enum abstract Caller(String) {
	var client;
	var editor;
}

typedef ClientMsg = {
	var type:ClientMsgType;
	var whoami:Caller;
	var ?itemId:UInt;
	var ?toDir:String;
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

typedef TActionOutcome = {
	var ?state:ItemState;
	var ?directory:DynamicDir;
}

typedef DynamicDir = {
	var ?rows:UInt;
	var ?columns:UInt;
	var items:Array<DynamicDirItem>;
}

typedef DynamicDirItem = {
	> ItemState,
	var ?toDir:String;
	var ?actions:Array<{
		var name:String;
		var ?props:Any;
	}>;
}

@:forward
abstract ActionOutcome(TActionOutcome) from TActionOutcome to TActionOutcome {
	public inline function new(v)
		this = v;

	@:from static function fromAny(v:Any) {
		if (Reflect.hasField(v, 'state') || Reflect.hasField(v, 'dynamicDir')) {
			return new ActionOutcome(v);
		} else if (Reflect.hasField(v, 'text') || Reflect.hasField(v, 'icon') || Reflect.hasField(v, 'bgColor')) {
			return {state: v};
		}
		throw new haxe.Exception('Cannot parse this object to ActionOutcome: $v');
	}
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
	var ?extraData:{
		fromAction:String,
		data:Any
	};
}

typedef ClientLayout = {
	var rows:UInt;
	var columns:UInt;
	var icons:haxe.DynamicAccess<String>;
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
	var dialog:api.dialog.IDialog;
	var mediaPlayer:api.media.IMediaPlayer;
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
