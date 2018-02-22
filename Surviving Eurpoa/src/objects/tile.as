package  objects
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import engine.IsometricObject;
	
	public class tile extends engine.IsometricObject
	{
		//tile properties variables
		////////////////////////////
		public var hasResource:Boolean;
		private var _resourceType:String;
		public var canBreak:Boolean;
		public var walkable:Boolean; //for raised tiles?
		public var canSel:Boolean;
		public var buildingType:String;
		public var tileType:String;
		////////////////////////////
		
		//variables for movement////
		////////////////////////////
		private var normalPos:Point;
		private var raisedPos:Point;
		//start/end y-pos
		private var y1:Number;
		private var y2:Number;
		//selector variables
		public var chosen:Boolean;
		private var over:Boolean;
		//movements
		public var riseUp:Tween;
		public var riseStart:Tween;
		public var fadeStart:Tween;
		////////////////////////////
		
		
		public function tile() 
		{
			buildingType = "blank";
			gotoAndStop(1);
			//can select
			canSel = true;
			//cannot brea most tiles except tiles with resource unerneath
			canBreak = false;
			//set chosen to false
			chosen = false;
			over = false;
			//set that this tile is not occupied
			this.occupied = false;
			//calculate depth height 
			this.depHeight = 0;
			//tile type affects different objects in certain ways
			tileType = "regular";
			if (this is tile101)
				tileType = "thin ice";
			if  (this is tile103 || this is tile104)
				tileType = "rocky";
			//add starting event listeners
			
			//resources
			hasResource = false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		private function onAdd(event:Event):void
		{
			//set base positions for movement
			y1 = y;
			y2 = y - 25;
			
			//raise/fade tile
			riseStart = new Tween(this, "y", Regular.easeIn,500, y1, (coord.x / 2 + coord.y * 1.5 + 2) / 5, true);
			fadeStart = new Tween(this, "alpha", Regular.easeIn, 0, 1, (coord.x / 2 + coord.y * 1.5 + 3) / 5, true);
			riseStart.start();
			fadeStart.start();
			
			riseStart.addEventListener(TweenEvent.MOTION_FINISH, startFinish);
			removeEventListener(Event.ADDED_TO_STAGE, onAdd);
		}
		private function onRemoved(event:Event):void
		{
			removeEventListener(MouseEvent.MOUSE_OVER, update1);
			removeEventListener(MouseEvent.MOUSE_OUT, update2);
			stage.removeEventListener(MouseEvent.CLICK, sel);
		}
		private function startFinish(event:TweenEvent):void
		{
			addEventListener(MouseEvent.MOUSE_OVER, update1);
			addEventListener(MouseEvent.MOUSE_OUT, update2);
			stage.addEventListener(MouseEvent.CLICK, sel);
			riseStart.removeEventListener(TweenEvent.MOTION_FINISH, startFinish);
		}
		//tile select functions
		/////////////////////////////////////////////////////////
		private function update1(event:MouseEvent):void
		{
			if (canSel)
			{
				over = true;
			
				var ty1 = y;
				var ty2 = y2;
				
				riseUp = new Tween(this, "y", Regular.easeIn,ty1, y2, .5, true);
				riseUp.start();
				riseUp.addEventListener(TweenEvent.MOTION_FINISH, finishUp);
			}
			
		}
		private function update2(event:MouseEvent):void
		{
			if (canSel)
			{
				over = false;
				if (!chosen)
				{
				var ty1 = y1;
				var ty2 = y;
		
				riseUp = new Tween(this, "y", Regular.easeIn,ty2, y1, .5, true);
				riseUp.start();
				riseUp.addEventListener(TweenEvent.MOTION_FINISH, finishDown);
				}
			}
			
		}
		private function finishUp(event:TweenEvent):void
		{
			
			if (canSel)
			{
				riseUp.removeEventListener(TweenEvent.MOTION_FINISH, finishUp);
			}
		}
		private function finishDown(event:TweenEvent):void
		{
			if (canSel)
			{
				riseUp.removeEventListener(TweenEvent.MOTION_FINISH, finishDown);
			}
		}
		private function sel(event:MouseEvent):void
		{
			if (canSel)
			{
				if (!over)
				{
				chosen = false;
				var ty1 = y1;
				var ty2 = y;
	
				riseUp = new Tween(this, "y", Regular.easeIn,ty2, y1, .5, true);
				riseUp.start();
				riseUp.addEventListener(TweenEvent.MOTION_FINISH, finishDown);
				}
				else
				{
					chosen = true;
				}
				
				if (!this.occupied && chosen)
				{
					
				}
			}
			
		}
		/////////////////////////////////////////////////////////
	
		
		public function get resourceType():String
		{
			return _resourceType;
		}
		public function set resourceType(val:String):void
		{
			_resourceType = val;
		}
	}
	
}
