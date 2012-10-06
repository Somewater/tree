package tree.view.gui {
	import com.somewater.storage.I18n;

	import flash.display.Sprite;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import tree.common.Config;
	import tree.common.IClear;

	public class ProfileSwitcher extends Sprite implements IClear{

		public var change:ISignal;
		public var personList:Button;
		public var personProfile:Button;
		private var _profile:Boolean;

		public var blocked:Boolean = false;// переключение невозможно

		public function ProfileSwitcher() {
			personProfile = new SwitchButton(Config.loader.createMc('assets.ProfileSwitcher_left'));
			personProfile.label = I18n.t('PROFILE');
			addChild(personProfile);

			personList = new SwitchButton(Config.loader.createMc('assets.ProfileSwitcher_right'));
			personList.label = I18n.t('RELATIVES');
			personList.x = personProfile.width;
			addChild(personList);

			personList.click.add(onClicked);
			personProfile.click.add(onClicked);

			profile = false;
			change = new Signal(ProfileSwitcher);
		}

		public function clear():void{
			change = new Signal(ProfileSwitcher);
		}

		private function onClicked(b:Button):void{
			if(blocked || (b as SwitchButton).selected) return;
			if(b == personList){
				profile = false;
			}else{
				profile = true;
			}
			change.dispatch(this);
		}

		public function get list():Boolean{return !_profile}
		public function get profile():Boolean{return _profile;}

		public function set list(value:Boolean):void{
			this.profile = !value;
		}

		public function set profile(value:Boolean):void{
			(personList as SwitchButton).selected = !value;
			(personProfile as SwitchButton).selected = value;
			_profile = value;
		}
	}
}

import com.somewater.text.EmbededTextField;

import flash.display.MovieClip;

import tree.view.gui.Button;

class SwitchButton extends Button{

	private var _selected:Boolean = false;

	public function SwitchButton(movie:MovieClip){
		super(movie);
		textField = new EmbededTextField(null, 0x485E06, 11, true);
	}

	public function get selected():Boolean {
		return _selected;
	}

	public function set selected(value:Boolean):void {
		if(_selected != value){
			_selected = value;
			if(value){
				upFrame = overFrame = downFrame = 4;
			} else {
				upFrame = 1;
				overFrame = 2;
				downFrame = 3;
			}
			buttonMode = useHandCursor = !value;
			toFrame(upFrame);
		}
	}
}
