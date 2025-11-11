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
	var clientEndpoint = '/client';
	var editorEndpoint = '/editor';
	var configurationEndpoint = '/configuration';
	var aboutEndpoint = '/about';
	var quitEndpoint = '/quit';
	var pingEndpoint = '/ping';
	var newLocalizationEndpoint = '/localization/new';
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
	var ?possibleValues:Array<String>;
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

enum abstract PropEditorFieldType(String) from String to String {
	var text;
	var number;
	var password;
	var boolean;
	var path;
	var icon;
	var object;
	var listOf;

	public static function fromTypeName(fieldName:String, fieldType:String):String {
		final editorFieldTypes = [text, number, password, boolean, path, icon, object];
		if (fieldType != null && (editorFieldTypes.contains(fieldType) || StringTools.startsWith(fieldType, listOf)))
			return fieldType;

		if (StringTools.startsWith(fieldType, 'Null<'))
			fieldType = StringTools.replace(fieldType.substring(0, fieldType.length - 1), 'Null<', '');
		return switch fieldType {
			case 'Int' | 'UInt' | 'Float': PropEditorFieldType.number;
			case 'Bool': PropEditorFieldType.boolean;
			case 'String':
				if (StringTools.contains(fieldName, 'password') || StringTools.contains(fieldName, 'pwd')) {
					PropEditorFieldType.password;
				} else if (StringTools.contains(fieldName, 'path')) {
					PropEditorFieldType.path;
				} else {
					PropEditorFieldType.text;
				};
			case x:
				if (StringTools.startsWith(fieldType, '{')) {
					PropEditorFieldType.object;
				} else if (StringTools.contains(x, 'Array<')) {
					var itemType = StringTools.replace(x, 'Array<', '');
					itemType = StringTools.replace(itemType, '>', '');
					PropEditorFieldType.listOf + '<${PropEditorFieldType.fromTypeName(fieldName, itemType)}>';
				} else x;
		}
	}
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
		var getCurrentLocale:() -> String;
		var getContent:(path:String) -> String;
		var getJson:(path:String) -> Dynamic;
		var getLocalizations:(path:String) -> LocalizedTexts;
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

typedef LocString = {
	var id:String;
	var text:String;
	var ?comment:String;
}

typedef LocalesMap = Map<String, Array<LocString>>;

@:keep
class LocalizedTexts {
	var localesMap:LocalesMap;

	public function new(v:LocalesMap = null)
		localesMap = v;

	public function tr(localeId:String, stringId:String, ?args:Array<Dynamic>) {
		if (localesMap == null || !localesMap.exists(localeId.toLowerCase()))
			return stringId;

		var locale = localesMap.get(localeId.toLowerCase());
		for (s in locale) {
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

	public function merge(other:LocalizedTexts) {
		for (locale => strings in @:privateAccess other.localesMap)
			localesMap.set(locale, strings);
	}

	public function exists(localeId:String)
		return localesMap.exists(localeId.toLowerCase());

	public function get(localeId:String)
		return localesMap.get(localeId.toLowerCase());

	public function keys()
		return localesMap.keys();
}

#if !core
typedef Loc = api.data.Loc;

macro function tr(textIdExpr:ExprOf<String>, ?argsExpr:ExprOf<Array<Dynamic>>) {
	var definedLocalizationsPath = haxe.macro.Context.definedValue('localizationsPath');
	var localizationsDir = (definedLocalizationsPath == null) ? 'loc' : definedLocalizationsPath;
	var idFound, text;

	final textId = haxe.macro.ExprTools.getValue(textIdExpr);
	final argsLength = (argsExpr == null) ? 0 : switch argsExpr.expr {
		case EArrayDecl(arr): arr.length;
		case EConst(CIdent(ident)) if (ident == 'null'): 0;
		case EConst(_):
			argsExpr.expr = EArrayDecl([
				{
					expr: argsExpr.expr,
					pos: haxe.macro.Context.currentPos()
				}
			]);
			1;
		default: 0;
	}

	for (locFile in sys.FileSystem.readDirectory(localizationsDir)) {
		var locContent:Array<LocString> = haxe.Json.parse(sys.io.File.getContent(localizationsDir + '/$locFile'));

		idFound = false;
		for (t in locContent) {
			if (textId == t.id) {
				idFound = true;
				text = t.text;

				for (i in 0...argsLength) {
					if (!StringTools.contains(text, '{$i}'))
						haxe.macro.Context.error('No placeholder [{$i}] found in the text [id=$textId] from the file [$locFile].',
							haxe.macro.Context.currentPos());
				}
				if (StringTools.contains(text, '{${argsLength}}'))
					haxe.macro.Context.error('Found more placeholders than arguments in the text [id=$textId] from the file [$locFile].',
						haxe.macro.Context.currentPos());
			}
		}
		if (!idFound)
			haxe.macro.Context.error('No text [id=$textId] found in the file [$locFile].', haxe.macro.Context.currentPos());
	}

	return macro localizedTexts.tr(core.data.getCurrentLocale(), $textIdExpr, $argsExpr);
}
#end
