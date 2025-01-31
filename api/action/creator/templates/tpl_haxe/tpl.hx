package;

using api.IdeckiaApi;

typedef Props = {
	@:editable("prop_property_name", "default value", ["possible", "values", "for the property"], PropEditorFieldType.text)
	var property_name:String;
}

@:name("::name::")
@:description("action_description")
@:localize("loc")
class ::className:: extends IdeckiaAction {
	override public function init(initialState:ItemState):js.lib.Promise<ItemState>
		return super.init(initialState);

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
        return js.lib.Promise.reject(Loc.not_implemented.tr());
        // return js.lib.Promise.resolve(new ActionOutcome({state: currentState}));
	}

	override public function onLongPress(currentState:ItemState):js.lib.Promise<ActionOutcome>
		return super.onLongPress(currentState);

	override public function getStatus():js.lib.Promise<ActionStatus>
		return super.getStatus();

	override public function show(currentState:ItemState):js.lib.Promise<ItemState>
		return super.show(currentState);

	override public function hide():Void {}

	// AUTOGENERATED
	/*
		var props:Props;
		var core:IdeckiaCore;

		public function setup(props:Any, ?core:IdeckiaCore) {
			this.props = props;
			this.core = core;
		}

		public function getActionDescriptor():js.lib.Promise<ActionDescriptor> {
			return js.lib.Promise.resolve({
				name : "::name::",
				description : Loc.action_description.tr(),
				props : [{
					name : "property_name",
					defaultValue: "default value",
					type: "text",
					value: "possible",
					isShared: false,
					sharedName : "shared_property_name",
					description : Loc.prop_property_name.tr(),
					values : ["possible", "values", "for the property"]
				}]
			}));
		}
	 */
}
