package  engine
{
	import flash.geom.Point;
	
	public class IsometricUtils 
	{
		// this is a utility class
		// do not create it directly
		
		public static function to2D(pt:Point):Point
		{
			var tempPt:Point = new Point(0,0);
			tempPt.x = (2 * pt.y + pt.x) / 2;
			tempPt.y = (2 * pt.y - pt.x) / 2;
			return tempPt;
		}
		public static function toIso(pt:Point):Point
		{
			var tempPt:Point = new Point(0,0);
			tempPt.x = (pt.x - pt.y);
			tempPt.y = (pt.y + pt.x) / 2;
			return tempPt;
		}
		public static function getTileCoordinates(pt:Point, tileSide:Number):Point
		{
			//use tile size as the length of one side of the square
			//pretending it were 2d not isometric
			
			var point = new Point(0,0);
			point = pt;
			point = to2D(pt);
			//divide point coordinte by tile size
			point.x = Math.floor(point.x / tileSide);
			point.y = Math.floor(point.y / tileSide);
			return point;
		}
		public static function tileTo2D(pt:Point, tileIsoSize:Number):Point
		{
			var tempPt:Point = new Point(0,0);
			tempPt.x = pt.x * tileIsoSize;
			tempPt.y = pt.y * tileIsoSize;
			tempPt = toIso(tempPt);
			return tempPt;
			
		}
	}
	
}
