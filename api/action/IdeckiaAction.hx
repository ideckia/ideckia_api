package api.action;

using api.IdeckiaApi;

@:keep
@:autoBuild(api.action.IdeckiaAction.build())
abstract class IdeckiaAction {
	var server:IdeckiaServer;

	abstract public function setProps(props:Any, ?server:IdeckiaServer):Void;

	public function init():Void {}

	abstract public function execute(currentState:ItemState):js.lib.Promise<ItemState>;

	abstract public function toJson():Any;

	abstract public function getActionDescriptor():ActionDescriptor;
}
