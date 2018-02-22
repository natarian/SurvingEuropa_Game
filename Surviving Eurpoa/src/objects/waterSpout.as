package  objects{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class waterSpout extends MovieClip 
	{
		
		private var clouds:Array = new Array;
		
		public function waterSpout() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			addEventListener(Event.ENTER_FRAME, onNewFrame);
			
		}
		public function onAdded(event:Event):void
		{
			addEventListener(Event.ENTER_FRAME, onNewFrame);
		}
		public function onRemoved(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onNewFrame);
		}

		public function onNewFrame(event:Event):void
		{
			
			var c:steam = new steam();
			addChild(c);
			c.x = 64;
			c.y = 10;
			clouds.push(c);
			for(var i:int = 0; i < clouds.length; i++)
			{
				var tc:steam = clouds[i] as steam;
				tc.y -=3;
				tc.alpha -=.025;
				tc.x += Math.random()*5;
				tc.x -= Math.random()*5;
				if (tc.alpha < .05)
				{
					clouds.splice(i, 1);
					removeChild(tc);
				}
			}
		}
	}
	
}
