import { IdeckiaAction } from "./api/action";
import {
    ActionStatusCode, IdeckiaCore, ItemState, ActionDescriptor, ActionOutcome, ActionStatus
} from "./api/core";
import { LocalizedTexts } from "./api/data";
import * as path from "path";

class ::className:: implements IdeckiaAction {
    props: any;
    core?: IdeckiaCore = undefined;
    localizedTexts?: LocalizedTexts = undefined;

    setup(props: any, core: IdeckiaCore) {
        this.props = props == null ? {} : props;
        this.core = core;
        this.localizedTexts = core.data.getLocalizations(path.join(__dirname, 'loc'));
    }

    init(initialState: ItemState): Promise<ItemState> {
        return Promise.resolve(initialState);
    }

    execute(currentState: ItemState): Promise<ActionOutcome> {
        this.core.dialog.error('Errorea', this.localizedTexts.tr(this.core.data.getCurrentLocale(), "not_implemented"));
        return Promise.resolve({ state: currentState });
    }

    onLongPress(currentState: ItemState): Promise<ActionOutcome> {
        return Promise.resolve({ state: currentState });
    }

    getStatus(): Promise<ActionStatus> {
        return Promise.resolve({ code: ActionStatusCode.ok });
    }

    show(currentState: ItemState): Promise<ItemState> {
        return Promise.resolve(currentState);
    }

    hide(): void {
    }

    getActionDescriptor(): Promise<ActionDescriptor> {
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

exports.IdeckiaAction = ::className::;