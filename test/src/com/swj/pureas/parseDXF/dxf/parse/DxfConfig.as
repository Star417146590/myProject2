package com.swj.pureas.parseDXF.dxf.parse
{
	/**
	 *
	 *	日期：2016-7-28
	 *	作者：hew
	 *	描述：dxf文件的配置信息
	 */
	public class DxfConfig
	{
		public static var dxfScale:Number = 0.06;
		/**墙体的最小可识别厚度*/
		public static var minWallWeight:Number = 80;
		/**墙体的最大可识别厚度*/
		public static var maxWallWeight:Number = 400;
		/**墙体的最小可识别长度*/
		public static var minWallLength:Number = 200;
//		/**窗户最小可识别长度*/
//		public static var minWindowLength:Number = 600;
//		/**最大窗户线识别距离*/
//		public static var maxWindowLineDistance:Number = 120;
		/**墙体端点接合距离*/
		public static var wallJointDistance:Number = 100;
		/**只有一个端点与其他墙体链接的墙体，长度小于这个值将被剔除*/
		public static var wallCutLength:Number = 250;
		/**距离误差，两点的距离小于此值，判断为相等*/
		public static var distanceError:Number = 3;
		/**长度误差，当两条线的长度差的绝对值小于这个值时，判定为等长*/
		public static var lengthError:Number = 0.01;
		/**斜率误差，当两条线的斜率差的绝对值小于这个值时，判定为平行*/
		public static var slopeError:Number = 0.02;
		/**弧度误差，当两个弧度差的绝对值小于这个值时，判定为相等*/
		public static var radianError:Number = Math.PI / 180;
	}
}