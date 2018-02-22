/* example code to use this in main
		
		var thing:ProgressBar
		
		thing = new ProgressTimer(100);
		addChild(thing);
		
		//set x and y
		
		var nc:uint= uint("0x00ff00");
		thing.changeColor(nc);
*/

package objects {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	
	public class ProgressTimer extends MovieClip 
	{
		//variables
		private var timeEnd:int; 		//max time
		private var currTime:int 		//current time
		private var finished:Boolean; 	//when timer bar is full
		private var barMaxLength:int;	//total length of bar
		private var colTran:ColorTransform;
		private var up:Boolean;
		private var freezed:Boolean;
		
		public function ProgressTimer(te:int, dir:Boolean) 
		{
			//initialize variables
			timeEnd = te;
			up = dir;
			currTime = 0;
			barMaxLength = width -12;
			finished = false;
			freezed = false;
			colTran = new ColorTransform();
			
			//the rest needs to wait until it is on the stage
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		function onAdded(event:Event):void
		{
			if (up)
			bar.width = 0; //set bar to starting position
			else
			bar.width = barMaxLength;
			
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
			if (currTime < timeEnd) // if it is not full
				{
					if (!freezed)
					currTime++;
				}
			else
				finished = true;
			
			if (up)
			{
				//size of bar
				bar.width = (currTime / timeEnd) * barMaxLength;
			}
			else
			{
				//size of bar
				bar.width = barMaxLength - ((currTime / timeEnd) * barMaxLength);
			}
		}
		
		//////////////////
		//public functions
		//////////////////
		public function freeze():void
		{
			freezed =  true;
		}
		public function unFreeze():void
		{
			freezed = false;
		}
		public function resetBar():void
		{
			finished = false;
			currTime = 0;
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
