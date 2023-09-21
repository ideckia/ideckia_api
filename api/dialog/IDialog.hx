package api.dialog;

import api.dialog.DialogTypes;
import api.IdeckiaApi.Promise;
import haxe.ds.Option;

@:autoBuild(api.macros.Macros.addExposeMetadata('Dialog'))
interface IDialog {
	/**
		Set default options for the dialogs.

		@param options Any option to send.
	**/
	function setDefaultOptions(options:WindowOptions):Void;

	/**
		Shows notification

		@param title The title of the notification.
		@param text The text of the notification.
	**/
	function notify(title:String, text:String, ?options:WindowOptions):Void;

	/**
		Shows information window

		@param title The title of the window
		@param text The information text.
	**/
	function info(title:String, text:String, ?options:WindowOptions):Void;

	/**
		Shows warning window

		@param title The title of the window
		@param text The warning text.
	**/
	function warning(title:String, text:String, ?options:WindowOptions):Void;

	/**
		Shows error window

		@param title The title of the window
		@param text The error text.
	**/
	function error(title:String, text:String, ?options:WindowOptions):Void;

	/**
		Shows YES/NO question window

		@param title The title of the window
		@param text The text of the question
		@returns A promise with value true if OK is clicked, false otherwise.
	**/
	function question(title:String, text:String, ?options:WindowOptions):Promise<Bool>;

	/**
		Select one or multiple file or directories

		@param title The title of the window
		@param isDirectory Do you want to select a directory instead of a file?
		@param openDirectory Open the dialog in an directory
		@param multiple Allow multiple selection
		@param fileFilter Filter to show files
		@returns A promise with selected files paths
	**/
	function selectFile(title:String, isDirectory:Bool = false, ?openDirectory:String, multiple:Bool = false, ?fileFilter:FileFilter,
		?options:WindowOptions):Promise<Option<Array<String>>>;

	/**
		Open a dialog to save file

		@param title The title of the window
		@param saveName Optional name for saving
		@param openDirectory Open the dialog in an directory
		@param fileFilter Filter to show files
		@returns A promise with selected files paths
	**/
	function saveFile(title:String, ?saveName:String, ?openDirectory:String, ?fileFilter:FileFilter, ?options:WindowOptions):Promise<Option<String>>;

	/**
		Open a dialog to get user input text

		@param title The title of the window
		@param text The text of the window
		@param placeholder The input text placeholder.
		@returns A promise with the entered text
	**/
	function entry(title:String, text:String, ?placeholder:String, ?options:WindowOptions):Promise<Option<String>>;

	/**
		Open a dialog to get user input password

		@param title The title of the window
		@param text The text of the window
		@param showUsername Display the username field
		@returns A promise with the an object containing username (if required) and password
	**/
	function password(title:String, text:String, showUsername:Bool = false, ?options:WindowOptions):Promise<Option<{username:String, password:String}>>;

	/**
		Create and show a progress dialog

		@param title The title of the window
		@param text The text of the window
		@param autoClose Close automatically when finished
		@returns A Progress instance
	**/
	function progress(title:String, text:String, autoClose:Bool = true, ?options:WindowOptions):Progress;

	/**
		Open a color selection dialog

		@param title The title of the window
		@param initialColor The initial selected color.
		@returns A promise with the selected color
	**/
	function color(title:String, initialColor:String = "#FFFFFF", ?options:WindowOptions):Promise<Option<Color>>;

	/**
		Open a dialog to get user input text

		@param title The title of the window
		@param text The text of the window
		@param year Set the calendar year
		@param mont Set the calendar mont
		@param day Set the calendar day
		@param dateFormat Set the format for the returned date. The default depends on the user locale or be set with the strftime style. For example %A %d/%m/%y 
		@returns A promise with the entered date
	**/
	function calendar(title:String, text:String, ?year:UInt, ?month:UInt, ?day:UInt, ?dateFormat:String, ?options:WindowOptions):Promise<Option<String>>;

	/**
		Shows a list dialog

		@param title The title of the window
		@param text The text of the window
		@param multiple Allow multiple selection
		@param columnHeader Set the column header.
		@param values Values to list.
		@returns A promise with the selected items
	**/
	function list(title:String, text:String, columnHeader:String, values:Array<String>, multiple:Bool = false,
		?options:WindowOptions):Promise<Option<Array<String>>>;

	/**
		Custom dialog. Passing a path to the dialog definition file the implementation will render it. When closed, it will return an array with filled values.

		@param definitionPath The path of the definition file of the dialog
		@returns A promise for an array with {id:String, value:Any}. Being `id` the identifier of the field and `value` the value of that field
	**/
	function custom(definitionPath:String):Promise<Option<Array<IdValue<String>>>>;
}

interface Progress {
	function progress(percentage:UInt):Void;
}
