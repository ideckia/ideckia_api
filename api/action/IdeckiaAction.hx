package api.action;

using api.IdeckiaActionApi;

@:keep
@:autoBuild(api.action.IdeckiaAction.build())
abstract class IdeckiaAction {
	var state:ItemState;
	var server:IdeckiaServer;

	abstract public function setProps(props:Any, ?initialState:ItemState, ?server:IdeckiaServer):Void;

	public function init():Void {}

	abstract public function execute():ItemState;

	abstract public function toJson():Any;

	abstract public function getActionDescriptor():ActionDescriptor;
}
