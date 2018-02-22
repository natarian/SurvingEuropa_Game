package objects {
	
	import flash.display.MovieClip;
	
	
	public class ElectrolysisStation extends building {
		
		
		public function ElectrolysisStation() 
		{
			super(600);
			//initialize costs 
			cost$ = 10;
			costE = 5;
			costO = 0;
			costW = 0;
			costM = 5;
			costF = 0;
			//and production
			people = 0;
			space = 0; 
			prod$ = 0;
			prodE = 0;
			prodO = 1;
			prodW = -1;
			prodM = 0;
			prodF = 1;
		}
	}
	
}
