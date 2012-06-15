package layers {
	
	import family.desktop.Desktop;
	import family.desktop.DesktopInteractive;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import utils.Utils;

	
	public class TreeLayer extends Sprite implements IUse,IDisposable {
		
		public function TreeLayer() {
			
		}
		
		/** Интерфейс */
		
		public function init():void {
			
		}
		
		public function update():void {
			var local:Point = globalToLocal(new Point(Utils.stageWidthHalf, 0));
			DesktopInteractive.instance.x = local.x - DesktopInteractive.instance.width;
		}
		
		public function dispose():void {
			
		}
	}
}