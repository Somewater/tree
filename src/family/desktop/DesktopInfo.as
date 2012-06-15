package family.desktop {
	
	import family.level.LevelCellInfo;
	
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public class DesktopInfo {
		
		public var stage:Stage;
		
		public var wheelLimits:Vector3D;
		
		public var levelNums:uint;
		public var levelGrid:Point;
		public var size:Point;
		public var colors:Array;
		public var alphas:Array;
		public var levelCellInfo:LevelCellInfo;
		
		public var halfSize:Number; // Половина ширины уровня вычисляется 1 единственный раз чтобы не тратить ресурсы)
		public var levelCellNums:uint; // Количество ячеек в ряду (вычисляется 1 единственный раз чтобы не тратить ресурсы)
	
		public var treeItemShift:uint;
		public var levelRowShift:uint;
		public var maxTreeItemVShift:uint; // Сдвиг ячейки по вертикали
		public var maxTreeItemHShift:uint; // Сдвиг ячейки по горизонтали 
		
		public var levelRowMaxNum:uint;
		
		public function DesktopInfo(
			stage:Stage,
			wheelLimits:Vector3D,
			vNums:uint,
			levelGrid:Point,
			size:Point,
			colors:Array,	
			alphas:Array,
			levelCellInfo:LevelCellInfo,
			treeItemShift:uint,
			levelRowShift:uint,
			levelRowMaxNum:uint
		) {
			this.stage = stage;
			
			this.wheelLimits = wheelLimits;
			
			this.levelNums = vNums;
			this.levelGrid = levelGrid;
			this.size = size;
			this.colors = colors;
			this.alphas = alphas;
			
			this.levelCellInfo = levelCellInfo;
			
			this.halfSize = this.size.x / 2;
			this.maxTreeItemHShift = levelGrid.x * .5 + treeItemShift;
			
			// -2 клетки - на всякий случай чтобы избежать вероятных ошибок алгоритмов на правом краю поля
			this.levelCellNums = Math.ceil(this.size.x / maxTreeItemHShift) - 2;
			
			this.treeItemShift = treeItemShift;
			this.levelRowShift = levelRowShift;
			this.maxTreeItemVShift = levelGrid.y + levelRowShift;
			
			this.levelRowMaxNum = levelRowMaxNum - 1;
		}
	}
}