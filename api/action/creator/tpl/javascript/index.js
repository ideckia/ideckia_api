/**
 * [Find here the action structure]{@link https://github.com/ideckia/ideckia_api/blob/develop/README.md#action-structure}
 */
class ::className:: {

    /**
     * Method called to inject the properties and server access
     */
    setup(props, server) {
        this.props = props == null ? {} : props;
        this.server = server;
    }

    /**
     * Method called when the action is loaded
     */
    init(initialState) {
        return new Promise((resolve, reject) => {
            resolve(initialState);
        });
    }

    /**
     * Method called when the item is clicked in the client
     */
    execute(currentState) {
        throw 'Not implemented';
        // return new Promise((resolve, reject) => {
        // 		resolve({state: currentState});
        // });
    }

    /**
     * Method called when the item is long pressed in the client
     */
    onLongPress(currentState) {
        return new Promise((resolve, reject) => {
            resolve({ state: currentState });
        });
    }

    /**
     * Method called from the editor to show if the action has any problems
     */
    getStatus() {
        return new Promise((resolve, reject) => {
            resolve({ code: 'ok' });
        });
    }

    /**
     * Method called when the state that belongs this action shows up
     */
    show(currentState) {
        return new Promise((resolve, reject) => {
            resolve(initialState);
        });
    }

    /**
     * Method called when the state that belongs this action goes out of sight
     */
    hide() {
    }

    /**
     * Method called from the editor to create an UI to configure the action
     */
    getActionDescriptor() {
        return {
            name: "::name::",
            description: "::description::",
            // props : [{
            // 	name : "property_name",
            // 	type : "String",
            // 	isShared : false,
            //	defaultValue: "default value",
            // 	description : "property description",
            // 	values : ["possible", "values", "for the property"]
            // }]
        };
    }
}

exports.IdeckiaAction = ::className::;