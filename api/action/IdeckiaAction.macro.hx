package api.action;

import haxe.macro.Compiler;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Printer;
import haxe.macro.Type;
import haxe.macro.TypeTools;

using StringTools;
using api.IdeckiaApi;

class IdeckiaAction {
	static inline var EXPOSE_NAME = 'IdeckiaAction';
	static inline var EDITABLE_METADATA = ':editable';
	static inline var SHARED_METADATA = ':shared';
	static inline var EDITABLE_DESCRIPTION_IDX = 0;
	static inline var EDITABLE_DEFAULT_VALUE_IDX = 1;
	static inline var EDITABLE_POSSIBLE_VALUES_IDX = 2;

	static public function build() {
		var fields:Array<Field> = Context.getBuildFields();

		var localType:Type = Context.getLocalType();
		var actionName:String = "";
		var actionDescription:String = "";
		switch localType {
			case TInst(t, params):
				var classType:ClassType = t.get();

				for (metadata in classType.meta.get())
					if (metadata.name == ":name")
						switch metadata.params[0].expr {
							case EConst(CString(s, kind)):
								actionName = s;
							default:
						};
					else if (metadata.name == ":description")
						switch metadata.params[0].expr {
							case EConst(CString(s, kind)):
								actionDescription = s;
							default:
						};

				// Add :expose('IdeckiaAction') metadata to be available from Javascript under
				// the name defined in 'IdeckiaAction'
				classType.meta.add(':expose', [macro $v{EXPOSE_NAME}], Context.currentPos());

			default:
		}

		if (actionName == '')
			Context.fatalError('Please define @:name("action-name") metadata in the class.', Context.currentPos());

		var moduleName:String = Context.getLocalModule();
		var moduleTypes:Array<Type> = Context.getModule(moduleName);
		var defaultExprMap:Map<String, Expr> = [];

		for (moduleType in moduleTypes) {
			switch moduleType {
				case TType(t, params):
					var type = t.get();
					if (type.name == 'Props') {
						var propDescriptors:Array<PropDescriptor> = [];
						switch type.type {
							case TAnonymous(a):
								var anonType:AnonType = a.get();

								var propDescriptor:PropDescriptor;
								var propDescription;
								var propPossibleValues;
								var defaultValue:Any;
								var isShared:Bool;
								var propType;
								var defaultExpr:Expr;
								for (classField in anonType.fields) {
									propDescription = null;
									propPossibleValues = null;
									defaultValue = null;
									isShared = false;
									propType = null;

									var metas:haxe.macro.Metadata = classField.meta.get();
									for (meta in metas) {
										// Look for the editor parameter metadata
										if (meta.name == EDITABLE_METADATA) {
											propDescription = extractDescription(meta);
											defaultExpr = extractDefaultValueExpr(meta);
											if (defaultExpr != null) {
												defaultExprMap.set(classField.name, defaultExpr);
												defaultValue = ExprTools.toString(defaultExpr);
											} else {
												defaultValue = null;
											}
											propPossibleValues = extractPossibleValues(meta);
										} else if (meta.name == SHARED_METADATA) {
											isShared = true;
										}
									}

									classField.meta.add(':optional', [], Context.currentPos());

									// Get the property type
									propType = TypeTools.toString(classField.type);

									// Create the descriptor and add it to the array
									propDescriptors.push({
										name: classField.name,
										defaultValue: defaultValue,
										isShared: isShared,
										type: propType,
										description: propDescription,
										values: propPossibleValues
									});
								}

								// Generate getActionDescriptor method
								var actionDescriptor:ActionDescriptor = {
									name: actionName,
									description: actionDescription,
									props: propDescriptors
								};
								createMarkdown(actionName, propDescriptors);
								fields.push(createGetActionDescriptorFunction(actionDescriptor));
							default:
						}

						// Create 'var props:Props' class property
						fields.push({
							name: 'props',
							kind: FVar(macro:Props),
							pos: Context.currentPos()
						});

						// Create default assigments if needed
						var assignDefaults = [];
						for (pd in propDescriptors) {
							var propName = pd.name;
							var defValue = pd.defaultValue;
							// trace('$propName -> $defValue');
							if (defValue != null && defValue != 'null') {
								/*
									Example:
									if (this.props.delay_ms == null) {
										this.props.delay_ms = 1000;
									}
								 */
								assignDefaults.push(macro @:pos(Context.currentPos()) {
									if (this.props.$propName == null)
										this.props.$propName = ${defaultExprMap.get(propName)};
								});
							}
						}

						/* Create
								function setup(props:Props, server:IdeckiaServer) {
									this.props = props;
									// default assignments
									this.server = server;
								}
							}
						 */
						fields.push({
							name: 'setup',
							kind: FFun({
								args: [
									{
										name: 'props',
										type: macro:Any
									},
									{
										name: 'server',
										opt: true,
										type: macro:IdeckiaServer
									}
								],
								expr: macro {
									this.props = (props == null) ? {} : props;
									$b{assignDefaults};
									this.server = server;
								}
							}),
							access: [APublic],
							pos: Context.currentPos()
						});
					}
				default:
			}
		}
		return fields;
	}

