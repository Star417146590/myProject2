package com.swj.pureas.parseDXF.dxf.parse
{
	import flash.geom.Point;

	public class DxfEllipse
	{
		public var LName:String;
		
		public var lwidth:String;
		
		public var center:Point = new Point();
		
		public var delta:Point = new Point();
		
		public var startAngle:Number;
		
		public var endAngle:Number;
		
		public var radiu:Number;
		
		
		public function DxfEllipse()
		{
		}
	}
}