package objects {
	
	import flash.display.MovieClip;
	
	
	public class HabitationModule extends building {
		
		
		public function HabitationModule() 
		{
			super(0);
			//initialize costs 
			cost$ = 5;
			costE = 5;
			costO = 0;
			costW = 0;
			costM = 0;
			costF = 0;
			//and production
			people = 0;
			space = 0; 
			prod$ = 0;
			prodE = 0;
			prodO = 0;
			prodW = 0;
			prodM = 0;
			prodF = 0;
		}
	}
	
}
