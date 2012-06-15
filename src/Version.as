package {
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Version extends TextField {
		
		public function Version(version:String) {
			autoSize = TextFieldAutoSize.LEFT;
			embedFonts = true;
			defaultTextFormat = Constants.VERSION_FORMAT;
			text = version;
			mouseEnabled = false;
		}
	}
}