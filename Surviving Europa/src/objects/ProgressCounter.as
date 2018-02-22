package objects {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	
	public class ProgressCounter extends MovieClip {
		
		//variables
		public var timeEnd:int; 		//max time
		public var currTime:int 		//current time
		private var finished:Boolean; 	//when timer bar is full
		private var barMaxHeight:int;	//total length of bar
		private var colTran:ColorTransform;
		
		public function ProgressCounter(te:int)
		{
			//initialize variables
			timeEnd = te;
			currTime = 0;
			barMaxHeight = height -2;
			finished = false;
			colTran = new ColorTransform();
			//add listener for moving bar
			addEventListener(Event.ENTER_FRAME, onEnter);
			//the rest needs to wait until it is on the stage
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		function onAdded(event:Event):void
		{
			//set bar to starting position
			
			//add listener for moving bar
			addEventListener(Event.ENTER_FRAME, onEnter);
			//add listener for when it is removed
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		function onRemoved(event:Event):void
		{
			//remove listener for moving bar
			removeEventListener(Event.ENTER_FRAME, onEnter)
		}
		function onEnter(event:Event):void
		{
			if (currTime >= timeEnd) // if it is not full
			{
				finished = true;
				currTime = timeEnd;
				changeColor(0x00ff00);
			}
			else
			{
				finished = false;
				changeColor(0xffffff);
			}
			bar.height= ((currTime / timeEnd) * barMaxHeight);
		}

		//////////////////
		//public functions
		//////////////////
		public function updateAmount(amt:int):void
		{
			currTime = amt;
		}
		public function resetBar():void
		{
			finished = false;
			changeColor(0xffffff);
			//currTime = 0;
		}
		//get if it is full
		public function isFinished():Boolean
		{
			return finished;
		}
		//change bar color
		public function changeColor(c:uint):void
		{
			colTran.color = c;
			bar.transform.colorTransform = colTran;
		}
	}
	
}