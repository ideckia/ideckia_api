package;

using api.IdeckiaCmdApi;

typedef Props = {
    @:editable("property description", "default value", ["possible", "values", "for the property"])
    var propertyName:String;
}

class ::name:: extends IdeckiaCmd {

	override public function init() {
	}

    public function execute():ItemState {
        throw new haxe.exceptions.NotImplementedException();
    }
	
    // AUTOGENERATED
    /*
    var state:ItemState;
    var server:IdeckiaServer;
    var props:Props;
    
	public function setProps(props:Props, initialState:ItemState, server:IdeckiaServer) {
		this.props = props;
		this.state = initialState;
		this.server = server;
	}
    
	public function toJson():Any {
		return { name : "::lowerName::", props : this.props};
	}
	
	public function getCmdDescriptor():CmdDescriptor {
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