package objects {
	
	import flash.display.MovieClip;
	
	
	public class IceDrill extends building {
		
		
		public function IceDrill() 
		{
			super(300);
			//initialize costs 
			cost$ = 5;
			costE = 5;
			costO = 0;
			costW = 0;
			costM = 1;
			costF = 0;
			//and production
			people = 0;
			space = 0; 
			prod$ = 0;
			prodE = 0;
			prodO = 0;
			prodW = 1;
			prodM = 0;
			prodF = 0;
		}
	}
	
}
