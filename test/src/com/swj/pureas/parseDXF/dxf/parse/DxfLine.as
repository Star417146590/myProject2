package com.swj.pureas.parseDXF.dxf.parse
{
	import flash.geom.Point;

	public class DxfLine
	{
		public var LName:String;
		
		public var colornum:String;
		
		public var lwidth:String;
		
		public var start:Point = new Point();
		
		public var end:Point = new Point();
		
		public function DxfLine()
		{
		}
	}
}