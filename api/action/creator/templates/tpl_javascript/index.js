const path = require('path');

/**
 * [Find here the action structure]{@link https://github.com/ideckia/ideckia_api/blob/main/README.md#action-structure}
 */
class ::className:: {

    /**
     * Method called to inject the properties and core access
     */
    setup(props, core) {
        this.props = props == null ? {} : props;
        this.core = core;
        this.localizedTexts = core.data.getLocalizations(path.join(__dirname, 'loc'));
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
     *  Method called when the action is unloaded
     */
    deinit() {
    }

    /**
     * Method called when the item is clicked in the client
     */
    execute(currentState) {
        return new Promise((resolve, reject) => {
            reject(this.localizedTexts.tr(this.core.data.getCurrentLocale(), "not_implemented"));
        });
        // return new Promise((resolve, reject) => {
        //     resolve({state: currentState});
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
            resolve(currentState);
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
        return new Promise((resolve, reject) => {
            resolve({
                name: "::name::",
                description: this.localizedTexts.tr(this.core.data.getCurrentLocale(), "action_description"),
                // props : [{
                // 	name : "property_name",
                // 	type : "text",
                // 	isShared : false,
                // 	sharedName : "shared_property_name",
                //	defaultValue: "default value",
                // 	description : "property description",
                // 	values : ["possible", "values", "for the property"]
                // }]
            });
        });
    }
}

exports.IdeckiaAction = ::className:: ;