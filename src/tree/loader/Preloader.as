package tree.loader {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;

import preloader.LeafPreloaderAnimation;

public class Preloader extends MovieClip{

		public var loaderName:String = 'TreeLoader';
		//private var textField:TextField;
		//private var progressbar:Shape;
		private var movie:MovieClip;

		public function Preloader() {
			if(stage)
				onStage();
			else
				addEventListener(Event.ADDED_TO_STAGE, onStage);
		}


		private function onStage(event:Event = null):void
		{
			if(event)
				removeEventListener(event.type, onStage);

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

/*			progressbar = new Shape();
			addChild(progressbar);

			textField = new TextField();
			addChild(textField);
			textField.x = (stage.stageWidth - textField.width) * 0.5;
			textField.y = stage.stageHeight * 0.5;
			textField.selectable = false;
			textField.defaultTextFormat.align = 'center';
			textField.defaultTextFormat.color = 0x799919;
			textField.defaultTextFormat.size = 15;
			textField.setTextFormat(new TextFormat(null, 15, 0x799919, null, null, null, null, null, 'center'))
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.filters = [new DropShadowFilter(1, 90, 0, 0.6, 3, 3)];
			textField.text = '0%';

			progressbar.x = textField.x + textField.width * 0.5;
			progressbar.y = textField.y + textField.height * 0.5 + 30;*/

			movie = new LeafPreloaderAnimation();
			addChild(movie);
			movie.x = (stage.stageWidth - movie.width) * 0.5;
			movie.y = (stage.stageHeight - movie.height) * 0.5;

			updateProgress();
			addEventListener(Event.ENTER_FRAME, updateProgress);
		}

		private function updateProgress(... rest):void
		{
			if(framesLoaded == totalFrames)
				onComplete()
			else
			{
				var value:Number = (loaderInfo.bytesLoaded / loaderInfo.bytesTotal);


				/*textField.text = int(int(value * 1000) * 0.1) + '%';

				var w:int = 100;
				var h:int = 40;
				var g:Graphics = progressbar.graphics;
				g.clear();
				g.lineStyle(1, 0xB3C782);
				g.beginFill(0xC5E16E);
				g.drawRect(-w * 0.5, -w * 0.5, w, h);
				g.lineStyle(0, 0, 0);
				g.beginFill(0x8DB70A);
				g.drawRect(-w * 0.5, -w * 0.5, w * value, h);

				var i:int = 0;
				while(i < this.numChildren){
					var ch:DisplayObject = this.getChildAt(i);
					if(ch == textField || ch == progressbar)
						i++;
					else
						this.removeChildAt(i);
				}*/

				if(isNaN(value)) value = 0
				movie.gotoAndStop(int(movie.totalFrames * Math.min(value, 0.999)) + 1)
			}
		}

		private function onComplete(event:Event = null):void
		{
			removeEventListener(Event.ENTER_FRAME, updateProgress);
			if(movie.hasOwnProperty('clear'))
				movie.clear();
			this.stop();
			start();
		}

		protected function start():void
		{
			var s:Stage = this.stage;

			if(this.parent)
				this.parent.removeChild(this)

			var app:Class = getDefinitionByName(loaderName) as Class;
			s.addChild(new app());
		}
	}
}