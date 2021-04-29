class ::name:: {
	
	setProps(props, initialState,server) {
		this.props = props;
		this.state = initialState;
		this.server = server;
	}
	
	init() {
	}
	
	execute() {
		throw 'Not implemented';
		// return state;
	}
	
	toJson() {
		return { name : "::lowerName::", props : this.props};
	}
	
	getActionDescriptor() {
		return {
			name : "::name::",
			// props : [{
			// 	name : "propertyName",
			//	defaultValue: "default value",
			// 	description : "property description",
			// 	values : ["possible", "values", "for the property"]
			// }]
		};
	}
}

exports['IdeckiaAction'] = ::name::;