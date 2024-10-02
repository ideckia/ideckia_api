export interface MediaPlayer {

    /**
    Play the media from the give path
    
    @param path The path of the file to be played.
    @param loop Repeat the file in loop
    @param onEnd A callback function to be called when the media ends (will be called every time when loop=true)
    @return The identifier of the playing sound
    */
    play(path: string, loop?: boolean, onEnd?: null | (() => void)): number

    /**
    Pauses the media
    
    @param id The identifier of the sound to be paused
    */
    pause(id: number): void

    /**
    Resumes the media if paused
    
    @param id The identifier of the sound to be paused
    */
    resume(id: number): void

    /**
    Stop the media
    
    @param id The identifier of the sound to be stopped
    */
    stop(id: number): void
}
