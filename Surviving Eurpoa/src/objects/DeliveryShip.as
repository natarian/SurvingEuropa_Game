package objects
{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class DeliveryShip extends MovieClip {
		
		private var count:int = 240;
		private var current:int;
		
		public function DeliveryShip() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		function onAdded(event:Event):void
		{
			addEventListener(Event.ENTER_FRAME, onNewFrame);
			current = 0;
		}
		function onNewFrame(event:Event):void
		{
			current++;
			if (current >= count)
			{
				removeEventListener(Event.ENTER_FRAME, onNewFrame);
				this.visible = false;
			}
		}
	}
	
}
