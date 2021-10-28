package api.action;

using api.IdeckiaApi;

@:keep
@:autoBuild(api.action.IdeckiaAction.build())
abstract class IdeckiaAction {
	var server:IdeckiaServer;

	abstract public function setup(props:Any, ?server:IdeckiaServer):Void;

	public function init(initialState:ItemState):js.lib.Promise<ItemState>
		return new js.lib.Promise((resolve, reject) -> resolve(initialState));

	abstract public function execute(currentState:ItemState):js.lib.Promise<ItemState>;

	public function onLongPress(currentState:ItemState):js.lib.Promise<ItemState>
		return new js.lib.Promise((resolve, reject) -> resolve(currentState));

	abstract public function toJson():Any;

	abstract public function getActionDescriptor():ActionDescriptor;
}
