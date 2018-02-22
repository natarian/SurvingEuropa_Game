package objects {
	
	import flash.display.MovieClip;
	
	
	public class PowerStation extends building {
		
		
		public function PowerStation() 
		{
			super(100);
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
			prodE = 1;
			prodO = 0;
			prodW = 0;
			prodM = 0;
			prodF = 0;
		}
	}
	
}
