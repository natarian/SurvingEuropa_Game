package objects {
	
	import flash.display.MovieClip;
	
	
	public class HydroponicsFarm extends building {
		
		
		public function HydroponicsFarm() 
		{
			super(320);
			//initialize costs 
			cost$ = 10; 
			costE = 10;
			costO = 0;
			costFd = 5;
			costW = 5;
			costM = 0;
			costF = 0;
			//and production
			people = 0;
			space = 0; 
			prod$ = 0;
			prodE = 0;
			prodO = 0; //Math.round(Math.random())
			prodFd = 1;
			prodW = 0;
			prodM = 0;
			prodF = 0;
		}
	}
	
}
