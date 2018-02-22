package objects {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	public class MessageBoard extends MovieClip 
	{
		public var opened:Boolean;
		
		public function MessageBoard() 
		{
			opened = true;
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		function onAdded(event:Event):void
		{
			togBtn.addEventListener(MouseEvent.CLICK, onToggle);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		function onRemoved(event:Event):void
		{
			//do something idk
		}
		//raise or lower menu
		var moveMenu:Tween;
		function onToggle(event:MouseEvent):void
		{
			if (opened == false)
				raise();
			else
				lower();
		}
		public function raise():void
		{
			moveMenu = new Tween(this,"y", None.easeNone, 75, 0, .5, true);
			moveMenu.start();
			opened = !opened;
		}
		public function lower():void
		{
			moveMenu = new Tween(this,"y", None.easeNone, 0, 75, .5, true);
			moveMenu.start();
			opened = !opened;
		}
		
		//public functions
		public function changeMessage(str:String):void
		{
			messageText.text = str;
			if(!opened)
				raise();
		}
	}
	
}
