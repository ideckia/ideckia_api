package;

using api.IdeckiaApi;

typedef Props = {
	@:editable("property description", "default value", ["possible", "values", "for the property"])
	var propertyName:String;
}

class ::name:: extends IdeckiaAction {
	override public function init() {}

	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		// return return new js.lib.Promise((resolve, reject) -> resolve(currentState));
		throw new haxe.exceptions.NotImplementedException();
	}

	// AUTOGENERATED
	/*
		var props:Props;
		var server:IdeckiaServer;

		public function setProps(props:Props, server:IdeckiaServer) {
			this.props = props;
			this.server = server;
		}

		public function toJson():Any {
			return { name : "::lowerName::", props : this.props};
		}

		public function getActionDescriptor():ActionDescriptor {
			return {
				name : "::name::",
				props : [{
					name : "propertyName",
					defaultValue: "default value",
					description : "property description",
					values : ["possible", "values", "for the property"]
				}]
			};
		}
	 */
}
