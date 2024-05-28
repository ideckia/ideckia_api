package api;

typedef IdeckiaAction = api.action.IdeckiaAction;
#if !editor
typedef Data = api.data.Data;
#end

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
	var actionDescriptorsEndpoint = '/action/descriptors';
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

// Core messages
enum abstract CoreMsgType(String) {
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

typedef CoreMsg<T> = {
	var type:CoreMsgType;
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

typedef IdeckiaCore = {
	var log:{
		var error:(v:Dynamic) -> Void;
		var debug:(v:Dynamic) -> Void;
		var info:(v:Dynamic) -> Void;
	}
	var dialog:api.dialog.IDialog;
	var mediaPlayer:api.media.IMediaPlayer;
	var updateClientState:(props:ItemState) -> Void;
	var data:{
		var getCurrentLang:() -> String;
		var getContent:(path:String) -> String;
		var getJson:(path:String) -> Dynamic;
		var getTranslations:(path:String) -> Translations;
		var getBytes:(path:String) -> haxe.io.Bytes;
		var getBase64:(path:String) -> String;
	}
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

@:keep
class Translations {
	var translang:TransLang;

	public function new(v)
		translang = v;

	public function tr(langId:String, stringId:String, ?args:Array<Dynamic>) {
		var lang = translang.get(langId);
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
		for (lang => strings in @:privateAccess newTranslations.translang)
			translang.set(lang, strings);
	}

	public function exists(langId:String)
		return translang.exists(langId);

	public function get(langId:String)
		return translang.get(langId);

	public function keys()
		return translang.keys();
}

#if !core
typedef Translate = api.data.Translate;

macro function tr(textIdExpr:ExprOf<String>, ?argsExpr:ExprOf<Array<Dynamic>>) {
	var definedTranslationsPath = haxe.macro.Context.definedValue('translationsPath');
	var translationsDir = (definedTranslationsPath == null) ? 'lang' : definedTranslationsPath;
	var idFound, text;

	final textId = haxe.macro.ExprTools.getValue(textIdExpr);
	final argsLength = (argsExpr == null) ? 0 : switch argsExpr.expr {
		case EArrayDecl(arr):
			arr.length;
		default: 0;
	}

	for (langFile in sys.FileSystem.readDirectory(translationsDir)) {
		var transContent:Array<TransString> = haxe.Json.parse(sys.io.File.getContent(translationsDir + '/$langFile'));

		idFound = false;
		for (t in transContent) {
			if (textId == t.id) {
				idFound = true;
				text = t.text;

				for (i in 0...argsLength) {
					if (!StringTools.contains(text, '{$i}'))
						haxe.macro.Context.error('No placeholder [{$i}] found in the text [id=$textId] from the translation file [$langFile].',
							haxe.macro.Context.currentPos());
				}
				if (StringTools.contains(text, '{${argsLength}}'))
					haxe.macro.Context.error('Found more placeholders than arguments in the text [id=$textId] from the translation file [$langFile].',
						haxe.macro.Context.currentPos());
			}
		}
		if (!idFound)
			haxe.macro.Context.error('No text [id=$textId] found in the translation file [$langFile].', haxe.macro.Context.currentPos());
	}

	return macro translations.tr(core.data.getCurrentLang(), $textIdExpr, $argsExpr);
}
#end
