import {
    IdeckiaCore, ItemState, ActionDescriptor, ActionOutcome, ActionStatus, ActionStatusCode
} from "./core";

import { LocalizedTexts } from "./data";

export interface IdeckiaAction {
    props: any;
    core?: IdeckiaCore;
    localizedTexts?: LocalizedTexts;

    /**
     *  Method called to inject the properties and core access.
     *
     *  @param props: Properties defined for the instance in the layout file
     *  @param core: Object to access to some tools that ideckia_core @see <https://github.com/ideckia/ideckia_api/blob/main/api/IdeckiaApi.hx#L126-L135>
     */
    setup(props: any, core: IdeckiaCore): void;

    /**
     *  Method called when the action is loaded
     *
     *  @param initialState: The initial ItemState of the item @see <https://github.com/ideckia/ideckia_api/blob/main/api/IdeckiaApi.hx#L74-L85>
     *  @return A Promise with the new state of the item
     */
    init(initialState: ItemState): Promise<ItemState>;

    /**
     *  Method called when the item is clicked in the client
     *
     *  @param currentState: The current ItemState of the item @see <https://github.com/ideckia/ideckia_api/blob/main/api/IdeckiaApi.hx#L74-L85>
     *  @return A Promise with the outcome given by the action. It can be a new state or a new directory @see <https://github.com/ideckia/ideckia_api/blob/main/api/IdeckiaApi.hx#L34-L37>
     */
    execute(currentState: ItemState): Promise<ActionOutcome>;

    /**
     *  Method called when the item is long pressed in the client
     *
     *  @param currentState: The current ItemState of the item @see <https://github.com/ideckia/ideckia_api/blob/main/api/IdeckiaApi.hx#L74-L85>
     *  @return A Promise with the outcome given by the action. It can be a new state or a new directory @see <https://github.com/ideckia/ideckia_api/blob/main/api/IdeckiaApi.hx#L34-L37>
     */
    onLongPress(currentState: ItemState): Promise<ActionOutcome>;

    /**
     * Method called from the editor to show if the action has any problems
     */
    getStatus(): Promise<ActionStatus>;

    /**
     * Method called when the state that belongs this action shows up
     */
    show(currentState: ItemState): Promise<ItemState>;

    /**
     * Method called when the state that belongs this action goes out of sight
     */
    hide(): void;

    getActionDescriptor(): Promise<ActionDescriptor>;
}