package  objects
{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import engine.IsometricObject;
	
	
	public class building extends engine.IsometricObject
	{
		public var buildLevel:int;
		
		//building costs
		public var cost$:int;
		public var costE:int;
		public var costO:int;
		public var costFd:int;
		public var costW:int;
		public var costM:int;
		public var costF:int;
		//private var _cost[whatever]:int;
		
		//building productions
		public var people:int;
		public var space:int; 
		public var prod$:int;
		public var prodE:int;
		public var prodO:int;
		public var prodFd:int;
		public var prodW:int;
		public var prodM:int;
		public var prodF:int;
		
		
		public var timeFrame:int;
		public var counter:int = 0;
		
		
		
		//counter object
		public var counterBar:ProgressTimer;
		public var secondBar:ProgressTimer;
		
		private var placedVal:int = 120;
		private var counterStart:int;
		public var isPlaced:Boolean;
		
		public function building(time:int) 
		{
			//set time frame
			timeFrame = time;
			counter = 0;
			//define that its a building
			//as part of isoObj
			this.isBuilding = true;
			//set building level to 1
			buildLevel = 1;
			gotoAndPlay(buildLevel);
			//wait for animation to drop building
			isPlaced = false;
			//init counter object, timeFrame = frames to fill, true to go up/false to count down
			counterBar = new ProgressTimer(timeFrame,true);
			secondBar = new ProgressTimer(timeFrame,true);
			
			//change bar color per building type
			adjustColor();

			//initialize listener
			addEventListener(Event.ENTER_FRAME, waitForPlace);
			
			//initialize costs 
			cost$ = 0;
			costE = 0;
			costO = 0;
			costFd = 0;
			costW = 0;
			costM = 0;
			costF = 0;
			//and production
			people = 0;
			space = 0; 
			prod$ = 0;
			prodE = 0;
			prodO = 0;
			prodFd =0;
			prodW = 0;
			prodM = 0;
			prodF = 0;
		}
		
		public function waitForPlace(event:Event)
		{
			//trace(this, counterStart, placedVal);
			counterStart++;
			if(counterStart >= placedVal)
			{
				isPlaced = true;
				//this.visible = true;
				addChild(counterBar);
				counterBar.x = 7;
				counterBar.rotation = 28;
				counterBar.y = 45;
				counterBar.width = 67;
				
				addChild(secondBar);
				//turn it upsidedown
				secondBar.width = 67;
				secondBar.scaleY = -1;
				//secondBar.scaleY = 1;
				//position it
				secondBar.x = 117;
				secondBar.y = 47;
				secondBar.rotation = 180-28;
				
				
				setChildIndex(counterBar, numChildren-1);
				setChildIndex(secondBar, numChildren-1);
				counterStart = 0;
				addEventListener(Event.ADDED, onChange);
				removeEventListener(Event.ENTER_FRAME, waitForPlace);
			}
		
		}
		public function changeTime(nt:int):void
		{
			timeFrame = nt;
			counterBar = new ProgressTimer(timeFrame,true);
			secondBar = new ProgressTimer(timeFrame,true);
			adjustColor();
		}
		
		public function adjustColor():void
		{
			if(this is MissionControl)
			{
				counterBar.changeColor(0x00aa00);
				secondBar.changeColor(0x00aa00);
			}
			else if(this is PowerStation)
			{
				counterBar.changeColor(0xffff00);
				secondBar.changeColor(0xffff00);
			}
			else if (this is IceDrill)
			{
				counterBar.changeColor(0x3333ff);
				secondBar.changeColor(0x3333ff);
			}
			else if (this is HydroponicsFarm)
			{
				counterBar.changeColor(0x55ff55);
				secondBar.changeColor(0x55ff55);
			}
			else if (this is ElectrolysisStation)
			{
				counterBar.changeColor(0x4444ff);
				secondBar.changeColor(0x4444ff);
			}
		}
		function onChange(event:Event):void //update bars position in front of everything
		{
			setChildIndex(counterBar, numChildren-1);
			setChildIndex(secondBar, numChildren-1);
		}
		
		//public functions
		public function subtractCosts(temp:Array):Array
		{
			var subTemp:Array = new Array(people, 
										  space * buildLevel,
										  cost$ * buildLevel,
										  costE * buildLevel,
										  costO * buildLevel,
										  costFd * buildLevel,
										  costW * buildLevel,
										  costM * buildLevel,
										  costF * buildLevel);
			return subtractArrays(temp,subTemp);
		}
		public function sellBuilding(temp:Array):Array
		{
			var subTemp:Array = new Array(people, 
										  space * buildLevel *.5,
										  cost$ * buildLevel *.5,
										  costE * buildLevel *.5,
										  costO * buildLevel *.5,
										  costFd * buildLevel *.5,
										  costW * buildLevel *.5,
										  costM * buildLevel *.5,
										  costF * buildLevel *.5);
			return addArrays(temp,subTemp);
		}
		
		public function addResources(temp:Array):Array
		{
			var subTemp:Array = new Array(people, 
										  space * buildLevel,
										  prod$ * buildLevel,
										  prodE * buildLevel,
										  prodO * buildLevel,
										  prodFd * buildLevel,
										  prodW * buildLevel,
										  prodM * buildLevel,
										  prodF * buildLevel);
			return addArrays(temp,subTemp);
		}
		public function canBuild(temp:Array):Boolean
		{
			var bool:Boolean = false;
			var subTemp:Array = new Array(people, 
										  space * buildLevel,
										  cost$ * buildLevel,
										  costE * buildLevel,
										  costO * buildLevel,
										  costFd * buildLevel,
										  costW * buildLevel,
										  costM * buildLevel,
										  costF * buildLevel);
			var botTemp:Array = new Array(0,0,0,0,0,0,0,0,0);
			if (arrayOverZero(subtractArrays(temp,subTemp)))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		public function canUpgrade(temp:Array):Boolean
		{
			var bool:Boolean = false;
			var subTemp:Array = new Array(people, 
										  space * buildLevel,
										  cost$ * buildLevel,
										  costE * buildLevel,
										  costO * buildLevel,
										  costFd * buildLevel,
										  costW * buildLevel,
										  costM * buildLevel,
										  costF * buildLevel);
			var botTemp:Array = new Array(0,0,0,0,0,0,0,0,0);
			if (arrayOverZero(subtractArrays(temp,subTemp)))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		//utility
		private function subtractArrays(a1:Array, a2:Array):Array
		{
			var temp:Array = new Array();
			if (a1.length == a2.length)
			{
				for(var i:int = 0; i < a1.length; i++)
				{
					temp[i] = a1[i] - a2[i];
				}
			}
			else
				trace("incompatible arrays: /n" + a1 + "/n" + a2);
			return temp;
		}
		private function addArrays(a1:Array, a2:Array):Array
		{
			var temp:Array = new Array();
			if (a1.length == a2.length)
			{
				for(var i:int = 0; i < a1.length; i++)
				{
					temp[i] = a1[i] + a2[i];
				}
			}
			else
				trace("incompatible arrays: /n" + a1 + "/n" + a2);
			return temp;
		}
		private function arrayOverZero(a:Array):Boolean
		{
			var temp:Boolean = true;
			for (var i:int = 0; i < a.length; i++)
			{
				if(a[i] <0)
				{
					temp = false;
				}
				
			}
			return temp;
		}
	}
	
}
