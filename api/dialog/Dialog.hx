package api.dialog;

import api.dialog.DialogTypes;

interface Dialog {
	/**
		Set options for the dialogs. If the parameters is missing, options will be set to default

		@param options Any option to send. Send null to reset options
	**/
	function setOptions(options:Any):Void;

	/**
		Shows notification

		@param title The title of the notification.
		@param text The text of the notification.
	**/
	function notify(title:String, text:String):Void;

	/**
		Shows information window

		@param title The title of the window
		@param text The information text.
	**/
	function info(title:String, text:String):Void;

	/**
		Shows information window

		@param title The title of the window
		@param text The error text.
	**/
	function error(title:String, text:String):Void;

	/**
		Shows YES/NO question window

		@param title The title of the window
		@param text The text of the question
		@returns A promise with value true if OK is clicked, false otherwise.
	**/
	function question(title:String, text:String):api.IdeckiaApi.Promise<Bool>;

	/**
		Select one or multiple file or directories

		@param title The title of the window
		@param isDirectory Do you want to select a directory instead of a file?
		@param multiple Allow multiple selection
		@param fileFilter Filter to show files
		@returns A promise with selected files paths
	**/
	function selectFile(title:String, isDirectory:Bool = false, multiple:Bool = false, ?fileFilter:FileFilter):api.IdeckiaApi.Promise<Array<String>>;

	/**
		Open a dialog to save file

		@param title The title of the window
		@param saveName Optional name for saving
		@param fileFilter Filter to show files
		@returns A promise with selected files paths
	**/
	function saveFile(title:String, ?saveName:String, ?fileFilter:FileFilter):api.IdeckiaApi.Promise<String>;

	/**
		Open a dialog to get user input text

		@param title The title of the window
		@param text The text of the window
		@param placeholder The input text placeholder.
		@returns A promise with the entered text
	**/
	function entry(title:String, text:String, ?placeholder:String):api.IdeckiaApi.Promise<String>;

	/**
		Open a dialog to get user input password

		@param title The title of the window
		@param text The text of the window
		@param showUsername Display the username field
		@returns A promise with the an array containing username (if required) and password
	**/
	function password(title:String, text:String, showUsername:Bool = false):api.IdeckiaApi.Promise<Array<String>>;

	/**
		Create and show a progress dialog

		@param title The title of the window
		@param text The text of the window
		@param pulsate Pulsate progress bar
		@param autoClose Close automatically when finished
		@returns A Progress instance
	**/
	function progress(title:String, text:String, pulsate:Bool = false, autoClose:Bool = true):Progress;

	/**
		Open a color selection dialog

		@param title The title of the window
		@param initialColor The initial selected color.
		@param palette Show palette
		@returns A promise with the selected color
	**/
	function color(title:String, initialColor:String = "#FFFFFF", palette:Bool = false):api.IdeckiaApi.Promise<Color>;

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
	function calendar(title:String, text:String, ?year:UInt, ?month:UInt, ?day:UInt, ?dateFormat:String):api.IdeckiaApi.Promise<String>;

	/**
		Shows a list dialog

		@param title The title of the window
		@param text The text of the window
		@param multiple Allow multiple selection
		@param columnHeader Set the column header.
		@param values Values to list.
		@returns A promise with the selected items
	**/
	function list(title:String, text:String, columnHeader:String, values:Array<String>, multiple:Bool = false):api.IdeckiaApi.Promise<Array<String>>;
}

interface Progress {
	function progress(percentage:UInt):Void;
}
