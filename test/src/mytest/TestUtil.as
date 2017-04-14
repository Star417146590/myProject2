package mytest
{
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class TestUtil extends Sprite
	{
		public static const DEGREES_TO_RADIANS:Number=Math.PI/180;
		public static const X_AXIS:Vector3D=new Vector3D(1,0,0);
		public static const Y_AXIS:Vector3D=new Vector3D(0,1,0);
		public static const Z_AXIS:Vector3D=new Vector3D(0,0,1);
		
		public static const TEMP_MATRIX3D:Matrix3D=new Matrix3D();
		
		public function TestUtil()
		{
			var data:Array
			
			var oldRotate:Vector3D = new Vector3D(0.001,90,0);
			var oldRotate1:Vector3D = new Vector3D(1.5707963705062866, -1.5707963705062866, -1.5707963705062866)
			var oldRotate2:Vector3D = new Vector3D(1.5707963705062866, -1.5707963705062866, -1.5707963705062866)
			var oldRotate3:Vector3D = new Vector3D(1.5707963705062866, -1.5707963705062866, -1.5707963705062866)
			var oldRotate4:Vector3D = new Vector3D(1.5707963705062866, -1.5707963705062866, -1.5707963705062866)
			
			var rotate:Vector3D = getOtherCoordSysRotationFromRotation(oldRotate.x,oldRotate.y,oldRotate.z);
			
			trace(rotate);	
			
		}
		
		/**
		 * 从指定旋转值中获取其它坐标系的旋转值，期间坐标系会发生改变，比如输入的旋转值为左手系值，则得到的值为右手系值；相反，如果输入的旋转值为右手系值，则得到的值为左手系值。
		 * @param degreesRx x角度值
		 * @param degreesRy y角度值
		 * @param degreesRz z角度值
		 * @return 一个Vector3D，里面的值为弧度值
		 */
		public static function getOtherCoordSysRotationFromRotation(degreesRx:Number,degreesRy:Number,degreesRz:Number):Vector3D
		{
			if(degreesRy>-0.001 && degreesRy<0.001) {
				return new Vector3D(-degreesRx*DEGREES_TO_RADIANS,-degreesRz*DEGREES_TO_RADIANS,0);
			}else if(degreesRz>-0.001 && degreesRz<0.001){
				return new Vector3D(-degreesRx*DEGREES_TO_RADIANS,0,-degreesRy*DEGREES_TO_RADIANS);
			}
			TEMP_MATRIX3D.identity();
			TEMP_MATRIX3D.appendRotation(-degreesRx,X_AXIS);
			TEMP_MATRIX3D.appendRotation(-degreesRy,Z_AXIS);
			TEMP_MATRIX3D.appendRotation(-degreesRz,Y_AXIS);
			return TEMP_MATRIX3D.decompose()[1];
		}
	}
}