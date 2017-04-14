package 
{
	/**
	 *@author wangxiaolong
	 *2013-6-19
	 */
	
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	
	public class TestPointLight extends Sprite
	{
		private var VIEW_WIDTH:int = 1000;
		private var VIEW_HEIGHT:int = 700;
		
		private var m_kContext3D:Context3D;
		private var m_kProgram3D:Program3D;
		
		private var m_kTextureBricks:Texture;
		
		[Embed(source="res/bricks.jpg")]
		private var m_claBMBricks:Class;
		
		[Embed(source="res/teaport.obj", mimeType="application/octet-stream")]
		private var m_claObjTeaport:Class;
		
		private var m_kTeaportModel:Stage3dObjParser;
		
		//
		private var m_kModelMatrix:Matrix3D;
		private var m_matFinal:Matrix3D;
		
		private var m_kCamera:NiCamera;
		
		private var m_dDelta:Number = 0;
		private var m_uiLastTime:uint;
		private var m_uiTick:uint;
		
		
		public function TestPointLight()
		{
			stage.stage3Ds[0].addEventListener( Event.CONTEXT3D_CREATE, OnContextComplete );
			stage.stage3Ds[0].requestContext3D();
		}
		
		private function OnContextComplete( evt:Event ):void
		{
			var kStage3D:Stage3D = evt.target as Stage3D;
			
			m_kContext3D = kStage3D.context3D;
			m_kContext3D.configureBackBuffer( VIEW_WIDTH, VIEW_HEIGHT, 16, true );
			m_kContext3D.setCulling( Context3DTriangleFace.BACK );
			m_kContext3D.setDepthTest( true, Context3DCompareMode.LESS_EQUAL );
			m_kContext3D.setBlendFactors( Context3DBlendFactor.SOURCE_COLOR, Context3DBlendFactor.ZERO );
			
			m_kProgram3D = m_kContext3D.createProgram();
			
			InitShader();
			
			InitData();
			
			m_uiLastTime = getTimer();
			
			if( hasEventListener(Event.ENTER_FRAME) )
			{
				removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
			}
			addEventListener( Event.ENTER_FRAME, OnEnterFrame );
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, OnKeyDown );
		}
		
		private function InitShader():void
		{
			// LightPos        : vc0
			// LightColor      : vc1
			// ModelViewProj   : vc2
			// Model           : vc6
			// NormalMatrix    : vc10
			
			var strVertexAGAL:String = 
				'm44 op, va0, vc2 \n' +	
				'mov v1, va1 \n' +	// uv
				
				// 因为Demo里光源是不动的，所以这里没有对光源进行世界变换
				// 否则后面要对光源进行世界变换
				
				// 这里用到的点，是世界变换后的点，而不是投影变换后的点
				// 世界变换后的顶点到光源的向量 vt1
				'm44 vt0, va0, vc6 \n' +
				'sub vt1, vc0, vt0 \n' +
				'nrm vt1.xyz, vt1.xyz \n' +
				
				// Normal 变换并单位化 vt2
				'm33 vt2.xyz, va2.xyz, vc10 \n' +
				'nrm vt2.xyz, vt2.xyz \n' +
				
				'dp3 vt3.x, vt1.xyz, vt2.xyz \n' +	// 点积 CosA = L . Normal
				'sat vt3.x, vt3.x \n' +
				'mul vt4.rgb, vc1.rgb, vt3.xxx \n' +  // 这里只是粗略的用 CosA*LightColor当作顶点颜色
				'mov v2, vt4.rgb \n';
			
			var strPixelAGAL:String = 
				'tex ft0, v1, fs0<2d, repeat, liner, nomip> \n' +
				'mul ft0, ft0, v2 \n' +	
				'mov oc, ft0 \n';
			
			var kVertexAS:AGALMiniAssembler = new AGALMiniAssembler(true);
			kVertexAS.assemble( Context3DProgramType.VERTEX, strVertexAGAL );
			
			var kPixelAS:AGALMiniAssembler = new AGALMiniAssembler(true)
			kPixelAS.assemble( Context3DProgramType.FRAGMENT, strPixelAGAL );
			
			m_kProgram3D.upload( kVertexAS.agalcode, kPixelAS.agalcode );
		}
		
		private function InitData():void
		{
			m_kTeaportModel = new Stage3dObjParser( m_claObjTeaport, m_kContext3D, 1, true, true );
			
			var kBM:Bitmap = new m_claBMBricks;
			m_kTextureBricks = m_kContext3D.createTexture( kBM.bitmapData.width, kBM.bitmapData.height, Context3DTextureFormat.BGRA, false );
			m_kTextureBricks.uploadFromBitmapData( kBM.bitmapData );
			kBM.bitmapData.dispose();
			
			m_kModelMatrix = new Matrix3D;
			m_matFinal = new Matrix3D;
			
			m_kCamera = new NiCamera;
			m_kCamera.LookAtLH( new Vector3D(0, 0, -10), new Vector3D(0, 0, 0), new Vector3D(0, 1, 0) );
			m_kCamera.PerspectiveFieldOfViewLH( 45, VIEW_WIDTH, VIEW_HEIGHT, 1, 5000 );
		}
		
		private function OnEnterFrame( evt:Event ):void
		{
			m_dDelta += 0.6;
			
			m_kContext3D.clear( 0, 0, 0 );
			
			DrawTeaport();
			
			m_kContext3D.present();
		}
		
		private function DrawTeaport():void
		{
			m_kContext3D.setProgram( m_kProgram3D );
			
			m_kContext3D.setTextureAt( 0, m_kTextureBricks );
			
			m_kContext3D.setVertexBufferAt( 0, m_kTeaportModel.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
			m_kContext3D.setVertexBufferAt( 1, m_kTeaportModel.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2 ); 
			m_kContext3D.setVertexBufferAt( 2, m_kTeaportModel.normalsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
			
			// Matrix
			m_kModelMatrix.identity();
			m_kModelMatrix.appendRotation( m_dDelta, Vector3D.Y_AXIS );
			m_kModelMatrix.appendTranslation( 0, 0, 50 );
			
			// Light Pos
			m_kContext3D.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 0, Vector.<Number>([0, 0, 0, 1]), 1 );
			// Light Color
			m_kContext3D.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 1, Vector.<Number>([1, 1, 1, 1]), 1 );
			
			// ModelViewProj Matrix
			m_matFinal.identity();
			m_matFinal.append( m_kModelMatrix );
			m_matFinal.append( m_kCamera.viewMatrix );	
			m_matFinal.append( m_kCamera.perspectiveMatrix );
			m_kContext3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 2, m_matFinal, true );
			
			// Model Matrix
			m_matFinal.identity();
			m_matFinal.append( m_kModelMatrix );
			m_kContext3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 6, m_matFinal, true );
			
			// Normal Matrix
			m_matFinal.identity();
			m_matFinal.append( m_kModelMatrix );
			var vecData:Vector.<Number> = m_matFinal.rawData;
			vecData[3] = 0;
			vecData[7] = 0;
			vecData[11] = 0;
			vecData[15] = 1;
			vecData[12] = 0;
			vecData[13] = 0;
			vecData[14] = 0;
			m_matFinal.copyRawDataFrom( vecData );
			m_matFinal.invert();
			m_kContext3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 10, m_matFinal, false );
			
			m_kContext3D.drawTriangles( m_kTeaportModel.indexBuffer, 0, m_kTeaportModel.indexBufferCount );
		}
		
		private function OnKeyDown( evt:KeyboardEvent ):void
		{
			switch( evt.keyCode )
			{
				case Keyboard.W:
					m_kCamera.AppendRotation( -1, 'X' );
					break;
				case Keyboard.S:
					m_kCamera.AppendRotation( 1, 'X' );
					break;
				case Keyboard.A:
					m_kCamera.AppendRotation( -1, 'Y' );
					break;
				case Keyboard.D:
					m_kCamera.AppendRotation( 1, 'Y' );
					break;
				case Keyboard.Q:
					m_kCamera.AppendRotation( 1, 'Z' );
					break;
				case Keyboard.E:
					m_kCamera.AppendRotation( -1, 'Z' );
					break;
				case Keyboard.J:
					m_kCamera.Forward( 1 );
					break;
				case Keyboard.K:
					m_kCamera.Back( 1 );
					break;
			}
		}
		
	}
}