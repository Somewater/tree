// перед включением задать локальную переменную _array
// на выходе получить локальную переменную _string с результатом

var accum:int = -1;
var _string:String = _array.map(function(i:int, ...args):int{
				var diff:int = i;
				if(accum != -1)
					i = (i < accum ? i + 0xFF - accum : i - accum);
				accum = diff;
				return i;
			}).map(function(elem:int, ...args):String{return String.fromCharCode(elem)}).join('');