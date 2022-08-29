package api.media;

interface IMediaPlayer {
	/**
		Play the media from the give path

		@param path The path of the file to be played.
		@param loop Repeat the file in loop
		@param onEnd A callback function to be called when the media ends (will be called every time when loop=true)
		@return The identifier of the playing sound
	**/
	function play(path:String, loop:Bool = false, ?onEnd:Void->Void):Int;

	/**
		Pauses the media

		@param id The identifier of the sound to be paused
	**/
	function pause(id:Int):Void;

	/**
		Stop the media

		@param id The identifier of the sound to be stopped
	**/
	function stop(id:Int):Void;
}
