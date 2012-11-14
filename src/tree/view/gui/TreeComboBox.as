package tree.view.gui {
import com.somewater.text.EmbededTextField;

import fl.controls.ComboBox;
import fl.controls.TextInput;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import tree.common.Config;
import tree.common.IClear;

public class TreeComboBox extends ComboBox implements IClear{

		public static const FILTER:String = 'treeCBFilter';

		private var icon:DisplayObject;
		private var promptActive:Boolean = false;


		public function TreeComboBox() {
			super();
			this.height = 28;

			icon = Config.loader.createMc('ComboBox_ArrowIcon');
			addChild(icon);

			textField.textField.autoSize = TextFieldAutoSize.LEFT;

			setStyle('textPadding', 5);
		}

		override protected function draw():void {
			super.draw();

			icon.x = this.width - 10;
			icon.y = this.height * 0.5 - 2;
			textField.width = this.width - 14;
		}

		override protected function clearPrompt():void {
			setTextColor(inputField, 0);
			super.clearPrompt();
			promptActive = false;
		}

		override protected function showPrompt():void {
			setTextColor(inputField, 0x666666);
			super.showPrompt();
			promptActive = true;
		}

		private function setTextColor(tf:TextInput, color:uint):void{
			var format:TextFormat = (tf.getStyle('textFormat') as TextFormat) || EmbededTextField.getEmbededFormat();
			format.color = color;
			format.size = 13;
			tf.setStyle('textFormat', format);
			tf.drawNow();
		}

		override protected function positionList():void {
			var p:Point = localToGlobal(new Point(0,0));
			list.x = p.x;
			if (p.y + height + list.height > stage.stageHeight) {
				list.y = p.y - list.height;
			} else {
				list.y = p.y + height - 5;
			}
		}


		override protected function onInputFieldFocus(event:FocusEvent):void {
			super.onInputFieldFocus(event);
			if(promptActive){
				clearPrompt();
				inputField.text = '';
			}
		}

		override protected function onInputFieldFocusOut(event:FocusEvent):void {
			super.onInputFieldFocusOut(event);
			if(promptActive)
				showPrompt();
			else{
				if(list && list.selectedItem){
					inputField.text = itemToLabel(list.selectedItem)
				}
			}
		}

		public function clear():void {
		}

		// если в редактируемое поле ввели хрень, не сбрасывать значение
		override protected function onTextInput(event:Event):void {
			// Stop the TextInput CHANGE event
			event.stopPropagation();
			if (!_editable) { return; }
			// If editable, set the editableValue, and dispatch a change event.
			editableValue = inputField.text;
			////////////////selectedIndex = -1;
			////////////////dispatchEvent(new Event(Event.CHANGE));
			dispatchEvent(new Event(TreeComboBox.FILTER));
		}
}
}
