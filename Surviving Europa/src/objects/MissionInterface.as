package objects {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	public class MissionInterface extends MovieClip {
		
		public var opened:Boolean;
		
		public function MissionInterface() 
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
		public function onToggle(event:MouseEvent):void
		{
			if (opened == false)
				raise();
			else
				lower();
		}
		public function raise():void
		{
			moveMenu = new Tween(this,"x", Regular.easeOut, 230, 0, 1, true);
			moveMenu.start();
			opened = true;
		}
		public function lower():void
		{
			moveMenu = new Tween(this,"x", Regular.easeOut, 0, 230, 1, true);
			moveMenu.start();
			opened = false;
		}
		
		public function changeMessage(str:String):void
		{
			mission.text = str;
			if(!opened)
				raise();
		}
	}
	
}
