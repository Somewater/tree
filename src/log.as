package {
	import com.junkbyte.console.Cc;

	public function log(message:*):void {
		CONFIG::debug {
			Cc.log(message);
		}
	}
}
