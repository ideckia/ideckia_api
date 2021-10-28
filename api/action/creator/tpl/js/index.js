class ::className:: {

    setup(props, server) {
        this.props = props == null ? {} : props;
        this.server = server;
    }

    init(initialState) {
        return new Promise((resolve, reject) => {
            resolve(initialState);
        });
    }

    execute(currentState) {
        throw 'Not implemented';
        // return new Promise((resolve, reject) => {
        // 		resolve(currentState);
        // });
    }

    onLongPress(currentState) {
        return new Promise((resolve, reject) => {
            resolve(currentState);
        });
    }

    toJson() {
        return { name: "::name::", props: this.props };
    }

    getActionDescriptor() {
        return {
            name: "::name::",
            description: "::description::",
            // props : [{
            // 	name : "propertyName",
            //	defaultValue: "default value",
            // 	description : "property description",
            // 	values : ["possible", "values", "for the property"]
            // }]
        };
    }
}

exports.IdeckiaAction = ::className::;