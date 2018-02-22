package  objects
{
	
	public class maps {
		
		/*
		
		*/

		public static const std:Array =	new Array(new Array(200,200,200, 200, 200, 200),
												  new Array(200,100,102, 100, 103, 100),
												  new Array(200,192,100, 100, 101, 103),
												  new Array(200,100,103, 101, 101, 104),
												  new Array(200,100,100, 101, 101, 100),
												  new Array(200,104,100, 102, 191, 100)
								  				);
												
		public static const lvl1:Array =	new Array(new Array(125,126,126,126,126,127),
													  new Array(124,100,102,103,100,122),
												  	  new Array(124,103,100,104,100,122),
												  	  new Array(124,100,103,100,103,122),
												  	  new Array(124,104,100,104,100,122),
													  new Array(123,120,120,120,120,121)
												);
		public static const lvl2:Array =	new Array(new Array(125,126,126,126,126,127),
													  new Array(124,100,102,103,100,122),
												  	  new Array(124,103,101,101,100,122),
												  	  new Array(124,100,101,101,103,122),
												  	  new Array(124,104,100,104,100,122),
													  new Array(123,120,120,120,120,121)
												);
		//starting resources //(pop, max pop, money, energy, oxygen, food, water, metal, fuel)
		public static const StartingResources:Array = new Array(new Array(0,0,0,0,0,0,0,0,0),
																new Array(0,50,50,50,50,50,50,50,50),
																new Array(0,2,10,10,10,10,2,5,0)
																);
		
		
		//objectives: must be an array, then each level has an array of objectives
		/*
		objectives list
		checkBuilding - (1, building type, required level)
		checkResource - (2, resource number, amount)
		checkContact - (3, 0);
		*/
		//descriptoions
		public static const levelNames:Array = new Array("No such level",
														 "Establish a Colony",
														 "Find Water on Europa"
														 );
		
		public static const lvl1Obj1D:String = "Click any tile, then build a Mission Control center";
		public static const lvl1Obj2D:String = "Click on your Mission Control. \n -send a message home to tell them what you've accomlished.";
		
		public static const lvl2Obj1D:String = "It looks like we had a water leak on the way here, place an Ice Drill to gather water.";
		public static const lvl2Obj2D:String = "Click on your Ice Drill. \n -try upgrading it to produce more water.";
		public static const lvl2Obj3D:String = "Wait until you have 10 gallons of water.";
		
		//level 1 obectives
		public static const lvl1Obj1:Array = new Array(1, MissionControl, 0);
		public static const lvl1Obj2:Array = new Array(3, 0);
		//level 2 obectives
		public static const lvl2Obj1:Array = new Array(1,IceDrill,0);
		public static const lvl2Obj2:Array = new Array(1,IceDrill,2);
		public static const lvl2Obj3:Array = new Array(2, 6, 10);
		//objectives list: each array is a level
		public static const objectives:Array = new Array(new Array(lvl1Obj1, lvl1Obj2),
														 new Array(lvl2Obj1, lvl2Obj2, lvl2Obj3)
														 );
		//objecives description
		public static const objectiveDescription:Array = new Array(new Array(lvl1Obj1D, lvl1Obj2D),
														 		   new Array(lvl2Obj1D, lvl2Obj2D, lvl2Obj3D)
														 		   );
		
		//list of levels in load-order
		public static const levels:Array = new Array(std, lvl1, lvl2);
		
		public static function getObj(l:int, o:int):String
		{
			return objectiveDescription[l-1][o-1];
		}
		public static function getStartingResources(n:int):Array
		{
			return StartingResources[n];
		}

	}
	
}
