package tree.loader
{
	import flash.system.ApplicationDomain;

	public class Lib
	{
		private var classCache:Array = [];
		private var inited:Boolean = false;
		
		public function Lib(_swfAds:Array):void
		{
			inited = true;
			swfADs = _swfAds;
		}
		
		
		////////////////////////////////////////////////////////////////
		//															  //
		//					U S E R		M E T H O D S				  //
		//															  //
		////////////////////////////////////////////////////////////////
		
		private var swfADs:Array = [];
		
		public function createMc(className:String, library:String = null, instance:Boolean = true):*
		{
			var cl:Class = classCache[className]
			if(cl == null)
			{
				for each(var _ad:* in swfADs)
				{
					var ad:ApplicationDomain = _ad as ApplicationDomain;
					if(ad)
					{
						try
						{
							cl = ad.getDefinition(className) as Class;
							if(cl != null)
								break;
						}catch(e:Error){}
					}
				}

				if(cl == null)
				{
					trace("[ERROR] MC " + className + " not created");
					return null;
				}

				classCache[className] = cl;
			}

			if(instance)
				return new cl();
			else
				return cl;
		}

		public function hasMC(className:String, library:String = null):Boolean
		{
			var cl:Class;
			try
			{
				cl = createMc(className, null, false) as Class;
			}catch(e:Error){}
			return cl != null;
		}
		
	}
}