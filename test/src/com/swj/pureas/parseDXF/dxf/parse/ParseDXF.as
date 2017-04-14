package com.swj.pureas.parseDXF.dxf.parse
{
	import flash.geom.Point;
	

	public class ParseDXF
	{
		/**版本号,AC2021*/
		public var version:String;
		public var LayerList:Vector.<DxfLayer> = new Vector.<DxfLayer>();
		public var LineList:Vector.<DxfLine> = new Vector.<DxfLine>();
		public var ArcList:Vector.<DxfArc>=new Vector.<DxfArc>();
		public var EllipseList:Vector.<DxfEllipse> = new Vector.<DxfEllipse>();
		public var LwopolylineList:Vector.<DxfLwpolyline> = new Vector.<DxfLwpolyline>();
		public var SplineList:Vector.<DxfSpline>=new Vector.<DxfSpline>();
		private var str:Vector.<String> = new Vector.<String>();
		private var count:int;
		private var leftx:Number;
		private var lefty:Number;
		private var rightx:Number;
		private var righty:Number;
		/**文件的所有行*/
		private var fileLines:Vector.<String>;
		/**正在读取的文件行*/
		private var readLineIndex:int;
		
		private function trim(str : String) : String
		{
			if (str == null)
				return null;
			return str.replace(/^\s+|\s+/gs, '');
		}
		
		private function ReadLine():String
		{
			if(readLineIndex < fileLines.length)
			{
				return fileLines[readLineIndex++];
			}
			return null;
		}
		
		private function ReadPair():Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>();
			result.push(trim(ReadLine()));
			result.push(trim(ReadLine()));
			count += 2;
			return result;
		}
		
		public function Read(fileContext:String):void
		{
			if(!fileLines)
			{
				fileLines = new Vector.<String>();
				if(fileContext.indexOf("\r\n")!=-1)
				{
					fileContext = fileContext.replace(/\r\n/g,"\n");//将所有\r\n 的换行方式转换为\n
				}
				var lineArray:Array = fileContext.split("\n");
				for each(var line:String in lineArray)
				{
					fileLines.push(line);
				}
			}
			while(readLineIndex < fileLines.length)
			{
				str = ReadPair();
				if (str[1] == "SECTION")
				{
					str = ReadPair();
					switch (str[1])
					{
					case "HEADER": ReadHeader();
						break;
					case "TABLES": ReadTable();
						break;
					case "ENTITIES": ReadEntities();
						break;
					}
				}
			}
			count = 0;
			trace("读取完毕");
		}
		
		private function ReadTable():void
		{
			while (str[1] != "ENDSEC")
			{
				while (str[0] != "2" || str[1] != "LAYER")
				{
					str = ReadPair();
				}
				while (str[0] != "0" || str[1] != "LAYER")
				{
					str = ReadPair();
				}
				while (str[0] == "0" && str[1] == "LAYER")
				{
					ReadLAYER();
				}
				while (str[1] != "ENDSEC")
				{
					str = ReadPair();
				}
			}
		}
		
		private function ReadLAYER():void
		{
			var newlayer:DxfLayer = new DxfLayer();
			while (str[1] != "ENDTAB")
			{
				str = ReadPair();
				switch (str[0])
				{
				case "2": newlayer.name = str[1];
					break;
				case "62": newlayer.colornum = str[1];
					break;
				case "6": newlayer.lstyle = str[1];
					break;
				case "370": newlayer.lwidth = str[1];
					break;
				}
				if (str[0] == "0" && str[1] == "LAYER")
				{
					LayerList.push(newlayer);
					return;
				}
			}
			LayerList.push(newlayer);
		}
		
		private function ReadEntities():void
		{
			while (str[1] != "ENDSEC")
			{
				switch (str[1])
				{
				case "LINE": ReadLineSegment();
					break; 
				case "ARC": ReadArc();
					break;
				case "CIRCLE": ReadArc();
					break;
				case "ELLIPSE": ReadEllipse();
					break;
				case "LWPOLYLINE": ReadLwpolyline();
					break;
				case "SPLINE": ReadSpline();
					break;
				default: str = ReadPair();
					break;
				}
				
			}
		}
		
		private function ReadArc():void
		{
			var newarc:DxfArc = new DxfArc();
			while (str[1] != "ENDSEC")
			{
				str = ReadPair();
				switch (str[0])
				{
				case "8": newarc.LName = str[1];
					break;
				case "10": newarc.center.x = Number(str[1]);
					break;
				case "20": newarc.center.y = Number(str[1]);
					break;
				case "40": newarc.radiu = Number(str[1]);
					break;
				case "50": newarc.startAngle = Number(str[1]);
					break;
				case "51": newarc.endAngle = Number(str[1]);
					break;
				case "370": newarc.lwidth = str[1];
					break;
				case "0": ArcList.push(newarc);
					return;
				}
			}
		}
		
		/**读取线段*/
		private function ReadLineSegment():void
		{
			var newline:DxfLine = new DxfLine();
			while (str[1] != "ENDSEC")
			{
				str = ReadPair();
				switch (str[0])
				{
				case "8": newline.LName = str[1];
					break;
				case "10": newline.start.x = Number(str[1]);
					break;
				case "20": newline.start.y = Number(str[1]);
					break;
				case "11": newline.end.x = Number(str[1]);
					break;
				case "21": newline.end.y = Number(str[1]);
					break;
				case "62": newline.colornum = str[1];
					break;
				case "370": newline.lwidth = str[1];
					break;
				case "0": LineList.push(newline); 
					return;
				}
			}
		}
		
		private function ReadEllipse():void
		{
			var newellipse:DxfEllipse = new DxfEllipse();
			while (str[1] != "ENDSEC")
			{
				str = ReadPair();
				switch (str[0])
				{
				case "8": newellipse.LName = str[1];
					break;
				case "10": newellipse.center.x = Number(str[1]);
					break;
				case "20": newellipse.center.y = Number(str[1]);
					break;
				case "11": newellipse.delta.x = Number(str[1]);
					break;
				case "21": newellipse.delta.y = Number(str[1]);
					break;
				case "40": newellipse.radiu = Number(str[1]);
					break;
				case "41": newellipse.startAngle = Number(str[1]);
					break;
				case "42": newellipse.endAngle = Number(str[1]);
					break;
				case "370": newellipse.lwidth = str[1];
					break;
				case "0": EllipseList.push(newellipse);
					return;
				}
			}
		}
		
		private function ReadLwpolyline():void
		{
			var newlw:DxfLwpolyline = new DxfLwpolyline();
			var index:int = -1;
//			var context:String = "";
			while (str[1] != "ENDSEC")
			{
				str = ReadPair();
				switch (str[0])
				{
				case "8": 
					newlw.LName = str[1];
					break;
				case "370": 
					newlw.lwidth = str[1];
					break;
				case "62": 
					newlw.colornum = str[1];
					break;
				case "90": 
					newlw.pointCount = int(str[1]);
					newlw.points = new Vector.<Point>();
					for (var j:int = 0; j < newlw.pointCount; j++) 
					{
						newlw.points.push(new Point());
					}
					newlw.converxity = new Vector.<Number>(newlw.pointCount);
					break;
				case "70": newlw.flag = int(str[1]);
					break;
				case "10": 
					index++;
					newlw.points[index].x = Number(str[1]);
					break;
				case "20": 
					newlw.points[index].y = Number(str[1]);
					break;
				case "42": 
					newlw.converxity[index] = Number(str[1]);
					break;
				case "0": LwopolylineList.push(newlw); 
				return;
				}
			}
		}
		
		private function ReadSpline():void
		{
			var newspline:DxfSpline = new DxfSpline();
			while (str[1] != "ENDSEC")
			{
				str = ReadPair();
				switch (str[0])
				{
				case "8": newspline.LName = str[1];
					break;
				case "370": newspline.lwidth = str[1];
					break;
				case "62": newspline.colornum = str[1];
					break;
				case "70": newspline.flag = int(str[1]);
					break;
				case "74": newspline.count = int(str[1]);
					newspline.through = new Vector.<Point>(int(str[1]));
					for (var i:int = 0; i < newspline.through.length; i++) 
					{
						newspline.through.push(new Point());
					}
					break;
				case "12": newspline.startPoint.x = Number(str[1]);
					break;
				case "22": newspline.startPoint.y = Number(str[1]);
					break;
				case "13": newspline.endPoint.x = Number(str[1]);
					break;
				case "23": newspline.endPoint.y = Number(str[1]);
					break;
				case "11": 
					newspline.through[0].x = Number(str[1]);
					str = ReadPair();
					newspline.through[0].y = Number(str[1]);
					str = ReadPair();
					for(i=1;i<newspline.through.length;i++)
					{
						str=ReadPair();
						if(str[0]=="11")
						{
							newspline.through[i].x=Number(str[1]);
							i--;
						}
						else if(str[0]=="21")
						{
							newspline.through[i].y=Number(str[1]);
							i--;
						}
					}
					if(newspline.flag==11)
					{
						for(i=0;i<3;i++)
						{
							str=ReadPair();
						}
					}
					break;
				case "0": SplineList.push(newspline);
					return;
				}
			}
		}
		
		private function ReadHeader():void
		{
			while (str[1] != "ENDSEC")
			{
				str = ReadPair();
				switch (str[1])
				{
				case "$ACADVER"://CAD版本
					str = ReadPair();
					trace("Dxf version:"+str[1]);
					break;
				case "$EXTMIN": str = ReadPair();
					leftx = Number(str[1]);
					str = ReadPair();
					lefty = Number(str[1]);
					break;
				case "$EXTMAX": str = ReadPair();
					rightx = Number(str[1]);
					str = ReadPair();
					righty = Number(str[1]);
					break;
				}
			}
		}
	}
}
