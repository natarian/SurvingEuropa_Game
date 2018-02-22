package objects
{
	import flash.display.MovieClip;
	
	public class MissionControl extends building 
	{
		
		
		public function MissionControl() 
		{
			super(750);
			//initialize costs 
			cost$ = 5; //10,5,0,0,5,0
			costE = 5;
			costO = 0;
			costW = 0;
			costM = 0;
			costF = 0;
			//and production
			people = 0;
			space = 0; 
			prod$ = 2;
			prodE = -1;
			prodO = 0;
			prodW = 0;
			prodM = 0;
			prodF = 0;
		}
	}
	
}
