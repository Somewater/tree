package utils { 
	
	import caurina.transitions.Tweener;
	
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class Tweens {
		
		public function Tweens() {
			
		}
		
		/** Создание анимации Tween с возможностью dBlur и sAlpha... */
		public static function tween(
			displayObject:Object,
			animType:String,
			animTime:Number,
			
			beginPos:Point,
			beginScale:Point,
			beginAlpha:Number,
			beginBlur:Point,
			
			endPos:Point,
			endScale:Point,
			endAlha:Number,
			endBlur:Point,
			
			func:Function = null,
			delay:Number = 0
		):void {
			var object:Object = {}
			
			if (beginPos) {
				displayObject.x = beginPos.x;
				displayObject.y = beginPos.y;
				
				object.x = endPos.x;
				object.y = endPos.y;
			}
			
			if (beginScale) {
				displayObject.scaleX = beginScale.x;
				displayObject.scaleY = beginScale.y;
				
				object.scaleX = endScale.x;
				object.scaleY = endScale.y;
			}
			
			if (!isNaN(beginAlpha)) {
				displayObject.alpha = beginAlpha;
				
				object.alpha = endAlha;
			}	
			
			if (beginBlur) {
				displayObject.filters = [new BlurFilter(beginBlur.x, beginBlur.y)];
				
				object._Blur_blurX = endBlur.x;
				object._Blur_blurY = endBlur.y;
			}	
			
			object.time = animTime;
			object.transition = animType;
			object.onComplete = tweenEnd;
			object.onCompleteParams = [displayObject, func];
			object.delay = delay;
			
			Tweener.addTween(displayObject, object);
		}	
		
		/** Создание анимации Tween с возможностью dColor... */
		public static function tweenColor(
			displayObject:DisplayObject,
			colorTransform1:ColorTransform,
			colorTransform2:ColorTransform,
			animType:String,
			animTime:Number,
			delay:Number,
			func:Function = null			
		):void {
			Tweener.addTween(
				displayObject,
				{
					time:animTime,
					transition:animType,
					_colorTransform:colorTransform1
				}
			);
			Tweener.addTween(
				displayObject,
				{
					time:animTime,
					transition:animType,
					_colorTransform:colorTransform2,
					
					delay:delay,
					
					onComplete:tweenEnd,
					onCompleteParams:[displayObject, func]
				}
			);
		}
		
		/** Создание анимации Tween с возможностью dBrightness... */
		public static function tweenBrightness(
			displayObject:DisplayObject,
			brightness1:Number,
			brightness2:Number,
			animType:String,
			animTime:Number,
			delay:Number,
			func:Function = null
		):void {
			Tweener.addTween(
				displayObject,
				{
					time:animTime,
					transition:animType,
					_brightness:brightness1
				}
			);
			
			Tweener.addTween(
				displayObject,
				{
					time:animTime,
					transition:animType,
					_brightness:brightness2,
					onComplete:tweenEnd,
					onCompleteParams:[displayObject, func],
					delay:delay
				}
			);
		}
		
		private static function tweenEnd(target:DisplayObject, func:Function):void {
			if (func != null) func(target);
		}
	}
}