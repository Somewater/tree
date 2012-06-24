package tree.loader {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;

	public class Preloader extends MovieClip{

		public var loaderName:String = 'TreeLoader';
		private var textField:TextField;

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

			textField = new TextField();
			addChild(textField);
			textField.x = (stage.stageWidth - textField.width) * 0.5;
			textField.y = stage.stageHeight * 0.5;
			textField.selectable = false;
			textField.defaultTextFormat.align = 'center';

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
				textField.text = (int(value * 1000) * 0.1) + '%';
			}
		}

		private function onComplete(event:Event = null):void
		{
			removeEventListener(Event.ENTER_FRAME, updateProgress);
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