package api.action;

import haxe.macro.PositionTools;
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
		var translationDir:String = "";
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
					else if (metadata.name == ":translate")
						translationDir = metadata.params.length == 0 ? 'lang' : switch metadata.params[0].expr {
							case EConst(CString(s, kind)):
								s;
							default:
								'lang';
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
		var propDescriptors:Array<PropDescriptor> = [];
		var assignDefaults = [];
		var propsType = macro :Any;

		for (moduleType in moduleTypes) {
			switch moduleType {
				case TType(t, params):
					var type = t.get();
					if (type.name == 'Props') {
						propsType = macro :Props;
						switch type.type {
							case TAnonymous(a):
								var anonType:AnonType = a.get();

								var propDescriptor:PropDescriptor,
									propDescription,
									propPossibleValues,
									defaultValue:Any,
									isShared:Bool,
									sharedName:String,
									isEditable:Bool,
									propType,
									defaultExpr:Expr,
									metas:haxe.macro.Metadata;
								anonType.fields.sort((field1, field2) -> {
									var fieldLine1 = PositionTools.toLocation(field1.pos).range.start.line;
									var fieldLine2 = PositionTools.toLocation(field2.pos).range.start.line;
									return fieldLine1 - fieldLine2;
								});
								for (classField in anonType.fields) {
									propDescription = null;
									propPossibleValues = null;
									defaultValue = null;
									isShared = false;
									sharedName = '';
									propType = null;

									metas = classField.meta.get();
									isEditable = false;
									for (meta in metas) {
										// Look for the editor parameter metadata
										if (meta.name == EDITABLE_METADATA) {
											isEditable = true;
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
											sharedName = extractSharedName(meta);
										}
									}

									classField.meta.add(':optional', [], Context.currentPos());

									// Only @:editable and @:shared props goes in the descriptor
									if (isEditable || isShared) {
										// Get the property type
										propType = TypeTools.toString(classField.type);

										// Create the descriptor and add it to the array
										propDescriptors.push({
											name: classField.name,
											defaultValue: defaultValue,
											isShared: isShared,
											sharedName: sharedName,
											type: propType,
											description: propDescription,
											values: propPossibleValues
										});
									}
								}

								createMarkdown(actionName, propDescriptors);
							default:
						}

						// Create default assigments if needed
						for (pd in propDescriptors) {
							var propName = pd.name;
							var defValue = pd.defaultValue;
							var possibleValues = pd.values;
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
								/*
									Example: If the value is not one of the possibles, assign the default value
									if (![0, 10, 100, 1000].contains(this.props.delay_ms)) {
										this.props.delay_ms = 1000;
									}
								 */
								if (possibleValues != null) {
									assignDefaults.push(macro @:pos(Context.currentPos()) {
										if (!$v{possibleValues}.contains(this.props.$propName))
											this.props.$propName = ${defaultExprMap.get(propName)};
									});
								}
							}
						}
					}
				default:
			}
		}

		// Create 'var props:Props' or 'var props:Any' (if 'typedef Props' is not defined) class property
		fields.push({
			name: 'props',
			kind: FVar(propsType),
			pos: Context.currentPos()
		});

		var setupField = null;
		var getActionDescExists = false;
		for (field in fields) {
			switch field.name {
				case 'setup':
					setupField = field;
				case 'getActionDescriptor':
					getActionDescExists = true;
			}
		}

		if (setupField == null) {
			setupField = createSetup(assignDefaults);
			fields.push(setupField);
		}

		if (translationDir != '') {
			fields.push({
				name: 'translations',
				kind: FVar(macro :api.IdeckiaApi.Translations),
				pos: Context.currentPos()
			});
			switch setupField.kind {
				case FFun(f):
					switch f.expr.expr {
						case EBlock(exprs):
							exprs.push(macro translations = api.data.Data.getTranslations(haxe.io.Path.join([js.Node.__dirname, $v{translationDir}])));
						default:
					}
				default:
			}
		}

		// Generate _getActionDescriptor method
		var exprPropDescriptors:Array<ExprOf<PropDescriptor>> = propDescriptors.map(pd -> macro {
			name: $v{pd.name},
			defaultValue: $v{pd.defaultValue},
			isShared: $v{pd.isShared},
			sharedName: $v{pd.sharedName},
			type: $v{pd.type},
			description: translations.tr(core.data.getCurrentLang(), $v{pd.description}),
			values: $v{pd.values}
		});
		fields.push(createPrivateGetActionDescriptorFunction(macro {
			name: $v{actionName},
			description: translations.tr(core.data.getCurrentLang(), $v{actionDescription}),
			props: $a{exprPropDescriptors}
		}));
		if (!getActionDescExists)
			// Generate getActionDescriptor method
			fields.push(createGetActionDescriptorFunction());
		return fields;
	}

	/**
		Create
			function setup(props:Props, core:IdeckiaCore) {
				this.props = props;
				// default assignments
				this.core = core;
			}
	**/
	static function createSetup(assignDefaults:Array<Expr>):Field {
		return {
			name: 'setup',
			kind: FFun({
				args: [
					{
						name: 'props',
						type: macro :Any
					},
					{
						name: 'core',
						type: macro :IdeckiaCore
					}
				],
				expr: macro {
					this.props = (props == null) ? {} : props;
					$b{assignDefaults};
					this.core = core;
				}
			}),
			access: [APublic],
			pos: Context.currentPos()
		};
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
	 * Get the shared property name
	 */
	static function extractSharedName(meta:MetadataEntry) {
		var param = meta.params[0];
		var name = "";
		if (param != null) {
			name = switch param.expr {
				case EConst(CString(s, kind)):
					s;
				default:
					"";
			}
		}

		return name;
	}

	/*
	 * Get the default expression for the property
	 */
	static function extractDefaultValueExpr(meta:MetadataEntry) {
		return meta.params[EDITABLE_DEFAULT_VALUE_IDX];
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

	static function createPrivateGetActionDescriptorFunction(actionDescriptor:ExprOf<ActionDescriptor>):Field {
		return {
			name: '_getActionDescriptor',
			doc: 'Private method to get action properties descriptor (it can be used if getActionDescriptor is overwritten).',
			access: [],
			kind: FFun({
				args: [],
				ret: macro :ActionDescriptor,
				expr: macro return ${actionDescriptor}
			}),
			pos: Context.currentPos()
		};
	}

	static function createGetActionDescriptorFunction():Field {
		return {
			name: 'getActionDescriptor',
			doc: 'Method that returns action properties descriptor (name, type, isShared, description, values).',
			access: [APublic, AInline],
			kind: FFun({
				args: [],
				ret: macro :js.lib.Promise<ActionDescriptor>,
				expr: macro return js.lib.Promise.resolve(_getActionDescriptor())
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
			table += ' | ${api.data.Translate.tr(prop.description)}';
			table += ' | ${prop.isShared}';
			table += ' | ${prop.defaultValue}';
			table += ' | ${prop.values} |\n';
		}

		return table;
	}

	static function createMarkdownSample(actionName:String, propDescriptors:Array<PropDescriptor>) {
		var sample = '```json\n';
		sample += '{\n';
		sample += '    "text": "${actionName} action example",\n';
		sample += '    "actions": [\n';
		sample += '        {\n';
		sample += '            "name": "${actionName}",\n';
		sample += '            "props": {\n';
		var props = propDescriptors.map(p -> '                "${p.name}": ${p.defaultValue}');
		sample += props.join(',\n');
		sample += '\n';

		sample += '            }\n';
		sample += '        }\n';
		sample += '    ]\n';
		sample += '}\n';
		sample += '```';

		return sample;
	}
}
