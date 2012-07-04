package {
	import com.junkbyte.console.Cc;

	public function warn(message:*):void {
		CONFIG::debug {
			Cc.warn(message);
		}
	}
}
