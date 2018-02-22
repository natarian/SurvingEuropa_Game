/*
	swag
*/
package  engine
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class IsometricObject extends MovieClip
	{
		private var _coord:Point;
		private var _depHeight:Number;
		private var _dir:String;
		private var _occupied:Boolean;
		private var _isBuilding:Boolean;
		
		// which level the object is on
		public var levelNum:int;
		
		//size of tile assuming std 64x32
		private const _tileSize:Number = 64;
		

		public function IsometricObject() 
		{
			_isBuilding = false;
		}
		
		// getters and setter
		public function get coord():Point
		{
			if (_coord == null)
			return IsometricUtils.getTileCoordinates(new Point(this.x, this.y), _tileSize);
			else
			return _coord;
		}
		public function set coord(pt:Point):void
		{
			_coord = pt;
		}
		public function get depHeight():Number
		{
			//assuming the tile is square 
			return height - 32;
		}
		public function set depHeight(val:Number):void
		{
			_depHeight = val;
		}
		public function get dir():String
		{
			return _dir;
		}
		public function get occupied():Boolean
		{
			return _occupied;
		}
		public function set occupied(val:Boolean):void
		{
			_occupied = val;
		}
		public function get tileSize():Number
		{
			return _tileSize;
		}
		public function get isBuilding():Boolean
		{
			return _isBuilding;
		}
		public function set isBuilding(val:Boolean):void
		{
			_isBuilding = val;
		}
	}
	
}
