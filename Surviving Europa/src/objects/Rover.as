package objects 
{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import fl.motion.easing.Back;
	
	import engine.*;
	
	public class Rover extends MovieClip 
	{
		public var moveSpeed:int;
		public var dir:String;
		public var atTarg:Boolean;
		public var laserType:String;
		private var w:IsometricWorld;
		
		private var loc:tile;
		private var targLoc:tile;
		
		private var moveInProgress:Boolean;
		
		public function Rover(tw:IsometricWorld) 
		{
			moveInProgress = false;
			w = tw;
			moveSpeed = 2;
			dir = "S";
			gotoAndStop(dir);
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		function onAdded(event:Event):void
		{						
			loc = parent as tile;
			loc.occupied = true;
			targLoc = parent as tile;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyIsDown);
			//addEventListener(Event.ENTER_FRAME, update); // not using update currently
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			//addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		function onRemoved(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, update);
			removeEventListener(Event.ADDED_TO_STAGE, onRemoved);
		}
		
		function moveNorth():void
		{
			targLoc = w._floorTiles[loc.coord.x][loc.coord.y-1] as tile;
			if(loc.coord.y >0 && !targLoc.occupied)//if not near north edge
			{
				dir = "S";
				gotoAndStop(dir);
				moveInProgress = true;
				atTarg = false;
				removeEventListener(Event.ENTER_FRAME, goEast);
				removeEventListener(Event.ENTER_FRAME, goWest);
				removeEventListener(Event.ENTER_FRAME, goSouth);
				addEventListener(Event.ENTER_FRAME, goNorth);
			}
		}
		function moveSouth():void
		{
			targLoc = w._floorTiles[loc.coord.x][loc.coord.y+1] as tile;
			if(loc.coord.y < w._floorTiles[loc.coord.x].length-1 && !targLoc.occupied)//if not near south edge
			{
				dir = "S";
				gotoAndStop(dir);
				targLoc.addChild(this);
				x = 64;
				y = -32;
				moveInProgress = true;
				atTarg = false;
				removeEventListener(Event.ENTER_FRAME, goEast);
				removeEventListener(Event.ENTER_FRAME, goWest);
				removeEventListener(Event.ENTER_FRAME, goNorth);
				addEventListener(Event.ENTER_FRAME, goSouth);
			}
		}
		function moveEast():void
		{
			targLoc = w._floorTiles[loc.coord.x+1][loc.coord.y] as tile;
			if(loc.coord.x < w._floorTiles.length && !targLoc.occupied)//if not near north edge
			{
				dir = "E";
				gotoAndStop(dir);
				targLoc.addChild(this);
				x = -64;
				y = -32;
				moveInProgress = true;
				atTarg = false;
				removeEventListener(Event.ENTER_FRAME, goNorth);
				removeEventListener(Event.ENTER_FRAME, goSouth);
				removeEventListener(Event.ENTER_FRAME, goWest);
				addEventListener(Event.ENTER_FRAME, goEast);
			}
		}
		function moveWest():void
		{
			targLoc = w._floorTiles[loc.coord.x-1][loc.coord.y] as tile;
			if(loc.coord.x >0 && !targLoc.occupied)//if not near north edge
			{
				dir = "E";
				gotoAndStop(dir);
				moveInProgress = true;
				atTarg = false;
				removeEventListener(Event.ENTER_FRAME, goNorth);
				removeEventListener(Event.ENTER_FRAME, goSouth);
				removeEventListener(Event.ENTER_FRAME, goEast);
				addEventListener(Event.ENTER_FRAME, goWest);
			}
		}
		function goNorth(event:Event):void
		{
			x+= moveSpeed;
			y-= moveSpeed / 2;
			var dx:Number = Math.abs(x -64);
			var dy:Number = Math.abs(y +32);
			var d:Number = Math.sqrt(dx*dx + dy*dy);
			if(d < 4)
			{
				d = 100;
				loc.occupied = false;
				targLoc.occupied = true;
				targLoc.addChild(this);
				x = 0;
				y = 0;
				loc = parent as tile;
				targLoc = null;
				moveInProgress = false;
				atTarg = true;
				removeEventListener(Event.ENTER_FRAME, goNorth);
			}
		}
		function goSouth(event:Event):void
		{
			x-= moveSpeed;
			y+= moveSpeed / 2;
			var dx:Number = Math.abs(x);
			var dy:Number = Math.abs(y);
			var d:Number = Math.sqrt(dx*dx + dy*dy);
			if(d < 4)
			{
				d = 100;
				loc.occupied = false;
				targLoc.occupied = true;
				x = 0;
				y = 0;
				moveInProgress = false;
				loc = targLoc as tile;
				targLoc = null;
				removeEventListener(Event.ENTER_FRAME, goSouth);
			}
		}
		function goWest(event:Event):void
		{
			x-= moveSpeed;
			y-= moveSpeed / 2;
			var dx:Number = Math.abs(x +64);
			var dy:Number = Math.abs(y +32);
			var d:Number = Math.sqrt(dx*dx + dy*dy);
			if(d < 4)
			{
				d = 100;
				loc.occupied = false;
				targLoc.occupied = true;
				targLoc.addChild(this);
				x = 0;
				y = 0;
				loc = parent as tile;
				targLoc = null;
				moveInProgress = false;
				atTarg = true;
				removeEventListener(Event.ENTER_FRAME, goWest);
			}
		}
		function goEast(event:Event):void
		{
			x+= moveSpeed;
			y+= moveSpeed / 2;
			var dx:Number = Math.abs(x);
			var dy:Number = Math.abs(y);
			var d:Number = Math.sqrt(dx*dx + dy*dy);
			if(d < 4)
			{
				d = 100;
				loc.occupied = false;
				targLoc.occupied = true;
				x = 0;
				y = 0;
				moveInProgress = false;
				loc = targLoc as tile;
				targLoc = null;
				removeEventListener(Event.ENTER_FRAME, goEast)
			}
		}
		
		function keyIsDown(event:KeyboardEvent):void
		{
			if (moveInProgress == false)
			{
				if(event.keyCode == Keyboard.UP)
				{
					moveNorth();
				}
				else if(event.keyCode == Keyboard.DOWN)
				{
					moveSouth();
				}
				else if(event.keyCode == Keyboard.RIGHT)
				{
					moveEast();
				}
				else if(event.keyCode == Keyboard.LEFT)
				{
					moveWest();
				}
			}
		}
		
		
		
		
		
		
		
		
		
		function moveTile(t1:tile, t2:tile):void // t1 and t2 are adjacent t1 is current
		{
			moveInProgress = true;
			atTarg = false;
			
			
			if (t1.coord.x <= t2.coord.x) // targ is to the right
			{
				x += moveSpeed;
				t2.addChild(this);
				x = 0;
				y = 0;
			}
			else // targ is to the left
			{
				trace("left");
				x -= moveSpeed;
				x= 0;
				y = 0;
			}
			if (t1.coord.y <= t2.coord.y) //targ is below
			{
				y += moveSpeed / 2;
				t2.addChild(this);
				x= 0;
				y = 0;
			}
			else //targ is top
			{
				trace("top");
				y -= moveSpeed / 2;
				x= 0;
				y = 0;
			}
			
			
		}
		public function update(event:Event):void
		{
			var goto:String = dir + laserType;
			gotoAndStop(goto);
		}

	}
	
}
