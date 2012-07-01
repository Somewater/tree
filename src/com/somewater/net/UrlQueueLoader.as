package com.somewater.net
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequest;

	/**
	 * Осуществляет загрузку очереди загрузок
	 * (грузит в 1 поток)
	 */
	public class UrlQueueLoader
	{
		private static var _instance:UrlQueueLoader;
		
		private var urlLoader:URLLoader;
		private var jobInProgress:Boolean = false;// что то загружается в данный момент
		
		private var jobQueue:Array = [];
		
		private var currentData:Object;
		private var currentJob:Array;
		private var currentTasksQuantity:int;
		private var currentTasksCounter:int;
		private var currentJobFields:Array;// array ["XmlName", "SecondXmlName", ...]
		
		public function UrlQueueLoader()
		{
			if(_instance)
				throw new Error("Singletone");
		}
		
		// особого смысла доступа к инстунсу нет, поэтому скрываем его
		private static function get instance():UrlQueueLoader
		{
			if(_instance == null)
				_instance = new UrlQueueLoader();
			
			return _instance;
		}
		
		/**
		 * alias
		 */
		public static function load(data:Object, 
									onComplete:Function = null, 
									onError:Function = null, 
									onProgress:Function = null):void
		{
			instance.load(data, onComplete, onError, onProgress);
		}
		
		/**
		 * Загрузать файлы, поместив результаты загрузки в хэш в соответствующие поля
		 * @param files - ассоциативный массив ["FileName" => {"url":"http://..."}  ,
		 * 										"SecondFileName" => "http://..."  ,
		 * 										"ThirdFileName" => UrlRequest	]
		 * @param onComplete(files:Hash of String)
		 * @param onError():void
		 * @param onProgress(progress:Number = 0..1)
		 */
		public function load(files:Object,
							 onComplete:Function = null, 
							 onError:Function = null, 
							 onProgress:Function = null):void
		{
			if(urlLoader == null)
				createLoader();
			

			jobQueue.push([files, onComplete, onError, onProgress]);
			
			if(!jobInProgress)
			{
				onNext(true);
			}
		}
		
		
		private function createLoader():void
		{
			if(urlLoader == null)
			{
				urlLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onSomeError);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSomeError);
			}
		}
		
		private function clearLoader():void
		{
			if(urlLoader)
			{
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onSomeError);
				urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSomeError);
				urlLoader = null;
			}
		}
		
		
		private function onComplete(e:Event):void
		{
			currentData[currentJobFields[0]] = URLLoader(e.currentTarget).data;
			
			onNext();
		}
		
		// если вызвана без параметров, имеется в виду, что загрузка нового файла только началась (e.bytesLoaded == 0)
		private function onProgress(e:ProgressEvent = null):void
		{
			// если callback onProgress не null
			if(currentJob[3])
			{
				var value:Number = 1 / currentTasksQuantity;
				currentJob[3](	value * (e?(e.bytesLoaded/e.bytesTotal):0) + value * currentTasksCounter	);
			}
		}
		
		private function onSomeError(e:Event):void
		{
			if(currentJob[2])
				currentJob[2]();
			
			onNext(true);
		}
		
		/**
		 * Приступить к следующей загрузке, если необходимо
		 * @param skipCurrentJob пропустить всю текущую очередь загрузки и перейти к следующей (если задана)
		 */
		private function onNext(skipCurrentJob:Boolean = false):void
		{
			if(currentJobFields)
			{
				currentJobFields.shift();
				currentTasksCounter++;
			}
			else
				currentJobFields = [];
			
			// проверить onComplete
			if(!skipCurrentJob && currentJobFields.length == 0)
			{
				// загрузили последнее поле и ошибок не было
				if(currentJob[1])
				{
					currentJob[1](currentData);
				}
			}
			
			// проверить необходимость приступить к следующей job
			if(skipCurrentJob || currentJobFields.length == 0)
			{
				currentJob = jobQueue.shift();
				
				if(currentJob == null)
				{
					// больше нет заданий, уничтожаем лоадер
					clearLoader();
					jobInProgress = false;
					return;
				}
				
				currentData = currentJob[0];
				currentTasksCounter = 0;
				currentTasksQuantity = 0;
				for(var name:String in currentData)
				{
					currentTasksQuantity++;
					currentJobFields.push(name);
				}
				
				if(currentTasksQuantity == 0)
				{
					// если job, к которой приступили, не содержит тасков, приступаем к следующей
					onNext();
					return;
				}
			}
			
			var url:Object = currentData[currentJobFields[0]];
			if(url.hasOwnProperty('binary') && url.binary)
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			if(!(url is String) && url.hasOwnProperty("url"))
				url = url.url;

			urlLoader.load(url is URLRequest ? url as URLRequest : new URLRequest(String(url)));
			jobInProgress = true;
			
			onProgress();
		}
		
		
	}
}