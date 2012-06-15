package utils {
	
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import windows.PopUpWindow;
	import windows.ReportWindow;
	import windows.WindowInfo;
	
	public class Utils {
		
		private static var _time:Number = new Date().getTime();
		private static var _onFrameListeners:Array = new Array();
		private static var _onResizeListeners:Array = new Array();
		private static var _width:int;
		private static var _height:int;
		private static var _widthHalf:Number;
		private static var _heightHalf:Number;
		
		public function Utils() {
			
		}
		
		public static function get time():Number { return _time; }
		
		// OnFrame
		public static function addOnFrame(caller:Function):void {
			var ind:int = _onFrameListeners.indexOf(caller);
			if (ind == -1)_onFrameListeners.push(caller);
		}
		public static function removeOnFrame(caller:Function):void {
			var ind:int = _onFrameListeners.indexOf(caller);
			if (ind != -1) _onFrameListeners.splice(ind, 1);
		}
		public static function onFrame(event:Event):void {
			_time = new Date().getTime();
			var array:Array = _onFrameListeners;
			for (var i:uint = 0; i < _onFrameListeners.length; i++) _onFrameListeners[i]();
		}		
		
		// Resize
		public static function addOnResize(caller:Function):void {
			var ind:int = _onResizeListeners.indexOf(caller);
			if (ind == -1)_onResizeListeners.push(caller);
		}		
		public static function removeOnResize(caller:Function):void {
			var ind:int = _onResizeListeners.indexOf(caller);
			if (ind != -1) _onResizeListeners.splice(ind, 1);
		}		
		public static function onResize(e:Event):void {
			_width = e.target.stageWidth;
			_height = e.target.stageHeight;
			_widthHalf = _width * .5;
			_heightHalf = _height * .5;
			for (var i:uint = 0; i < _onResizeListeners.length; i++) _onResizeListeners[i]();
		}
		
		public static function get stageWidth():int {
			return _width;
		}		
		public static function get stageHeight():int {
			return _height;
		}		
		public static function get stageWidthHalf():int {
			return _widthHalf;
		}		
		public static function get stageHeightHalf():int {
			return _heightHalf;
		}
		
		public static function getObjectFromLib(loader:Loader, name:String):Object {
			var a:Object;
			if (loader.contentLoaderInfo.applicationDomain.hasDefinition(name)) {
				a = loader.contentLoaderInfo.applicationDomain.getDefinition(name);
				return new a();
			}
			return null;
		}
		
		public static function loadDisplayObject(
			url:String,
			handler:Function,
			params:Array = null,
			appDomain:ApplicationDomain = null
		):void {
			var loader:Loader = new Loader();
			var onLoad:Function = function(e:Event):void {
				deleteAll();
				if (params == null) handler(loader);
				else handler(loader, params); 
			}
			var onError:Function = function(e:IOErrorEvent):void {
				deleteAll();
				trace(e.text);
			}
			var onSecurityError:Function = function (e:SecurityErrorEvent):void {
				deleteAll();
				trace(e.text);
			}
			var deleteAll:Function = function():void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoad);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.load(new URLRequest(url), new LoaderContext(false, appDomain ? appDomain : new ApplicationDomain()));
		}
		
		public static function loadXML(url:String, handler:Function):void {
			var loader:URLLoader = new URLLoader();
			var onLoad:Function = function(event:Event):void {
				deleteAll();
				handler(loader);
			}
			var onError:Function = function(e:IOErrorEvent):void {
				deleteAll();
				trace(e.text);
			}
			var onSecurityError:Function = function (e:SecurityErrorEvent):void {
				deleteAll();
				trace(e.text);
			}
			var deleteAll:Function = function():void {
				loader.removeEventListener(Event.COMPLETE, onLoad);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoad);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			loader.load(new URLRequest(url));
		}
		
		public static function sendURLVariables(url:String, variables:URLVariables, callback:Function):void {
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			var onComplete:Function = function(e:Event):void {
				callback(e.target.data);
			}			
			loader.addEventListener(Event.COMPLETE, onComplete);
			request.method = URLRequestMethod.POST;
			request.data = variables;			
			try {
				loader.load(request);
			} catch (e:Error) {
				trace("Error! Can not send URLVariables to " + url + "! " + e.message);
			}	
		}
		
		/** В одну строку без переноса слов... */
		public static function createTextField(format:TextFormat, autoSize:String = null):TextField {
			var txt:TextField = new TextField();
			if (autoSize == null) txt.autoSize = TextFieldAutoSize.LEFT;
			else txt.autoSize = autoSize;
			txt.embedFonts = true;
			txt.selectable = false;
			txt.wordWrap = false;
			txt.defaultTextFormat = format;
			return txt;
		}
		
		/** Динамическая ширина с переносом слов... */
		public static function createSizeTextField(format:TextFormat, w:uint, autoSize:String = null):TextField {
			var txt:TextField = new TextField();
			if (autoSize == null) txt.autoSize = TextFieldAutoSize.LEFT;
			else txt.autoSize = autoSize;
			txt.width = w;
			txt.embedFonts = true;
			txt.selectable = false;
			txt.wordWrap = true;
			//txt.border = true;
			if (format) txt.defaultTextFormat = format;
			return txt;
		}
		
		/** В одну строку без переноса слов, но огранниченная размером... */
		public static function createNoWrapSizeTextField(format:TextFormat, size:Point):TextField {
			var txt:TextField = new TextField();
			txt.embedFonts = true;
			txt.selectable = false;
			txt.wordWrap = false;
			txt.defaultTextFormat = format;
			txt.width = size.x;
			txt.height = size.y;
			return txt;
		}
		
		/** Динамическая ширина HTML... */
		public static function createSizeHTMLTextField(w:uint, autoSize:String = null):TextField {
			var txt:TextField = new TextField();
			if (autoSize == null) txt.autoSize = TextFieldAutoSize.LEFT;
			else txt.autoSize = autoSize;
			txt.width = w;
			txt.multiline = true;
			txt.selectable = false;
			txt.wordWrap = true;
			//txt.border = true;
			return txt;
		}
		
		/** Рисуем DotLine */
		public static function drawDotLine(
			graphics:Graphics,
			from:Point,
			to:Point,
			distance:uint,
			color:Number,
			thickness:Number,
			alpha:Number
		):void {
			graphics.lineStyle(1, color);
			
			var x:Number;
			var y:Number;
			var i:Number;
			var step:Number;
			
			var k:int = 1;
			
			var l:Number = Math.abs(to.x - from.x);
			var max:Number = Math.abs(to.y - from.y);
			if (l > max) max = l;
			
			if (l == 0) { /** Случай, когда x постоянный - вертикальная линия */
				step = distance; // Задаем относительное расстояние между точками...
				if (to.y < from.y) k = -1;
				for (i = 0; i < max; i += step) {
					y = i * k;
					drawLinePoint(graphics, new Point(from.x, from.y + y));
				}
			} else { /** Стандартный случай */
				if (to.x < from.x) k = -1;
				step = l / max;	// step должен быть обратнопропорциональным максимальной длине линии...
				step = step * distance; // Задаем относительное расстояние между точками...
				for (i = 0; i < l; i += step) {
					x = i * k + from.x;
					drawLinePoint(graphics, countLinePoint(from, to, x));
				}
			}
		}
		
		/** Рисуем DashLine */
		public static function drawDashLine(
			graphics:Graphics,
			from:Point,
			to:Point,
			dash:uint,
			color:Number,
			thickness:Number,
			alpha:Number
		):void {
			graphics.lineStyle(1, color);
			
			var x:Number;
			var y:Number;
			var i:Number;
			var step:Number;
			
			var k:int = 1;
			
			var l:Number = Math.abs(to.x - from.x);
			var max:Number = Math.abs(to.y - from.y);
			if (l > max) max = l;
			
			var doubleDash:uint = dash * 2;
			
			var counter:uint;
			
			if (l == 0) { /** Случай, когда x постоянный - вертикальная линия */
				if (to.y < from.y) k = -1;
				step = 1; // Задаем относительное расстояние между точками...
				for (i = 0; i < max; i += step) {
					y = i * k;
					if (counter < dash) drawLinePoint(graphics, new Point(from.x, from.y + y)); // Рисуем
					else if (counter > doubleDash) counter = 0; // Сбрасываем
					counter++;
				}	
			} else { /** Стандартный случай */
				if (to.x < from.x) k = -1;
				step = l / max; // step должен быть обратнопропорциональным максимальной длине линии...
				for (i = 0; i < l; i += step) {
					x = i * k + from.x;
					if (counter < dash) drawLinePoint(graphics, countLinePoint(from, to, x)); // Рисуем
					else if (counter > doubleDash) counter = 0; // Сбрасываем
					counter++;
				}	
			}
		}
		
		/** Уравнения прямой, проходящей через две заданные несовпадающие точки в общем виде */
		private static function countLinePoint(a:Point, b:Point, x:Number):Point {
			var y:Number = (b.x * a.y - a.x * b.y - x * (a.y - b.y)) / (b.x - a.x);
			if (isNaN(y) || y == Infinity) return new Point(b.x, x); // Случай, когда x постоянный - вертикальная линия
			return new Point(x, y);
		}
		
		private static function drawLinePoint(graphics:Graphics, pointPos:Point):void {
			graphics.moveTo(pointPos.x, pointPos.y);
			graphics.lineTo(pointPos.x + 1, pointPos.y + 1);
			graphics.endFill();
		}
		
		/** Создать круг с нужными свойствами... */
		public static function createCircle(
			color:Number,
			radius:uint,
			outlineThickness:Number = NaN,
			outlineColor:Number = NaN
		):Sprite {
			var s:Sprite = new Sprite();
			var shape:Shape = new Shape();
			if (outlineThickness && outlineThickness) shape.graphics.lineStyle(outlineThickness, outlineColor);
			shape.graphics.beginFill(color);
			shape.graphics.drawCircle(0, 0, radius);
			shape.graphics.endFill();
			shape.x = shape.y = radius;
			s.addChild(shape);
			return s;
		}
		
		/** Показать окно с сообщением */
		public static function showReport(message:String):void {
			var windowInfo:WindowInfo = new WindowInfo(
				ConsecutiveFamilyTree.instance.stage,
				null,
				new Back(),
				null,
				Constants.LOG_FORMAT
			);
			var window:ReportWindow = new ReportWindow(windowInfo, message);
			PopUpWindow.instance.show(window);
		}
		
	}
}