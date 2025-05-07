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
	static inline var EDITABLE_FIELD_TYPE_IDX = 3;

	static var abstractTypeValues:Map<String, Map<String, TConstant>> = [];

	static public function build() {
		var fields:Array<Field> = Context.getBuildFields();

		var localType:Type = Context.getLocalType();
		var actionName:String = "";
		var actionDescription:String = "";
		var localizationDir:String = "";
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
					else if (metadata.name == ":localize")
						localizationDir = metadata.params.length == 0 ? 'loc' : switch metadata.params[0].expr {
							case EConst(CString(s, kind)):
								s;
							default:
								'loc';
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
		var propPossibleValuesExprMap:Map<String, Expr> = [];

		for (moduleType in moduleTypes) {
			switch moduleType {
				case TType(t, params):
					var type = t.get();
					if (type.name == 'Props') {
						propsType = macro :Props;
						switch type.type {
							case TAnonymous(a):
								var anonType:AnonType = a.get();

								var propDescriptor:PropDescriptor, propDescription, propPossibleValues, propPossibleValuesExpr, defaultValue:Any,
									isShared:Bool, sharedName:String, isEditable:Bool, propRealType, propEditorType, metas:haxe.macro.Metadata;
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
									propRealType = null;
									propEditorType = null;
									sharedName = '';

									metas = classField.meta.get();
									isEditable = false;
									for (meta in metas) {
										// Look for the editor parameter metadata
										if (meta.name == EDITABLE_METADATA) {
											isEditable = true;
											// Get the property type
											propRealType = PropEditorFieldType.fromTypeName(classField.name, TypeTools.toString(classField.type));
											propEditorType = extractFieldTypeExpr(meta);
											if (propEditorType == null)
												propEditorType = propRealType;
											propDescription = extractDescription(meta);
											var extractedDefaultValue = extractDefaultValue(meta, propRealType);
											if (extractedDefaultValue.expr != null) {
												defaultExprMap.set(classField.name, extractedDefaultValue.expr);
												defaultValue = extractedDefaultValue.string;
											} else {
												defaultValue = null;
											}
											var extractedPossibleValues = extractPossibleValues(meta, propRealType);
											propPossibleValues = extractedPossibleValues.strings;
											propPossibleValuesExprMap.set(classField.name, extractedPossibleValues.expr);
										} else if (meta.name == SHARED_METADATA) {
											isShared = true;
											sharedName = extractSharedName(meta);
										}
									}

									classField.meta.add(':optional', [], Context.currentPos());

									// Only @:editable and @:shared props goes in the descriptor
									if (isEditable || isShared) {
										// Create the descriptor and add it to the array
										propDescriptors.push({
											name: classField.name,
											defaultValue: defaultValue,
											isShared: isShared,
											sharedName: sharedName,
											type: propEditorType,
											description: propDescription,
											possibleValues: propPossibleValues
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
							var possibleValues = pd.possibleValues;
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
								if (possibleValues != null && possibleValues.length > 0) {
									assignDefaults.push(macro @:pos(Context.currentPos()) {
										if (!${propPossibleValuesExprMap.get(propName)}.contains(this.props.$propName))
											this.props.$propName = ${defaultExprMap.get(propName)};
									});
								}
							}
						}
					}
				case TAbstract(_.get() => ab, _):
					abstractTypeValues.set(ab.name, getAbstractValues(ab));

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

		fields.push({
			name: 'localizedTexts',
			kind: FVar(macro :api.IdeckiaApi.LocalizedTexts, macro new api.IdeckiaApi.LocalizedTexts()),
			pos: Context.currentPos()
		});
		if (localizationDir != '') {
			switch setupField.kind {
				case FFun(f):
					switch f.expr.expr {
						case EBlock(exprs):
							exprs.push(macro localizedTexts = api.data.Data.getLocalizations(haxe.io.Path.join([js.Node.__dirname, $v{localizationDir}])));
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
			description: localizedTexts.tr(core.data.getCurrentLocale(), $v{pd.description}),
			possibleValues: $v{pd.possibleValues}
		});
		fields.push(createPrivateGetActionDescriptorFunction(macro {
			name: $v{actionName},
			description: localizedTexts.tr(core.data.getCurrentLocale(), $v{actionDescription}),
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
	static function extractDefaultValue(meta:MetadataEntry, propRealType:String) {
		var param = meta.params[EDITABLE_DEFAULT_VALUE_IDX];
		var expr = macro null;
		var string = null;
		if (param != null) {
			switch param.expr {
				case EConst(CIdent(i)):
					if (i != 'null') {
						expr = param;
						string = getCIndentStringValue(propRealType, i);
					}
				default:
					expr = param;
					string = ExprTools.toString(expr);
			};
		}

		return {expr: expr, string: string};
	}

	/*
	 * Get the posible values of the property to show in the editor
	 */
	static function extractPossibleValues(meta:MetadataEntry, propRealType:String) {
		var param = meta.params[EDITABLE_POSSIBLE_VALUES_IDX];
		var expr = macro null;
		var strings = [];
		if (param != null) {
			switch param.expr {
				case EArrayDecl(values):
					expr = param;
					for (v in values) {
						switch v.expr {
							case EConst(c):
								switch c {
									case CInt(v) | CFloat(v) | CString(v, _):
										strings.push(v);
									case CIdent(i) if (i != 'null'):
										strings.push(getCIndentStringValue(propRealType, i));
									default:
								}
							default:
						}
					}
				default:
			}
		}

		return {expr: expr, strings: strings};
	}

	/*
	 * Get the editor field type (text, password or path) expression for the property
	 */
	static function extractFieldTypeExpr(meta:MetadataEntry) {
		var param = meta.params[EDITABLE_FIELD_TYPE_IDX];
		if (param == null)
			return null;

		return switch param.expr {
			case EConst(CString(s, _)): s;
			case EField(_, field): field;
			default: 'text';
		}
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
			doc: 'Method that returns action properties descriptor (name, type, isShared, description, possibleValues).',
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
			table += ' | ${api.data.Loc.tr(prop.description)}';
			table += ' | ${prop.isShared}';
			table += ' | ${prop.defaultValue}';
			table += ' | ${prop.possibleValues} |\n';
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

	static function getCIndentStringValue(propRealType:String, name:String) {
		if (abstractTypeValues == null || !abstractTypeValues.exists(propRealType))
			return null;

		return switch abstractTypeValues.get(propRealType).get(name) {
			case TInt(i):
				'$i';
			case TFloat(s):
				s;
			case TString(s):
				'"$s"';
			default:
				null;
		};
	}

	static function getAbstractValues(ab:AbstractType) {
		var values:Map<String, TConstant> = [];
		for (field in ab.impl.get().statics.get()) {
			if (field.meta.has(":enum") && field.meta.has(":impl")) {
				if (field.expr() != null)
					switch field.expr().expr {
						case TCast(e, _):
							switch e.expr {
								case TConst(t):
									values.set(field.name, t);
								default:
							}
						default:
					}
			}
		}

		return values;
	}
}
