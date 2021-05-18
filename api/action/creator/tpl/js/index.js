class ::name:: {
	
	setProps(props, server) {
		this.props = props;
		this.server = server;
	}
	
	init() {
	}
	
	execute(currentState) {
		throw 'Not implemented';
		// return new Promise((resolve, reject) => {
		// 		resolve(currentState);
		// });
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