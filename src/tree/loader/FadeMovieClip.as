package tree.loader {
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;

public class FadeMovieClip extends MovieClip{

	private var movie:MovieClip;

	public function FadeMovieClip(movie:MovieClip) {
		this.movie = movie;
		addChild(movie);
		addEventListener(Event.ENTER_FRAME, onTick);
	}

	override public function gotoAndStop(frame:Object, scene:String = null):void {
		movie.gotoAndStop(int(frame));
	}

	override public function get totalFrames():int {
		return movie.totalFrames;
	}

	public function clear():void{
		removeEventListener(Event.ENTER_FRAME, onTick);
	}

	private function  onTick(event:Event):void{

	}
}
}
