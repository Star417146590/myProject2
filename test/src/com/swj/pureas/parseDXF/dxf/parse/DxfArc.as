package com.swj.pureas.parseDXF.dxf.parse
{
	import flash.geom.Point;

	public class DxfArc
	{
		public var LName:String;
		
		public var lwidth:String;
		
		public var startAngle:Number;
		
		public var endAngle:Number;
		
		public var center:Point = new Point();
		
		public var radiu:Number;
		
		public function DxfArc()
		{
		}
	}
}