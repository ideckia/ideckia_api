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

enum abstract Endpoint(String) to String {
	var editorEndpoint = '/editor';
	var pingEndpoint = '/ping';
	var newTranslationEndpoint = '/translation/new';
	var newActionEndpoint = '/action/new';
	var actionTemplatesEndpoint = '/action/templates';
	var layoutAppendEndpoint = '/layout/append';
	var directoryExportEndpoint = '/directory/export';

	public static inline function actionDescriptorForId(id:UInt)
		return 'action/${id}/descriptor';

	public static inline function stateActionsForId(id:UInt)
		return 'state/${id}/actions/status';
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
	var ?bgColor:String;
	var items:Array<DynamicDirItem>;
}

typedef DynamicDirItem = {
	> ItemState,
	var ?toDir:String;
	var ?actions:Array<{
		var name:String;
		var ?status:ActionStatus;
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
		?fromAction:String,
		data:Any
	};
}

typedef ClientLayout = {
	var rows:UInt;
	var columns:UInt;
	var ?bgColor:String;
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
	var ?value:String;
	var ?isShared:Bool;
	var ?sharedName:String;
	var ?description:String;
	var ?values:Array<String>;
}

typedef PresetAction = {
	var name:String;
	var props:Any;
}

enum abstract ActionStatusCode(String) from String {
	var unknown;
	var error;
	var ok;
}

typedef ActionStatus = {
	var code:ActionStatusCode;
	var ?message:String;
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
	var getCurrentLang:() -> String;
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

typedef TransString = {
	var id:String;
	var text:String;
	var ?comment:String;
}

typedef TransLang = Map<String, Array<TransString>>;

@:forward
abstract Translations(TransLang) to TransLang from TransLang {
	public inline function new(v)
		this = v;

	public function getLang(langId:String)
		return this.get(langId);

	public function t(langId:String, stringId:String, ?args:Array<Dynamic>) {
		var lang = this.get(langId);
		if (lang == null)
			return stringId;
		for (s in lang) {
			if (s.id == stringId) {
				if (args == null)
					return s.text;
				var text = s.text;
				for (index => value in args) {
					if (!StringTools.contains(text, '{$index}'))
						continue;
					text = StringTools.replace(text, '{$index}', value);
				}
				return text;
			}
		}
		return stringId;
	}

	public function merge(newTranslations:Translations) {
		for (lang => strings in newTranslations)
			this.set(lang, strings);
	}
}
