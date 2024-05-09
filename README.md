# ideckia_api

This is the API for the actions used by [ideckia](https://github.com/ideckia/ideckia_core).

## Concepts

* Layout: Bunch of _items_
* Item: An element that has one or more _states_ and is clickable.
* State: Definition of the item status: text, textColor, bgColor, icon and some _actions_ which will be executed when the item is pressed.
* Action: Action which will be fired (can be more than one in a state) in the host computer when the item is pressed in the client.

## Action structure

* setup(props, core):Void
  * Needs to be implemented, autogenerated with macros in haxe.
  * Core will call to this method to inject the configuration of the action instance
  * Parameters:
    * props: Properties defined for the instance in the layout file
    * core: Object to access to some tools that ideckia_core offers:
      * log: Logs in the core process:
        * error(text:String): Logs in ERROR level
        * debug(text:String): Logs in DEBUG level
        * info(text:String): Logs in INFO level
      * dialogs: Access to host dialogs. The dialog property is an implementation of [IDialog](/api/dialog/IDialog.hx)
      * mediaPlayer: Access to host media player. The mediaPlayer property is an implementation of [IMediaPlayer](/api/media/IMediaPlayer.hx)
      * updateClientState: a function to send to the client the state of the item.
      * getCurrentLang: a function to get the language configured for the app.
* init(initialState:ItemState):Promise<ItemState>
  * Entry point.
  * The core will call to this once, to initialize what you need.
* execute(currentState:ItemState):Promise<ActionOutcome>
  * Needs to be implemented.
  * The core will call when the associated item is clicked. 
  * Parameters:
    * The actual state of the item when it is clicked.
  * The function will return the Promise of a new state of the item or a directory items. See [TActionOutcome](/api/IdeckiaApi.hx#L34-L37)
* onLongPress(currentState:ItemState):Promise<ActionOutcome>
  * The core will call when the associated item is long pressed. 
  * Parameters:
    * The actual state of the item when it is long pressed.
  * The function will return the Promise of a new state of the item or a directory items. See [TActionOutcome](/api/IdeckiaApi.hx#L34-L37)
* getStatus():Void
  * Method called from the editor to show if the action has any problems.
* show(currentState:ItemState):Promise<ItemState>
  * Method called when the state that belongs this action shows up.
* hide():Void
  * Method called when the state that belongs this action goes out of sight.
* getActionDescriptor():Promise<ActionDescriptor>  (Used by the editor)
  * Needs to be implemented, autogenerated with macros in haxe.
  * This will return action descriptor structure which will be used by an editor

## RichString

The returned text can have different size, color and style (bold, italic, underline) parts. The format is `{transformer:text to transform}`. The _transformer_ can be:

* `b`: The `text to transform` will be **bold**
* `i`: The `text to transform` will be _italic_
* `u`: The `text to transform` will be underlined
* `color.colorName`: The `text to transform` will be rendered in `colorName` color.
* `size.fontSize`: The `text to transform` will be rendered in `fontSize` size.

The changes can be chained. For example:

```javascript
The text is {b:{i:{u:bold, italic and underlined}}}. And this text will be {color.red:{size.50:colored with red and BIG}}
```