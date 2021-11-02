# ideckia_api

This is the API for the actions used by [ideckia](https://github.com/ideckia/ideckia_server).

## Concepts

* Layout: Bunch of items
* Item: An element that has one or more states and is clickable.
* State: Definition of the item status: text, textColor, bgColor, icon and a action which will be executed when the item is pressed.

## Action structure

* setup(props, server):Void
  * Needs to be implemented, autogenerated with macros in haxe.
  * Server will call to this method to inject the configuration of the action instance
  * Parameters:
    * props: Properties defined for the instance in the layout file
    * server: Object to access to some tools that ideckia_server offers:
      * log: Logs in the server process:
        * error(text:String): Logs in ERROR level
        * debug(text:String): Logs in DEBUG level
        * info(text:String): Logs in INFO level
      * dialogs: Access to some host dialogs. All of them return a Promise of the clicked button or the input of the user (only in 'entry' type)
        * info(text:String):Promise<String>
          * Informative notification
        * error(text:String):Promise<String>
          * Error notification
        * question(text:String):Promise<String>
          * Ok/Cancel type notification
        * entry(text:String):Promise<String>
          * User input dialog
      * updateClientState: a function to send to the client the state of the item.
* init():Void
  * Entry point.
  * The server will call to this once, to initialize what you need
* execute(currentState:ItemState):Promise<ItemState>
  * Needs to be implemented.
  * The server will call when the associated item is clicked.
  * Parameters:
    * The actual state of the item when it is clicked.
  * The function will return the Promise of a new state of the item. Most of times we will return the input parameter as is.
* onLongPress(currentState:ItemState):Promise<ItemState>
  * The server will call when the associated item is long pressed.
  * Parameters:
    * The actual state of the item when it is long pressed.
  * The function will return the Promise of a new state of the item. Most of times we will return the input parameter as is.
* toJson:Any (Used by the editor)
  * Needs to be implemented, autogenerated with macros in haxe.
  * This will return the JSON to write to the layout file in the server side
* getActionDescriptor():ActionDescriptor  (Used by the editor)
  * Needs to be implemented, autogenerated with macros in haxe.
  * This will return action descriptor structure which will be used by an editor