	/*
	 * Get description to show in the editor
	 */
	static function extractDescription(meta:MetadataEntry) {
		var param = meta.params[EDITABLE_DESCRIPTION_IDX];
		var description = "";
		if (param != null) {
			description = switch param.expr {
				case EConst(CString(s, kind)):
					s;
				default:
					"";
			}
		}

		return description;
	}

	/*
	 * Get the default expression for the property
	 */
	static function extractDefaultValueExpr(meta:MetadataEntry) {
		var param = meta.params[EDITABLE_DEFAULT_VALUE_IDX];
		return param == null ? null : param;
	}

	/*
	 * Get the posible values of the property to show in the editor
	 */
	static function extractPossibleValues(meta:MetadataEntry) {
		var param = meta.params[EDITABLE_POSSIBLE_VALUES_IDX];
		var possibleValues = null;
		if (param != null) {
			possibleValues = [];
			switch param.expr {
				case EArrayDecl(values):
					for (v in values) {
						switch v.expr {
							case EConst(c):
								switch c {
									case CInt(v):
										possibleValues.push(v);
									case CFloat(f):
										possibleValues.push(f);
									case CString(s, kind):
										possibleValues.push(s);
									default:
								}
							default:
						}
					}
				default:
			}
		}

		return possibleValues;
	}

	static function createGetActionDescriptorFunction(actionDescriptor:ActionDescriptor):Field {
		return {
			name: 'getActionDescriptor',
			doc: 'Method that returns action properties descriptor (name, type, isShared, description, values).',
			access: [APublic, AInline],
			kind: FFun({
				args: [],
				ret: macro:ActionDescriptor,
				expr: macro return $v{actionDescriptor}
			}),
			pos: Context.currentPos()
		};
	}

	static function createMarkdown(actionName:String, propDescriptors:Array<PropDescriptor>) {
		var table = createMarkdownPropsTable(propDescriptors);
		var sample = createMarkdownSample(actionName, propDescriptors);
		sys.io.File.saveContent('./gen.readme.md', table + '\n' + sample);
	}

	static function createMarkdownPropsTable(propDescriptors:Array<PropDescriptor>) {
		var table = '| Name | Type | Description | Shared | Default | Possible values |\n';
		table += '| ----- |----- | ----- | ----- | ----- | ----- |\n';

		for (prop in propDescriptors) {
			table += '| ${prop.name}';
			table += ' | ${prop.type.replace('<', '&lt;').replace('>', '&gt;')}';
			table += ' | ${prop.description}';
			table += ' | ${prop.isShared}';
			table += ' | ${prop.defaultValue}';
			table += ' | ${prop.values} |\n';
		}

		return table;
	}

	static function createMarkdownSample(actionName:String, propDescriptors:Array<PropDescriptor>) {
		var sample = '```json\n';
		sample += '{\n';
		sample += '    "state": {\n';
		sample += '        "text": "${actionName} action example",\n';
		sample += '        "actions": [\n';
		sample += '            {\n';
		sample += '                "name": "${actionName}",\n';
		sample += '                "props": {\n';
		var props = propDescriptors.map(p -> '                    "${p.name}": ${p.defaultValue}');
		sample += props.join(',\n');
		sample += '\n';

		sample += '                }\n';
		sample += '            }\n';
		sample += '        ]\n';
		sample += '    }\n';
		sample += '}\n';
		sample += '```';

		return sample;
	}
}
