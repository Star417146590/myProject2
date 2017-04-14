package com.swj.pureas.parseDXF.dxf.parse
{
	import flash.geom.Point;

	public class DxfLwpolyline
	{
		public var LName:String;
		
		public var colornum:String;
		
		public var lwidth:String;
		
		public var pointCount:int;
		
		public var flag:int;
		
		public var points:Vector.<Point> = new Vector.<Point>();
		
		public var converxity:Vector.<Number> = new Vector.<Number>();
		
		public function DxfLwpolyline()
		{
			
		}
		
//		public function getScatterPoint():Vector.<Point>
//		{
//			var len:int;
//			var pointValue:Vector.<Point> = points.concat();
//			if(flag==0)
//			{
//				len=pointCount-1;
//			}
//			else if(flag==1)
//			{
//				len  = pointCount; 
//				pointValue.push(pointValue[0]);
//			}
//			
//			var newPoints:Vector.<Point> = new Vector.<Point>();
//			for (var i:int = 0; i < len; i++) 
//			{
//				var a:Point=pointValue[i];
//				var b:Point=pointValue[i+1];
//				if(converxity[i]==0)
//				{
//					newPoints.push(a,b);
//				}
//				else
//				{
//					var abLen:Number=Point.distance(a,b);//获取两个端点的距离
//					var h:Number=converxity[i]*abLen*0.5;
//					var sub:Point=a.subtract(b);
//					sub=pointRotate(sub,90);
//					
//					sub.normalize(h);//圆心位置
//					var c:Point= new Point((a.x+b.x)*0.5+sub.x,(a.y+b.y)*0.5+sub.y);
//					newPoints=newPoints.concat(ArrayUtil.connectedSeparate(MathGeometry.pointArc(c,a,b,servings),false));
//				}
//			}
//			return newPoints;
//		}
//		
//		public static function pointRotate(point:Point,rotate:Number):Point
//		{
//			var newPoint:Point= new Point();
//			rotate = rotate*Math.PI/180;
//			var sin:Number= Math.sin(rotate);
//			var cos:Number=Math.cos(rotate);
//			newPoint.x = point.x*cos  - point.y*sin;
//			newPoint.y = point.x*sin  + point.y*cos;
//			return newPoint;		
//		}
		
		
	}
}