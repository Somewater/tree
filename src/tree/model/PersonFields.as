package tree.model {
public class PersonFields {

	private var hash:Object = {};

	public function PersonFields() {
	}

	public function get(name:String):String{
		return hash[name] || '';
	}

	public function has(name:String):Boolean{
		var val:String = hash[name];
		return val && val.length > 0;
	}

	public function read(xml:XMLList):void{
		for each(var field:XML in xml.*){
			var nField:String = field.@name;
			var vField:String = field.toString();
			hash[nField] = vField;
		}
	}
}
}
