package  objects{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Counter extends MovieClip 
	{
		public var maxLength:int = 60;
		public var countTo:int;
		public var count:int;
		
		public function Counter(val:int) 
		{
			countTo = val;
			count = 0;
			//addEventListener(Event.ENTER_FRAME, onNewFrame);
		}
		function onNewFrame(event:Event):void
		{
			count++;
			this.width = (count/countTo) * maxLength;
			if (count> countTo)
			count = 0;
			
		}
	}
	
}
