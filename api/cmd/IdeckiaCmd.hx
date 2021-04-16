package api.cmd;

using api.IdeckiaCmdApi;

@:keep
@:autoBuild(api.cmd.IdeckiaCmd.build())
abstract class IdeckiaCmd {

    var state:ItemState;
    var server:IdeckiaServer;
    
    abstract public function setProps(props:Any, ?initialState:ItemState, ?server:IdeckiaServer):Void;

    public function init():Void {}

    abstract public function execute():ItemState;

    abstract public function toJson():Any;

    abstract public function getCmdDescriptor():CmdDescriptor;
}