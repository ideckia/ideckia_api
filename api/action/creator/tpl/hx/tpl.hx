package;

using api.IdeckiaApi;

typedef Props = {
	@:editable("Property description", "default value", ["possible", "values", "for the property"])
	var property_name:String;
}

@:name("::name::")
@:description("::description::")
class ::className:: extends IdeckiaAction {
	override public function init(initialState:ItemState):js.lib.Promise<ItemState>
		return super.init(initialState);

	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		// return new js.lib.Promise((resolve, reject) -> resolve(currentState));
		throw new haxe.exceptions.NotImplementedException();
	}
    
    override public function onLongPress(currentState:ItemState):js.lib.Promise<ItemState>
		return super.onLongPress(currentState);

	// AUTOGENERATED
	/*
		var props:Props;
		var server:IdeckiaServer;

		public function setup(props:Props, server:IdeckiaServer) {
			this.props = props;
			this.server = server;
		}

		public function getActionDescriptor():ActionDescriptor {
			return {
				name : "::name::",
				description : "::description::",
				props : [{
					name : "property_name",
					defaultValue: "default value",
					description : "property description",
					values : ["possible", "values", "for the property"]
				}]
			};
		}
	 */
}
