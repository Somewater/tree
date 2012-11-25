package tree.view.gui {
import com.somewater.text.EmbededTextField;
import com.somewater.text.LinkLabel;

import flash.display.DisplayObject;
import flash.display.MovieClip;

public class IconButton extends Button{

	private var linkTextField:LinkLabel;

	public function IconButton(icon:MovieClip) {
		super(icon);
		linkTextField = new LinkLabel(null, 0x2881c6, 13);
		addChild(linkTextField);
	}

	override protected function refresh():void {
		if(!linkTextField) return;

		var x:int = movie.x + movie.width + 5
		for each(var nearX:int in [10,25,35,60,100])
			if(nearX >= x){
				x = nearX;
				break;
			}
		linkTextField.x = x;
		linkTextField.y = (movie.height - linkTextField.height) * 0.5;
	}

	override public function get label():String {
		return linkTextField.text;
	}

	override public function set label(value:String):void {
		linkTextField.text = value;
		refresh();
	}
}
}
