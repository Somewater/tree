package family.level {
	
	import flash.geom.Vector3D;
	
	public class LevelCellInfo {
		
		public var fill:Vector3D; // round, color, alpha
		public var outline:Vector3D; // thikness, color, alpha
		
		public function LevelCellInfo(
			fill:Vector3D,
			outline:Vector3D
		) {
			this.fill = fill;
			this.outline = outline;
		}
	}
}