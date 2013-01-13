package tree.model {
import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

/**
 * Записывает все ручные перемещения
 */
public class HandMovingLog {

	private var log:Array = [];

	public var changed:ISignal;

	public function HandMovingLog() {
		changed = new Signal();
	}

	public function add(node:Node):void{
		if(log.indexOf(node) == -1){
			var l:int = log.length;
			log.push(node);
			if(l == 0)
				changed.dispatch();
		}
	}

	public function clear():void{
		var l:int = log.length;
		log = [];
		if(l > 0)
			changed.dispatch();
	}

	public function empty():Boolean{
		return log.length == 0;
	}

	public function formatPrint():String {
		var s:String = '';
		for each(var n:Node in log){
			if(s.length) s += ';'
			s += n.uid + '=' + n.handX + ',' + n.handY;
		}
		return s;
	}
}
}