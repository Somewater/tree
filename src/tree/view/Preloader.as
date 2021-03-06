package tree.view {
import flash.display.MovieClip;
import flash.display.Sprite;

import tree.common.Config;
import tree.loader.FadeMovieClip;

public class Preloader extends Sprite{
		private var _progress:Number = NaN;
		private var _width:int;
		private var _height:int;

		private var movie:MovieClip;

		public function Preloader() {
			movie = Config.loader.createMc('assets.TreeLoaderAnimationFade');
			addChild(movie);
		}

		public function set progress(progress:Number):void {
			if(_progress != progress)
			{
				_progress = progress;
				refresh();
			}
		}

		public function setSize(w:int, h:int):void
		{
			_width = w;
			_height = h;
			movie.x = (Config.WIDTH - movie.width) * 0.5;
			movie.y = (Config.HEIGHT - movie.height) * 0.5;
			refresh();
		}

		private function refresh():void {
			graphics.clear();
			graphics.beginFill(0x00FF00, 0.2);
			graphics.drawRect(0,0,_width,_height);
//
//			graphics.beginFill(0x008800, 0.8);
//			graphics.drawRect(_width * 0.5 - 100, _height * 0.5 - 10, 200, 20);
//
//			graphics.beginFill(0xFF0000);
//			graphics.drawRect(_width * 0.5 - 100 + 3, _height * 0.5 - 10 + 3, (200 - 6) * (isNaN(_progress) ? 1 : _progress), 20 - 6);
			movie.gotoAndStop(int(movie.totalFrames * Math.min(isNaN(_progress) ? 0 : _progress, 0.999)) + 1)
		}
	}
}
