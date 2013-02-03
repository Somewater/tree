package tree.signal {
	import flash.utils.ByteArray;

	public class ResponseSignal {

		public static const SIGNAL:String = 'response';

		public static const SUCCESS:String = 'success';
		public static const ERROR:String = 'error';

		public var type:String;
		public var data:*;
		public var request:RequestSignal;
		public var errorHandler:Boolean = false;

		public function ResponseSignal(type:String, data:*, request:RequestSignal) {
			this.type = type;
			this.data = data;
			this.request = request;
		}

		public function toXml():XML {
			return data is XML ? data : new XML(data);
		}

		public function toString():String {
			return String(data);
		}

		public function toBytes():ByteArray {
			return ByteArray(data);
		}

		public function isError():Boolean{
			return type != SUCCESS;
		}

		public function getMessage():String{
			var message:String = getErrorMessage();
			if(message) return message;
			var xml:XML = toXml();
			if(xml){
				if(xml.message && xml.message.toString().length > 0){
					message = xml.message.toString();
				}
			}
			return message;
		}

		public function getErrorMessage():String {
			var message:String = null;
			var xml:XML = toXml();
			if(xml){
				if(xml.error && xml.error.toString().length > 0){
					message = xml.error.toString();
				}
			}
			return message;
		}

		/**
		 * Запрос, при положительном ответе на который не следует выводить сообщение
		 */
		public function silent():Boolean {
			return request ? request.silent : false;
		}
	}
}
