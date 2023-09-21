package api.action;

using api.IdeckiaApi;

@:keep
@:autoBuild(api.action.IdeckiaAction.build())
abstract class IdeckiaAction {
	var server:IdeckiaServer;

	/**
	 *  Method called to inject the properties and server access.
	 *
	 *  @param props: Properties defined for the instance in the layout file
	 *  @param server: Object to access to some tools that ideckia_server @see <https://github.com/ideckia/ideckia_api/blob/develop/api/IdeckiaApi.hx#L126-L135>
	 */
	abstract public function setup(props:Any, server:IdeckiaServer):Void;

	/**
	 *  Method called when the action is loaded
	 *
	 *  @param initialState: The initial ItemState of the item @see <https://github.com/ideckia/ideckia_api/blob/develop/api/IdeckiaApi.hx#L74-L85>
	 *  @return A Promise with the new state of the item
	 */
	public function init(initialState:ItemState):js.lib.Promise<ItemState>
		return new js.lib.Promise((resolve, reject) -> resolve(initialState));

	/**
	 *  Method called when the item is clicked in the client
	 *
	 *  @param currentState: The current ItemState of the item @see <https://github.com/ideckia/ideckia_api/blob/develop/api/IdeckiaApi.hx#L74-L85>
	 *  @return A Promise with the outcome given by the action. It can be a new state or a new directory @see <https://github.com/ideckia/ideckia_api/blob/develop/api/IdeckiaApi.hx#L34-L37>
	 */
	abstract public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome>;

	/**
	 *  Method called when the item is long pressed in the client
	 *
	 *  @param currentState: The current ItemState of the item @see <https://github.com/ideckia/ideckia_api/blob/develop/api/IdeckiaApi.hx#L74-L85>
	 *  @return A Promise with the outcome given by the action. It can be a new state or a new directory @see <https://github.com/ideckia/ideckia_api/blob/develop/api/IdeckiaApi.hx#L34-L37>
	 */
	public function onLongPress(currentState:ItemState):js.lib.Promise<ActionOutcome>
		return js.lib.Promise.resolve(new ActionOutcome({state: currentState}));

	/**
	 * Method called from the editor to show if the action has any problems
	 */
	public function getStatus():js.lib.Promise<ActionStatus>
		return js.lib.Promise.resolve({code: ActionStatusCode.ok});

	/**
	 * Method called when the state that belongs this action shows up
	 */
	public function show(currentState:ItemState):js.lib.Promise<ItemState>
		return js.lib.Promise.resolve(currentState);

	/**
	 * Method called when the state that belongs this action goes out of sight
	 */
	public function hide():Void {}

	abstract public function getActionDescriptor():ActionDescriptor;
}
