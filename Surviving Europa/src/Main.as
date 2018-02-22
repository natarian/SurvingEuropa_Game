package  {
	
	import flash.display.MovieClip;
	import engine.*;
	import objects.*;
	import flash.events.MouseEvent;
	
	public class Main extends MovieClip 
	{
		
		
		public function Main() 
		{
			
			
			playBtn.addEventListener(MouseEvent.MOUSE_UP, playButtonClick);
		}
		function playButtonClick(event:MouseEvent):void
		{
			gotoAndStop(1,"Game");
			var gameEngine:IsometricEngine = new IsometricEngine();
			addChild(gameEngine);
		}
	}
	
}
