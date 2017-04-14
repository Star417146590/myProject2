package com.swj.pureas.parseDXF.dxf.parse
{
	import flash.geom.Point;

	public class DxfSpline
	{
		public var LName:String;
		
		public var colornum:String;
		
		public var lwidth:String;
		
		public var count:int;
		
		public var flag:int;
		
		public var through:Vector.<Point> = new Vector.<Point>();
		
		public var startPoint:Point = new Point();
		
		public var endPoint:Point = new Point();
		
		public function DxfSpline()
		{
		}
	}
}