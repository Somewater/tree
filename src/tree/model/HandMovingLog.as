package tree.model {

/**
 * Записывает все ручные перемещения
 */
public class HandMovingLog {

	private var log:Array = [];

	public function HandMovingLog() {
	}

	public function add(uid:int, toX:int, toY:int, fromX:int, fromY:int):void{
		var e:LogEntry = new LogEntry();
		e.uid = uid;
		e.fromX = fromX;
		e.fromY = fromY;
		e.toX = toX;
		e.toY = toY

		log.push(e);
	}

	public function clear():void{
		log = [];
	}

	public function empty():Boolean{
		return log.length == 0;
	}
}
}

class LogEntry{
	public var uid:int;

	public var fromX:int;
	public var fromY:int;
	public var toX:int;
	public var toY:int;
}
