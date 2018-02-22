package  engine
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import engine.*;
	import objects.*;
	
	public class IsometricWorld extends MovieClip
	{
		//_floor must be a 2 dimensional array (rows x cols)
		public var _floorData:Array;
		//tiles array
		public var _floorTiles:Array = new Array;
		//background and foreground tiles
		public var _extraTiles:Array = new Array;
		//objects is for game objects like walls, characters, whatever
		public var _objects:Array = new Array;
		//array for building objects
		private var _buildings:Array = new Array;
		//reference to currently selected point
		public var selTile:Point;
		
		public function IsometricWorld(fldata:Array) 
		{
			_floorData = fldata;
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		public function onAdded(event:Event):void
		{
			init();
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		public function init():void
		{
			createFloor();
			
			addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			addEventListener(Event.ENTER_FRAME, update);
		}
		function createFloor():void
		{
			//create background tiles
			
			
			//create game tiles
			for(var i:Number = 0; i < _floorData.length; i++)
			{
				_floorTiles[i] = new Array;
				for (var j:Number = 0; j < _floorData[i].length; j++)
				{
					var type:int = _floorData[i][j];
					var newTile:tile = new (getDefinitionByName("objects.tile" + type) as Class);
					newTile.coord = new Point(i,j);
					var pt:Point = IsometricUtils.tileTo2D((newTile.coord), newTile.tileSize);
					newTile.x = pt.x;
					newTile.y = pt.y; //- newTile.depHeight
					_floorTiles[i].push(newTile);
					addChild(newTile);
					
					if (type%100 >= 90)
					{
						newTile.hasResource = true;
						var temp:int = type%100 - 90;
						if (temp == 1)
							newTile.resourceType = "water_spout";
						else if(temp == 2)
							newTile.resourceType = "ore";
					}
					if (type == 101)
					{
						//water
						newTile.canBreak = true;
						//newTile.occupied = true;
					}
					if (type == 200) //raised tile
					{
						newTile.canSel = false;
						newTile.occupied = true;
						newTile.depHeight = 64;
					}
					if (type < 130 && type >= 120)
					{
						newTile.canSel = false;
						newTile.occupied = true;
					}
					
					//get tile info
					//trace(newTile.coord, newTile.depHeight, newTile.dir, newTile.depHeight, newTile.levelNum);
				}
			}
			
			//create foreground tiles
		}
		public function removeFloor():void
		{
			for(var i:Number = 0; i < _floorTiles.length; i++)
			{
				
				for (var j:Number = 0; j < _floorTiles[i].length; j++)
				{
					var tempTile:tile = _floorTiles[i][j] as tile;
					removeChild(tempTile);
				}
			}
			_floorTiles.splice(0,_floorTiles.length);
			for(var j2:int = 0; j2 < _objects.length; j2++)
			{
				var tempObj:IsometricObject = _objects[j2] as IsometricObject;
				removeChild(tempObj);
			}
			for(var k:int = 0; k < _buildings.length; k++)
			{
				var tempBuild:IsometricObject = _buildings[k] as IsometricObject;
				removeChild(tempBuild);
			}
		}
		function changeMap(newMap:Array):void
		{
			removeFloor();
			_floorData = newMap;
			createFloor();
		}
		
		public function addObjectTile(newObj:IsometricObject, loc:Point)
		{
			var locx = loc.x;
			var locy = loc.y;
			var tempTile:tile = _floorTiles[locx][locy] as tile;
			
			var objX:IsometricObject = newObj;
			objX.x = 0;
			objX.y = 0;
			tempTile.addChild(objX);
			tempTile.occupied = true;
		}
		// event listeners
		function update(event:Event):void
		{
			
			
			//var tempTile:tile = _floorTiles[tempPt.x][tempPt.y] as tile;
			//tempTile.riseUp.resume();
		}
		function onMove(event:MouseEvent):void
		{
			
		}
		public function tileIsSelected():Boolean
		{
			var temp:Boolean = false;
			for(var i:Number = 0; i < _floorTiles.length; i++)
			{
				
				for (var j:Number = 0; j < _floorTiles[i].length; j++)
				{
					var tempTile:tile = _floorTiles[i][j] as tile;
					if (tempTile.chosen)
						temp = true;
				}
			}
			return temp;
		}
		public function getTileSelected():Point
		{
			var temp:Point = new Point(0,0);
			for(var i:Number = 0; i < _floorTiles.length; i++)
			{
				
				for (var j:Number = 0; j < _floorTiles[i].length; j++)
				{
					var tempTile:tile = _floorTiles[i][j] as tile;
					if (tempTile.chosen)
						temp = tempTile.coord;
				}
			}
			return temp;
		}
		function sortObjects():void
		{
			_objects.sort(sortOnDepth, Array.NUMERIC);
			for (var i:int = 0; i < _objects.length; i++)
			{
				setChildIndex(_objects[i], numChildren - 1 - 1);
			}
		}
		private function sortOnDepth(objA:IsometricObject, objB:IsometricObject):Number
		{
			var dA:uint = objA.y;
			var dB:uint = objB.y;
			if(dA > dB)
				return 1;
			else if (dA < dB)
				return -1;
			else
				return 0;
		}
	}
	
}
