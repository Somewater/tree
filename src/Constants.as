package {
	
	import flash.filters.BevelFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.Font;
	import flash.text.TextFormat;
	
	public class Constants {
		
		[Embed(source = "resources/fonts/MyriadProRegular.ttf", fontFamily = "FontFamily1", mimeType = "application/x-font-truetype", embedAsCFF = "false")]
		private static var font1:Class;
		Font.registerFont(font1);
		
		[Embed(source = "resources/fonts/MyriadProBoldSemiExtended.ttf", fontFamily = "FontFamily2", mimeType = "application/x-font-truetype", embedAsCFF = "false")]
		private static var font2:Class;
		Font.registerFont(font2);
		
		/** Path */
		public static const TREE:String = "resources/xml/tree";
		public static const TREE_FOTO:String = "resources/foto/";
		
		/** Расширения */
		public static const BIN_EXP:String = ".bin";
		public static const JPG_EXP:String = ".jpg";
		public static const PNG_EXP:String = ".png";
		public static const GIF_EXP:String = ".gif";
		public static const SWF_EXP:String = ".swf";
		public static const XML_EXP:String = ".xml";
		
		/** TextFormat */
		public static const COMPONENT_FORMAT:TextFormat = new TextFormat("FontFamily1", 12, 0xFFFFFF);
		public static const LOG_FORMAT:TextFormat = new TextFormat("FontFamily1", 12, 0x000000);
		public static const VERSION_FORMAT:TextFormat = new TextFormat("FontFamily1", 11, 0x333333);
		public static const TREE_ITEM_NAME_FORMAT:TextFormat = new TextFormat("FontFamily1", 9, 0x000000);
		public static const COMPONENT_TEXT_FORMAT:TextFormat = new TextFormat("FontFamily1", 10, 0x000000);
		public static const TREE_NAME_FORMAT:TextFormat = new TextFormat("FontFamily1", 13);
		
		/** Эффекты */
		public static const FILTER_1:Array = [new DropShadowFilter(5, 45, 0x000000, .5)];
		public static const FILTER_2:Array = [new BevelFilter(4, 45, 0xBBBBBB, 1, 0x000000, 1, 2, 2, 2)];
		public static const FILTER_3:Array = [new BevelFilter(4, 45, 0xBBBBBB, 1, 0x000000, 1, 2, 2, 2), new ColorMatrixFilter([.8, 0, 0, 0, 0, 0, .8, 0, 0, 0, 0, 0, .8, 0, 0, 0, 0, 0, 1, 0])]
		public static const FILTER_4:Array = [new BevelFilter(2, 45, 0xBBBBBB, 1, 0x000000, 1, 2, 2, 2, 1)];
		
		/** Сообщения */
		public static const REPORT_1:String = "Невозможно подыскать подходящие пустые клетки - слишком большая плотность узлов.";
		public static const REPORT_2:String = "Невозможно установить узел в это место, так как деревья пересекуться.";
		
		public static const REPORT_3:String = "В данное место невозможно переместить дерево. По видимому, там уже находится какой-либо объект, мешающий перемещению дерева.";
		public static const REPORT_4:String = "В данное место невозможно переместить дерево. Целевая клетка-ориентир занята.";
		
		public static const REPORT_5:String = "В данное место невозможно переместить дерево. Позиция одного или более узлов перемещаемого дерева совпала с позицией узла/узлов соседнего дерева.";
		public static const REPORT_6:String = "В данное место невозможно переместить дерево. После полного перемещения дерева, оно столкнулусь с другим близлежащим и команда была отменена.";
		public static const REPORT_7:String = "Невозможно поместить дерево! Возможно 1 ряда для всех родственников одного типа - это мало!";
		public static const CREATE_TREE_ERRORS:Array = [
			REPORT_5,
			REPORT_6,
			REPORT_7
		];
	}
}