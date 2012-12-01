/**
 * Created with IntelliJ IDEA.
 * User: somewater
 * Date: 01.12.12
 * Time: 23:51
 * To change this template use File | Settings | File Templates.
 */
package tree.view.gui {
import flash.display.Sprite;

public class GuiShield extends Sprite {
	public function GuiShield() {
		super();

		graphics.beginFill(0,0.5);
		graphics.drawRect(-3000, -3000, 6000, 6000);
	}
}
}
