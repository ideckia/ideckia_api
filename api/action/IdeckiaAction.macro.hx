package api.action;

import haxe.macro.ExprTools;

using api.IdeckiaApi;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Printer;
import haxe.macro.TypeTools;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class IdeckiaAction {
	static inline var EXPOSE_NAME = 'IdeckiaAction';
	static inline var EDITABLE_METADATA = ':editable';
	static inline var EDITABLE_DESCRIPTION_IDX = 0;
	static inline var EDITABLE_DEFAULT_VALUE_IDX = 1;
	static inline var EDITABLE_POSSIBLE_VALUES_IDX = 2;

	static public function build() {
		var fields:Array<Field> = Context.getBuildFields();

		var localType:Type = Context.getLocalType();
		var className:String = "";
		switch localType {
			case TInst(t, params):
				var classType:ClassType = t.get();
				className = classType.name;

				// Add :expose('IdeckiaAction') metadata to be available from Javascript under
				// the name defined in 'IdeckiaAction'
				classType.meta.add(':expose', [macro $v{EXPOSE_NAME}], Context.currentPos());
				// Generate toJson method
				fields.push(createToJsonFunction(className));

			default:
		}

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
								var actionDescriptor:ActionDescriptor = {name: className};

								var propDescriptor:PropDescriptor;
								var description;
								var propPossibleValues;
								var defaultValue:Any;
								var propType;
								var defaultExpr:Expr;
								for (classField in anonType.fields) {
									description = null;
									propPossibleValues = null;
									defaultValue = null;
									propType = null;

									var metas:haxe.macro.Metadata = classField.meta.get();
									for (meta in metas) {
										// Look for the editor parameter metadata
										if (meta.name == EDITABLE_METADATA) {
											description = extractDescription(meta);
											defaultExpr = extractDefaultValueExpr(meta);
											if (defaultExpr != null) {
												defaultExprMap.set(classField.name, defaultExpr);
												defaultValue = ExprTools.toString(defaultExpr);
											} else {
												defaultValue = null;
											}
											propPossibleValues = extractPossibleValues(meta);
										}
									}

									classField.meta.add(':optional', [], Context.currentPos());

									// Get the property type
									propType = TypeTools.toString(classField.type);

									// Create the descriptor and add it to the array
									propDescriptors.push({
										name: classField.name,
										defaultValue: defaultValue,
										type: propType,
										description: description,
										values: propPossibleValues
									});
								}

								// Generate getActionDescriptor method
								actionDescriptor.props = propDescriptors;
								createMarkdownPropsTable(actionDescriptor);
								fields.push(createGetActionDescriptorFunction(className, actionDescriptor));
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
								function setProps(props:Props, server:IdeckiaServer) {
									this.props = props;
									// default assignments
									this.server = server;
								}
							}
						 */
						fields.push({
							name: 'setProps',
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

	static function createToJsonFunction(className:String):Field {
		return {
			name: 'toJson',
			doc: 'Method that returns this action Json representation to put it in the ideckia layout.',
			access: [APublic, AInline],
			kind: FFun({
				args: [],
				ret: macro:Any,
				expr: macro return {
					name: $v{className.toLowerCase()},
					props: props
				}
			}),
			pos: Context.currentPos()
		};
	}

	static function createGetActionDescriptorFunction(className:String, actionDescriptor:ActionDescriptor):Field {
		return {
			name: 'getActionDescriptor',
			doc: 'Method that returns action properties descriptor (name, description, values).',
			access: [APublic, AInline],
			kind: FFun({
				args: [],
				ret: macro:ActionDescriptor,
				expr: macro return $v{actionDescriptor}
			}),
			pos: Context.currentPos()
		};
	}

	static function createMarkdownPropsTable(actionDescriptor:ActionDescriptor) {
		var table = '| Name | Type | Default | Description | Possible values |\n';
		table += '| ----- |----- | ----- | ----- | ----- |\n';

		for (prop in actionDescriptor.props) {
			table += '| ${prop.name}';
			table += ' | ${prop.type}';
			table += ' | ${prop.defaultValue}';
			table += ' | ${prop.description}';
			table += ' | ${prop.values} |\n';
		}

		sys.io.File.saveContent('./props_table.md', table);
	}
}
