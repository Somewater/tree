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
	}
}
