package family.item {
	
	import flash.text.TextFormat;
	
	public class TreeItemInfo {
		
		public var xml:XML;
		public var nameTF:TextFormat;
		
		public function TreeItemInfo(
			xml:XML,
			nameTF:TextFormat
		) {
			this.xml = xml;
			this.nameTF = nameTF;
		}
	}
}