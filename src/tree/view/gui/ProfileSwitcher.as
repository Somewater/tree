package tree.view.gui {
	import flash.display.Sprite;

	import tree.common.Config;

	public class ProfileSwitcher extends Sprite{


		public function ProfileSwitcher() {
			addChild(Config.loader.createMc('assets.ProfileSwitcherBackground'))
		}
	}
}
