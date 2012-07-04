package {
	import com.junkbyte.console.Cc;

	public function error(message:*):void {
		CONFIG::debug {
			Cc.error(message);
		}
	}
}
