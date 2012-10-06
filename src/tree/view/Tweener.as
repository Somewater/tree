package tree.view {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;

	import tree.common.Config;
	import tree.model.Model;

	/**
	 * Обертка для обращений к твиннеру
	 */
	public class Tweener {
		public function Tweener() {

		}

		public static function to(target:Object=null,
						   duration:Number=1,
						   values:Object=null,
						   props:Object=null):GTween {
			var m:Model = Model.instance;
			var minDuration:Number = m.animationQuality == 0 ? 10 : (m.animationQuality == 1 ? (m.constructionInProcess ? 0.4 : 0.1) : 0.05);
			if(duration < minDuration){
				for(var propName:String in values)
					target[propName] = values[propName];
				if(props && props['onComplete'])
					Config.ticker.callLater(props['onComplete'], 1)
				return null;
			}else
				return GTweener.to(target, duration, values, props);
		}
	}
}
