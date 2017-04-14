package 
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	/**
	 *@author wangxiaolong
	 *2013-6-21
	 */
	
	public class NiCamera
	{
		private var m_vec3Pos:Vector3D;
		private var m_vec3At:Vector3D;
		private var m_vec3UPInit:Vector3D;
		private var m_vec3UP:Vector3D;
		private var m_vec3Right:Vector3D;
		private var m_vec3Dir:Vector3D;
		
		private var m_matView:Matrix3D;
		private var m_matPerspective:Matrix3D;
		private var m_vecData:Vector.<Number>;
		
		private var m_vecPos:Vector.<Number>;
		
		public function NiCamera()
		{
			m_matView = new Matrix3D;
			m_matPerspective = new Matrix3D;
			
			m_vecData = new Vector.<Number>( 16, true );
			
			m_vecPos = new Vector.<Number>( 4, true );
		}
		
		public function LookAtLH( vec3Eye:Vector3D, vec3At:Vector3D, vec3UP:Vector3D ):void
		{
			m_vec3Pos = vec3Eye;
			m_vec3At = vec3At;
			m_vec3UPInit = vec3UP;
			
			m_vec3Dir =  m_vec3At.subtract(m_vec3Pos);
			m_vec3Dir.normalize();
			m_vec3Dir.w = 0;
			
			m_vec3Right = m_vec3UPInit.crossProduct( m_vec3Dir );
			m_vec3Right.normalize();
			m_vec3Right.w = 0;
			
			m_vec3UP = m_vec3Dir.crossProduct( m_vec3Right );
			m_vec3UP.normalize();
			m_vec3UP.w = 0;
			
			UpdateCameraMatrix( );
		}
		
		public function PerspectiveFieldOfViewLH( iFildViewOfY:int, iWidth:int, iHeight:int, dZNear:Number, dZFar:Number ):void
		{
			var dFV:Number = iFildViewOfY * Math.PI / 180;
			
			var tY:Number = 1.0 / Math.tan( dFV * 0.5 );
			var tX:Number = iHeight / iWidth * tY;
			var tZ:Number = dZFar / ( dZFar - dZNear );
			var dZ:Number = -dZFar * dZNear / ( dZFar - dZNear );
			
			var vecData:Vector.<Number> = Vector.<Number>([
					tX,  0,  0, 0,
					 0, tY,  0, 0,
					 0,  0, tZ, 1,
					 0,  0, dZ, 0		
				]);
			
			m_matPerspective.identity();
			m_matPerspective.copyRawDataFrom( vecData, 0, false );
		}
		
		public function get perspectiveMatrix():Matrix3D
		{
			return m_matPerspective;
		}
		
		public function get viewMatrix():Matrix3D
		{
			return m_matView;
		}
		
		public function get cameraPos():Vector.<Number>
		{
			m_vecPos[0] = m_vec3Pos.x;
			m_vecPos[1] = m_vec3Pos.y;
			m_vecPos[2] = m_vec3Pos.z;
			m_vecPos[3] = 1;
			
			return m_vecPos;
		}
		
		private function UpdateCameraMatrix():void
		{
			var vec3Temp:Vector3D;
			
			m_vec3Dir.normalize();
			
			vec3Temp = m_vec3Dir.crossProduct( m_vec3Right );
			m_vec3UP.copyFrom( vec3Temp );
			m_vec3UP.normalize();
			
			vec3Temp = m_vec3UP.crossProduct( m_vec3Dir );
			m_vec3Right.copyFrom( vec3Temp );
			m_vec3Right.normalize();
			
			var dTX:Number = -m_vec3Right.dotProduct( m_vec3Pos );
			var dTY:Number = -m_vec3UP.dotProduct( m_vec3Pos );
			var dTZ:Number = -m_vec3Dir.dotProduct( m_vec3Pos );
			
			m_vecData[0] = m_vec3Right.x;
			m_vecData[4] = m_vec3Right.y;
			m_vecData[8] = m_vec3Right.z;
			m_vecData[12] = dTX;
			
			m_vecData[1] = m_vec3UP.x;
			m_vecData[5] = m_vec3UP.y;
			m_vecData[9] = m_vec3UP.z;
			m_vecData[13] = dTY;
			
			m_vecData[2] = m_vec3Dir.x;
			m_vecData[6] = m_vec3Dir.y;
			m_vecData[10] = m_vec3Dir.z;
			m_vecData[14] = dTZ;
			
			m_vecData[3] = 0;
			m_vecData[7] = 0;
			m_vecData[11] = 0;
			m_vecData[15] = 1;
			
			m_matView.copyRawDataFrom( m_vecData, 0, false );
		}
		
		public function AppendRotation( dAngle:Number, strAxis:String  ):void
		{
			var mat:Matrix3D = new Matrix3D;
			mat.identity();
			
			var vec3Temp:Vector3D;
			
			switch( strAxis )
			{
				case 'X':
					mat.appendRotation( dAngle, m_vec3Right );
					TransformVector( mat, m_vec3UP );
					TransformVector( mat, m_vec3Dir );
					break;
				case 'Y':
					mat.appendRotation( dAngle, m_vec3UP );
					TransformVector(mat, m_vec3Right );
					TransformVector(mat, m_vec3Dir );
					break;
				case 'Z':
					mat.appendRotation( dAngle, m_vec3Dir );
					TransformVector(mat, m_vec3Right );
					TransformVector(mat, m_vec3UP );
					break;
			}
			
			UpdateCameraMatrix();
		}
		
		public function Forward( dSpeed:Number ):void
		{
			m_vec3Pos.x += m_vec3Dir.x * dSpeed;
			m_vec3Pos.y += m_vec3Dir.y * dSpeed;
			m_vec3Pos.z += m_vec3Dir.z * dSpeed;
			
			UpdateCameraMatrix();
		}
		
		public function Back( dSpeed:Number ):void
		{
			m_vec3Pos.x += -m_vec3Dir.x * dSpeed;
			m_vec3Pos.y += -m_vec3Dir.y * dSpeed;
			m_vec3Pos.z += -m_vec3Dir.z * dSpeed;
			
			UpdateCameraMatrix();
		}
		
		private function TransformVector( mat:Matrix3D, vec3:Vector3D ):void
		{
			var vec3Temp:Vector3D = mat.deltaTransformVector( vec3 );
			
			vec3.copyFrom( vec3Temp );
		}
		
	}
}