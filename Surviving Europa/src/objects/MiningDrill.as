package objects 
{
	import flash.display.MovieClip;
	
	public class MiningDrill extends building 
	{
		
		
		public function MiningDrill() 
		{
			super(450);
			//initialize costs 
			cost$ = 10;
			costE = 10;
			costO = 0;
			costW = 0;
			costM = 5;
			costF = 0;
			//and production
			people = 0;
			space = 0; 
			prod$ = 0;
			prodE = 0;
			prodO = 0;
			prodW = 0;
			prodM = 1;
			prodF = 0;
		}
	}
	
}
