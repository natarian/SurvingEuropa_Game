/*
	requirements
	-tile000, tile 001, tile100 + etc
*/
package  engine
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	
	import engine.*;
	import objects.*;
	
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import flash.sampler.StackFrame;
	import fl.motion.easing.Back;
	import fl.motion.Tweenables;
	import flash.utils.Timer;
	import flash.ui.Mouse;
	
	public class IsometricEngine extends MovieClip
	{
		//variables
		private var world:IsometricWorld;
		
		//user interface menus
		private var bi:BuildInterface;
		private var ui:UpgradeInterface;
		private var ri:ResourceInterface;
		private var ti:ToolInterface;
		private var mi:MissionInterface;
		private var mci:MissionControlInterface;
		private var mb:MessageBoard;
		
		//resource storage progress bars
		private var es:ProgressCounter; //energy storage
		private var fds:ProgressCounter; //food storage
		private var ws:ProgressCounter; //water storage
		private var os:ProgressCounter; //oxygen storage
		private var ms:ProgressCounter; //metal storage
		private var fls:ProgressCounter; //fuel storage
		
		//resourcedepletion bars for human necessities
		private var eb:ProgressTimer; //energy bar
		private var ob:ProgressTimer; //oxygen bar
		private var fb:ProgressTimer; //food bar
		private var wb:ProgressTimer; //water bar
		//timer for using resources
		private var useTimer:ProgressTimer;
		
		//delivery ship
		private var ds:DeliveryShip;
		private var deliveryInProgress:Boolean;
		//rover
		private var rov:Rover;
		//tiles
		private var pt:tile;
		private var tt:tile;		//currently selected "Temporary Tile"
		//resources
		public var population:int
		public var maxPop:int;
		public var money:int;
		public var energy:int; 
		public var oxygen:int; 
		public var food:int;
		public var water:int;
		public var metal:int;
		public var fuel:int;
		//resource array
		public var resourceArray:Array = new Array();
		//building array
		private var buildings:Array = new Array();
		//get on my level
		public var levelNum:int;
		public var dayNum:int;
		public var objNum:int;
		
		//game checks
		private var isStart:Boolean;
		private var landerPlaced:Boolean;
		private var earthContacted:Boolean;
		
		//tools mode
		private var toolMode:String;
		
		public function IsometricEngine() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		function onAdded(event:Event):void
		{
			//initialize
			init();
		}
		//initialize resources, world, etc
		function init():void
		{
			//assign values to resources
			levelNum = 1;
			dayNum = 1;
			objNum = 1;
			
			
			isStart = false;
			toolMode = "build";
			landerPlaced = false;
			earthContacted = false;
			deliveryInProgress = false;
			
			//ui elements
			bi = new BuildInterface();
			ui = new UpgradeInterface();
			ri = new ResourceInterface();
			mi = new MissionInterface();
			mci = new MissionControlInterface();
			mb = new MessageBoard();
			
			//resource progress bars
			es = new ProgressCounter(20);
			fds = new ProgressCounter(10);
			ws = new ProgressCounter(10);
			os = new ProgressCounter(10);
			ms = new ProgressCounter(10);
			fls = new ProgressCounter(5);
			
			//set resources
			setResources(maps.getStartingResources(levelNum));
			
			//resource use progress bar for vitals(oxygen, food, water)
			useTimer = new ProgressTimer(2500,true);
			
			bi.description.text = "Building Description: Hover over any of the buttons at the bottom of the screen for a description.";
			mi.mission.text = "null";
			
			world = new IsometricWorld(maps.levels[levelNum]);
			
			world.x = stage.stageWidth / 2 - 64;
			world.y = (stage.stageHeight / 2) - (world.height / 2) - 100;
			addChild(world);
			addChild(ri);
			addChild(es); //add energy storage bar;
			addChild(ws); //add water storage bar;
			addChild(os); //add oxygen storage bar;
			addChild(ms); //add metal storage bar;
			addChild(fds); //add food storage bar;
			addChild(fls); //add fuel storage bar;
			addChild(mi);
			addChild(mb);
			addChild(useTimer);
			
			//position bars
			es.x = ri.energyText.x + 66; //these are not in order
			fds.x = ri.foodText.x + 70;
			ws.x = ri.waterText.x + 70;
			os.x = ri.oxygenText.x + 68;
			ms.x = ri.metalText.x + 73;
			fls.x = ri.fuelText.x + 73;
			es.y = 40;
			fds.y = 40;
			ws.y = 40;
			os.y = 40;
			ms.y = 40;
			fls.y = 40;
			es.rotation = 90;
			fds.rotation = 90;
			ws.rotation = 90;
			os.rotation = 90;
			ms.rotation = 90;
			fls.rotation = 90;
			
			useTimer.x = 17;
			useTimer.y = 40;
			useTimer.changeColor(0x000000);
			
			//set cost texts
			clearCosts();
			
			//welcome player
			mb.changeMessage("Welcome to Europa, Captain!");
			//show level name
			mi.levelName.text = maps.levelNames[levelNum];
			
			//reset button
			ri.resetBtn.addEventListener(MouseEvent.CLICK, resetLevel);
			//to place the lander ((((((((((((probably has to get moved))))))))))))
			world.addEventListener(MouseEvent.CLICK, placeLander);			
			
			//tool functions
			//ti.buildBtn.addEventListener(MouseEvent.CLICK, buildBtnClick);
			//drag function
			stage.addEventListener(MouseEvent.MOUSE_DOWN, isDown);
			//for tile functions
			//world.addEventListener(MouseEvent.CLICK, clickHandler);
			//update
			addEventListener(Event.ENTER_FRAME, update);
			//get rid of addedToStage
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		//add or remove engine
		//remove engine
		public function disableEngine():void
		{
			world.removeFloor();
			this.removeChildren(0,numChildren);
			removeEventListener(Event.ENTER_FRAME, update);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, isDown);
		}
		//enable engine after removal
		public function enableEngine():void
		{
			init();
		}
		//drag functions
		function isDown(event:MouseEvent):void
		{
			world.startDrag(false);
			stage.addEventListener(MouseEvent.MOUSE_UP, isUp);
		}
		function isUp(event:MouseEvent):void
		{
			world.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, isUp);
		}
		
		//update events
		//tile selected functions
		function update(event:Event):void
		{
			//resource manging
			if (resourceArray[0] != null) //dont even know what this does
			{
				population = resourceArray[0];
				maxPop = resourceArray[1];
				money = resourceArray[2];
				energy = resourceArray[3];
				oxygen = resourceArray[4];
				food = resourceArray[5];
				water = resourceArray[6];
				metal = resourceArray[7];
				fuel = resourceArray[8];				
			}
			ri.PopText.text = population.toString() + "/" + maxPop.toString();
			ri.moneyText.text = money.toString();
			ri.energyText.text = energy.toString();
			ri.oxygenText.text = oxygen.toString();
			ri.foodText.text = food.toString();
			ri.waterText.text = water.toString();
			ri.metalText.text = metal.toString();
			ri.fuelText.text = fuel.toString();
			ri.levelText.text = "Level: " + levelNum.toString();
			ri.dayText.text = dayNum.toString();
			resourceArray = [population, maxPop, money,energy, oxygen, food, water, metal, fuel];
			
			//update resource bars
			es.updateAmount(resourceArray[3]);
			os.updateAmount(resourceArray[4]);
			fds.updateAmount(resourceArray[5]);
			ws.updateAmount(resourceArray[6]);
			ms.updateAmount(resourceArray[7]);
			fls.updateAmount(resourceArray[8]);
			
			//tile functions
			//if a tile is selected, start the tile 
			//build/ upgrade/ whatever functions
			
			
			if (!landerPlaced) //////////fix it - until the lander is placed this will stay open and keep opening if you close it
			{
				mi.changeMessage("Click anywhere on the map to land on the surface!");
			}
			else // for tile selection stuff such as building things or upgrading buildings
			{
				var tis:Boolean = world.tileIsSelected();
				if(tis) // show specific menu depending on what is selected
				{				
					//tt
					var tileCoord:Point = world.getTileSelected();
					var Tile:tile = world._floorTiles[tileCoord.x][tileCoord.y] as tile;
					if (tt != Tile)
						tt = Tile;
					
					//check for build mode
				if (toolMode == "build")
					{
						//build menu for empty tiles
						if (!Tile.occupied && !Tile.hasResource)
						{
							activateMenu("build_blank");
						}
						// upgrade menu for building tiles
						else if(Tile.occupied && Tile.isBuilding)
						{
							if(Tile.buildingType == "MissionControl")
							   {
								   activateMenu("upgrade_MissionControl");
							   }
							else 
								activateMenu("upgrade_general");
							
						}
						// build menu for resource tiles
						else if (!Tile.occupied && Tile.hasResource)
						{
							if (Tile.resourceType == "ore")
							activateMenu("build_res_ore");
						}
					}
				else if (toolMode == "")
				{
					//add modes here
				}	
				}
				else //remove all menus if nothing is selected
				{
					deactivateMenu();
				}
			}
			
			//produce materials
			for (var a:int = 0; a < buildings.length; a++)
			{
				var b:building = new building(0);
				b = getBuildType(b,a);
				//more buildings...
				
				//counter
				if (b.isPlaced)
				{
					
					if(b.counterBar.isFinished()) // produce and reset
					{
						resourceArray = b.addResources(resourceArray);
						b.counterBar.resetBar();
						b.secondBar.resetBar();
					}
					//check with storage first
					if(b is PowerStation) //if energy storage is full, stop power stations from producing energy
					{
						if (resourceArray[3] >= es.timeEnd)
						{
							b.counterBar.freeze();
							b.secondBar.freeze();
						}
						else
						{
							b.counterBar.unFreeze();
							b.secondBar.unFreeze();
						}
					}
					if(b is HydroponicsFarm) //if food storage is full, stop power stations from producing food
					{
						if (resourceArray[5] >= fds.timeEnd)
						{
							b.counterBar.freeze();
							b.secondBar.freeze();
						}
						else
						{
							b.counterBar.unFreeze();
							b.secondBar.unFreeze();
						}
					}
					if(b is IceDrill) //if water storage is full, stop power stations from producing water
					{
						if (resourceArray[6] >= ws.timeEnd)
						{
							b.counterBar.freeze();
							b.secondBar.freeze();
						}
						else
						{
							b.counterBar.unFreeze();
							b.secondBar.unFreeze();
						}
					}
					if(b is MiningDrill) //if metal storage is full, stop production
					{
						if (resourceArray[7] >= ms.timeEnd)
						{
							b.counterBar.freeze();
							b.secondBar.freeze();
						}
						else
						{
							b.counterBar.unFreeze();
							b.secondBar.unFreeze();
						}
					}
					if(b is ElectrolysisStation) //if oxygen storage is full, stop production
					{
						if (resourceArray[4] >= ws.timeEnd)
						{
							b.counterBar.freeze();
							b.secondBar.freeze();
						}
						else
						{
							b.counterBar.unFreeze();
							b.secondBar.unFreeze();
						}
					}

				}
			}
			
			//use vital resources
			if(useTimer.isFinished())
			{
				//use resources
				//(oxygen = 4, foood = 5, water = 6 || population = 0)
				resourceArray[4] -= resourceArray[0];
				resourceArray[5] -= resourceArray[0];
				resourceArray[6] -= resourceArray[0];
				useTimer.resetBar();
				
				//change day
				dayNum++;
			}
			if(resourceArray[0] < 1)
				useTimer.freeze();
			else
				useTimer.unFreeze();
			//change color of bar
			for(var n:int = 4; n < 7; n++)
			{
				if (resourceArray[n] <= (resourceArray[0]*4) && resourceArray[n] > (resourceArray[0]*3))
				{
					//change color to yellow
					if(n==5)
					fds.changeColor(0xffff00);
					else if (n==6)
					ws.changeColor(0xffff00);
					else if (n==4)
					os.changeColor(0xffff00);
				}
				else if (resourceArray[n] <= (resourceArray[0]*3))
				{
					//change to red
					if(n==5)
					fds.changeColor(0xff0000);
					else if (n==6)
					ws.changeColor(0xff0000);
					else if (n==4)
					os.changeColor(0xff0000);
				}
				else if (resourceArray[n] > (resourceArray[0]*4))
				{
					//change to white
					if(n==5)
					{
						if (fds.isFinished())
							fds.changeColor(0x00ff00);
						else
							fds.changeColor(0xffffff);
					}
					else if(n==6)
					{
						if (ws.isFinished())
							ws.changeColor(0x00ff00);
						else
							ws.changeColor(0xffffff);
					}
					else if(n==4)
					{
						if (os.isFinished())
							os.changeColor(0x00ff00);
						else
							os.changeColor(0xffffff);
					}
				}
			}
			
			//check win
			if (checkObjective(maps.objectives[levelNum -1][objNum-1]))
				{
					objNum++;
					updateMission(maps.getObj(levelNum, objNum));
				}
			if (checkWin(maps.objectives[levelNum -1]))
			{
				trace("level won");
				nextLevel();
			}
		}
		//tool bar
		function buildBtnClick(event:MouseEvent):void
		{
			toolMode = "build";
		}
		
		/////build utilities
		//build a mission control
		function mcBtnClick(event:MouseEvent):void
		{
			//add mc
			var mc:MissionControl = new MissionControl();
			buildings.push(mc);
			if (mc.canBuild(resourceArray) && !deliveryInProgress && resourceArray[0] < resourceArray[1])
			{
				tt.addChild(mc);
				tt.occupied = true;
				tt.walkable = false;
				tt.isBuilding = true;
				tt.buildingType = "MissionControl";
				
				//increase population
				resourceArray[0]++;
				
				//call delivery ship
				makeDelivery();
				//subtract funds
				resourceArray = mc.subtractCosts(resourceArray);
				
				//destroy menu
				bi.enabled = false;
				bi.visible = false;
				//bi.remove listener
				bi.mcBtn.removeEventListener(MouseEvent.CLICK, mcBtnClick);
			}
			else
			{
				if(!mc.canBuild(resourceArray))
					mb.changeMessage("You don't have enough resources to build this, captain. You can either wait for them to be produced or reset your level to try again.");
				if(resourceArray[0] >= resourceArray[1])
					mb.changeMessage("You don't have enough space for any more colonists. Most buildings bring at least one person to operate it.");
				if(deliveryInProgress)
					mb.changeMessage("It looks like there was still a delivery in progress, you have to wait until the ship returns before ordering something else.");			
			}
			
		}
		//mission control button mouse_over
		function mcBtnOver(event:MouseEvent):void
		{
			bi.description.text = "Mission Control: You must place one of these, it is the center of your colony. It allows you to carry our further tasks and build new things.";
			//cost description
			var b:MissionControl = new MissionControl();
			showCosts(b);
			//show schematic
			bi.schematic.gotoAndStop(2); //show mission control schematic
		}
		//build a power station
		function psBtnClick(event:MouseEvent):void
		{
			//add ps
			var ps:PowerStation = new PowerStation();
			buildings.push(ps);
			if (ps.canBuild(resourceArray) && !deliveryInProgress && resourceArray[0] < resourceArray[1])
			{
				tt.addChild(ps);
				tt.occupied = true;
				tt.walkable = false;
				tt.isBuilding = true;
				
				//increase population
				resourceArray[0]++;
				
				makeDelivery();
				
				//subtract funds
				resourceArray = ps.subtractCosts(resourceArray);
				
				//destroy menu
				bi.enabled = false;
				bi.visible = false;
				//bi.remove listener
				bi.mcBtn.removeEventListener(MouseEvent.CLICK, mcBtnClick);
			}
			else
			{
				if(!ps.canBuild(resourceArray))
					mb.changeMessage("You don't have enough resources to build this, captain. You can either wait for them to be produced or reset your level to try again.");
				if(resourceArray[0] >= resourceArray[1])
					mb.changeMessage("You don't have enough space for any more colonists. Most buildings bring at least one person to operate it.");
				if(deliveryInProgress)
					mb.changeMessage("It looks like there was still a delivery in progress, you have to wait until the ship returns before ordering something else.");
			}
			
		}
		//power station button mouse_over
		function psBtnOver(event:MouseEvent):void
		{
			bi.description.text = "Power Station: This building is necessary to generate electricity for your base.";
			var b:PowerStation = new PowerStation();
			showCosts(b);
			//show schematic
			bi.schematic.gotoAndStop(3); //show schematic
		}
		//build a mine
		function mdBtnClick(event:MouseEvent):void
		{
			//add mine
			var md:MiningDrill = new MiningDrill();
			buildings.push(md);
			if (md.canBuild(resourceArray) && !deliveryInProgress && resourceArray[0] < resourceArray[1])
			{
				tt.addChild(md);
				tt.occupied = true;
				tt.walkable = false;
				tt.isBuilding = true;
				
				//increase population
				resourceArray[0]++;
				
				makeDelivery();
				
				//subtract funds
				resourceArray = md.subtractCosts(resourceArray);
				
				//destroy menu
				bi.enabled = false;
				bi.visible = false;
				//bi.remove listener
				bi.mdBtn.removeEventListener(MouseEvent.CLICK, mdBtnClick);
			}
			else
			{
				if(!md.canBuild(resourceArray))
					mb.changeMessage("You don't have enough resources to build this, captain. You can either wait for them to be produced or reset your level to try again.");
				if(resourceArray[0] >= resourceArray[1])
					mb.changeMessage("You don't have enough space for any more colonists. Most buildings bring at least one person to operate it.");
				if(deliveryInProgress)
					mb.changeMessage("It looks like there was still a delivery in progress, you have to wait until the ship returns before ordering something else.");
			}
		}
		//mining drill button mouse_over
		function mdBtnOver(event:MouseEvent):void
		{
			bi.description.text = "Mining Drill: Build one of these to mine the silicate mineral. This can only be placed on tiles with ore on them.";
			//cost description
			var b:MiningDrill = new MiningDrill();
			showCosts(b);
			//show schematic
			bi.schematic.gotoAndStop(5);
		}
		//ice drill placement and description
		function idBtnClick(event:MouseEvent):void
		{
			//add ice drill
			var id:IceDrill = new IceDrill();
			buildings.push(id);
			if (id.canBuild(resourceArray) && !deliveryInProgress && resourceArray[0] < resourceArray[1])
			{
				tt.addChild(id);
				tt.occupied = true;
				tt.walkable = false;
				tt.isBuilding = true;
				tt.buildingType = "IceDrill";
				
				//increase population
				resourceArray[0]++;
				
				//call delivery ship
				makeDelivery();
				//subtract funds
				resourceArray = id.subtractCosts(resourceArray);
				
				//check if it is a good tile type for this
				if (tt.tileType == "thin ice")
				{
					mb.changeMessage("This is a good place to find water, it looks like there is a lot of water under the surface. Production increased 25%");
					id.changeTime(id.timeFrame * .75);
				}
				
				//destroy menu
				bi.enabled = false;
				bi.visible = false;
				//bi.remove listener
				bi.idBtn.removeEventListener(MouseEvent.CLICK, idBtnClick);
			}
			else
			{
				if(!id.canBuild(resourceArray))
					mb.changeMessage("You don't have enough resources to build this, captain. You can either wait for them to be produced or reset your level to try again.");
				if(resourceArray[0] >= resourceArray[1])
					mb.changeMessage("You don't have enough space for any more colonists. Most buildings bring at least one person to operate it.");
				if(deliveryInProgress)
					mb.changeMessage("It looks like there was still a delivery in progress, you have to wait until the ship returns before ordering something else.");
			}
		}
		function idBtnOver(event:MouseEvent):void
		{
			bi.description.text = "Ice Drill: Place this on any empty tile to drill into the ice to attempt to extract water. The drill is fragile and may break easily.";
			//cost description
			var b:IceDrill = new IceDrill();
			showCosts(b);
			//show schematic
			bi.schematic.gotoAndStop(4); 
		}
		//Hydroponics Farm placement and description
		function hfBtnClick(event:MouseEvent):void
		{
			//add hydroponics farm
			var hf:HydroponicsFarm = new HydroponicsFarm();
			buildings.push(hf);
			if (hf.canBuild(resourceArray) && !deliveryInProgress && resourceArray[0] < resourceArray[1])
			{
				tt.addChild(hf);
				tt.occupied = true;
				tt.walkable = false;
				tt.isBuilding = true;
				tt.buildingType = "HydroponicsFarm";
				
				//increase population
				resourceArray[0]++;
				
				//call delivery ship
				makeDelivery();
				//subtract funds
				resourceArray = hf.subtractCosts(resourceArray);
				
				//destroy menu
				bi.enabled = false;
				bi.visible = false;
				//bi.remove listener
				bi.hfBtn.removeEventListener(MouseEvent.CLICK, hfBtnClick);
			}
			else
			{
				if(!hf.canBuild(resourceArray))
					mb.changeMessage("You don't have enough resources to build this, captain. You can either wait for them to be produced or reset your level to try again.");
				if(resourceArray[0] >= resourceArray[1])
					mb.changeMessage("You don't have enough space for any more colonists. Most buildings bring at least one person to operate it.");
				if(deliveryInProgress)
					mb.changeMessage("It looks like there was still a delivery in progress, you have to wait until the ship returns before ordering something else.");
			}
		}
		function hfBtnOver(event:MouseEvent):void
		{
			bi.description.text = "Hydroponics Farm: This building uses water and energy to produce food and oxygen.";
			//cost description
			var b:HydroponicsFarm = new HydroponicsFarm();
			showCosts(b);
			//show schematic
			bi.schematic.gotoAndStop(9); 
		}
		//Electrolysis Station placement and description
		function elsBtnClick(event:MouseEvent):void
		{
			//add ElectrolysisStation
			var els:ElectrolysisStation = new ElectrolysisStation();
			buildings.push(els);
			if (els.canBuild(resourceArray) && !deliveryInProgress && resourceArray[0] < resourceArray[1])
			{
				tt.addChild(els);
				tt.occupied = true;
				tt.walkable = false;
				tt.isBuilding = true;
				tt.buildingType = "ElectrolysisSystem";
				
				//increase population
				resourceArray[0]++;
				
				//call delivery ship
				makeDelivery();
				//subtract funds
				resourceArray = els.subtractCosts(resourceArray);
				
				//destroy menu
				bi.enabled = false;
				bi.visible = false;
				//bi.remove listener
				bi.esBtn.removeEventListener(MouseEvent.CLICK, elsBtnClick);
			}
			else
			{
				if(!els.canBuild(resourceArray))
					mb.changeMessage("You don't have enough resources to build this, captain. You can either wait for them to be produced or reset your level to try again.");
				if(resourceArray[0] >= resourceArray[1])
					mb.changeMessage("You don't have enough space for any more colonists. Most buildings bring at least one person to operate it.");
				if(deliveryInProgress)
					mb.changeMessage("It looks like there was still a delivery in progress, you have to wait until the ship returns before ordering something else.");
			}
		}
		function elsBtnOver(event:MouseEvent):void
		{
			bi.description.text = "Electrolysis Station: This complex unit splits apart water molecules into oxygen gas and hydrogen fuel.";
			//cost description
			var b:ElectrolysisStation = new ElectrolysisStation();
			showCosts(b);
			//show schematic
			bi.schematic.gotoAndStop(6); //show schematic
		}
		//Habitation Module placement and description
		function hmBtnClick(event:MouseEvent):void
		{
			//add HabitationModule
			var hm:HabitationModule = new HabitationModule();
			buildings.push(hm);
			if (hm.canBuild(resourceArray) && !deliveryInProgress && resourceArray[0] < resourceArray[1])
			{
				tt.addChild(hm);
				tt.occupied = true;
				tt.walkable = false;
				tt.isBuilding = true;
				tt.buildingType = "HabitationModule";
				
				//increase population
				resourceArray[0]++;
				
				//call delivery ship
				makeDelivery();
				//subtract funds
				resourceArray = hm.subtractCosts(resourceArray);
				
				//increase maximum population
				resourceArray[1] += 3;
				
				//destroy menu
				bi.enabled = false;
				bi.visible = false;
				//bi.remove listener
				bi.hmBtn.removeEventListener(MouseEvent.CLICK, hmBtnClick);
			}
			else
			{
				if(!hm.canBuild(resourceArray))
					mb.changeMessage("You don't have enough resources to build this, captain. You can either wait for them to be produced or reset your level to try again.");
				if(resourceArray[0] >= resourceArray[1])
					mb.changeMessage("You don't have enough space for any more colonists. Most buildings bring at least one person to operate it.");
				if(deliveryInProgress)
					mb.changeMessage("It looks like there was still a delivery in progress, you have to wait until the ship returns before ordering something else.");
			}
		}
		function hmBtnOver(event:MouseEvent):void
		{
			bi.description.text = "Habitation Module: Every Colonist needs a place to live, some buildings bring more colonists. Place this building to expand your maximum population, but look out, more colonists drain resources faster.";
			//cost description
			var b:HabitationModule = new HabitationModule();
			showCosts(b);
			//show schematic
			bi.schematic.gotoAndStop(7); //show schematic
		}
		//Storage Building placement and description
		function sbBtnClick(event:MouseEvent):void
		{
			//add StorageBuilding
			var sb:StorageBuilding = new StorageBuilding();
			buildings.push(sb);
			if (sb.canBuild(resourceArray) && !deliveryInProgress && resourceArray[0] < resourceArray[1])
			{
				tt.addChild(sb);
				tt.occupied = true;
				tt.walkable = false;
				tt.isBuilding = true;
				tt.buildingType = "StorageBuilding";
				
				
				//call delivery ship
				makeDelivery();
				//subtract funds
				resourceArray = sb.subtractCosts(resourceArray);
				
				//expand storage
				es.timeEnd += 5;
				os.timeEnd += 5;
				fds.timeEnd += 5;
				ws.timeEnd += 5;
				ms.timeEnd += 5;
				fls.timeEnd += 5;
				
				//destroy menu
				bi.enabled = false;
				bi.visible = false;
				//bi.remove listener
				bi.sbBtn.removeEventListener(MouseEvent.CLICK, sbBtnClick);
			}
			else
			{
				if(!sb.canBuild(resourceArray))
					mb.changeMessage("You don't have enough resources to build this, captain. You can either wait for them to be produced or reset your level to try again.");
				if(resourceArray[0] >= resourceArray[1])
					mb.changeMessage("You don't have enough space for any more colonists. Most buildings bring at least one person to operate it.");
				if(deliveryInProgress)
					mb.changeMessage("It looks like there was still a delivery in progress, you have to wait until the ship returns before ordering something else.");
			}
		}
		function sbBtnOver(event:MouseEvent):void
		{
			bi.description.text = "Storage Building: If you are running out of space to store resources or need to store more at a time, place this to increase storage capacity.";
			//cost description
			var b:StorageBuilding = new StorageBuilding();
			showCosts(b);
			//show schematic
			bi.schematic.gotoAndStop(8); //show schematic
		}
		//rolling out of button 
		function BtnOut(event:MouseEvent):void
		{
			//get rid of information
			bi.description.text = "Hover over one of the building buttons to get a brief description of the building. ";
			//cost description
			ri.moneyCostText.text = "";
			ri.energyCostText.text = "";
			ri.oxygenCostText.text = "";
			ri.foodCostText.text =  "";
			ri.waterCostText.text = "";
			ri.metalCostText.text = "";
			ri.fuelCostText.text = "";
			
			//hide schematic
			bi.schematic.gotoAndStop(1);
		}
		//upgrade
		function upgradeBtnClick(event:MouseEvent):void 
		{
			//upgrade building
			if (!deliveryInProgress)
			{
				var build:building = new building(0);
				build = tt.getChildAt(tt.numChildren - 3) as building; //this might change later if more children are added to buildings
				
				
				if (build.canUpgrade(resourceArray))
				{
					//subtract funds
					resourceArray = build.subtractCosts(resourceArray);
					build.buildLevel++;
					build.gotoAndStop(build.currentFrame+1);
				}
				else //not enough funds
				{
					mb.changeMessage("You don't have enough resources to build this, captain. You can either wait for them to be produced or reset your level to try again.");
				}
			}
			else //delivery still in progress
			{
				mb.changeMessage("It looks like there was still a delivery in progress, you have to wait until the ship returns before ordering something else.");
			}
		}
		function upgradeBtnOver(event:MouseEvent):void
		{
			var b:building = new building(0);
			b = tt.getChildAt(tt.numChildren - 3) as building; //this might change later if more children are added to buildings
			
			//display how much will be returned
			ri.moneyCostText.text = "-" + (b.cost$ *b.buildLevel).toString();
			ri.energyCostText.text = "-" + (b.costE *b.buildLevel).toString();
			ri.oxygenCostText.text = "-" + (b.costO *b.buildLevel).toString();
			ri.foodCostText.text = "-" + (b.costFd *b.buildLevel).toString();
			ri.waterCostText.text = "-" + (b.costW *b.buildLevel).toString();	
			ri.metalCostText.text = "-" + (b.costM *b.buildLevel).toString();
			ri.fuelCostText.text = "-" + (b.costF *b.buildLevel).toString();
			
			ui.upgradeDescription.text = "Upgrading this building will cost the same amount as the building's initial cost multiplied by it's upgrade level.";

		}
		function sellBtnClick(event:MouseEvent):void
		{
			var b:building = new building(0);
			b = tt.getChildAt(tt.numChildren - 3) as building; //this might change later if more children are added to buildings
			
			//add resources back
			resourceArray = b.sellBuilding(resourceArray);
			//remove building
			var t:building = new building(0);
			for(var i:int =0; i < buildings.length; i++)
			{
				t = buildings[i] as building;
				if (b == t)
				{
					//remove building
					buildings.splice(i,1);
					tt.removeChild(b);
				}
			}
			//make tile useable again
			tt.occupied = false;
			tt.isBuilding = false;
			tt.buildingType = "blank";
			//subtract population
			resourceArray[0]--;
		}
		function sellBtnOver(event:MouseEvent):void
		{
			var b:building = new building(0);
			b = tt.getChildAt(tt.numChildren - 3) as building; //this might change later if more children are added to buildings
			
			//display how much will be returned
			ri.moneyCostText.text = "+" + (b.cost$ / 2).toString();
			ri.energyCostText.text = "+" + (b.costE / 2).toString();
			ri.oxygenCostText.text = "+" + (b.costO / 2).toString();
			ri.foodCostText.text = "+" + (b.costFd / 2).toString();
			ri.waterCostText.text = "+" + (b.costW / 2).toString();	
			ri.metalCostText.text = "+" + (b.costM / 2).toString();
			ri.fuelCostText.text = "+" + (b.costF / 2).toString();
			
			ui.upgradeDescription.text = "Selling this building will return half of its cost including the resources used to upgrade it.";
		}
		////misc utilities
		//get a type of building. B is building as building, a is value in buildings array
		function getBuildType(B:building, A:int):building
		{
			var b:building = B as building;
				if (buildings[A] is MissionControl)
				{
					b = buildings[A] as MissionControl;
				}
				else if (buildings[A] is MiningDrill)
				{
					b = buildings[A] as MiningDrill;
				}
				else if (buildings[A] is PowerStation)
				{
					b = buildings[A] as PowerStation;
				}
				else if (buildings[A] is IceDrill)
				{
					b = buildings[A] as IceDrill;
				}
				else if (buildings[A] is ElectrolysisStation)
				{
					b = buildings[A] as ElectrolysisStation;
				}
				else if (buildings[A] is HydroponicsFarm)
				{
					b = buildings[A] as HydroponicsFarm;
				}
				else if (buildings[A] is HabitationModule)
				{
					b = buildings[A] as HabitationModule;
				}
				else if (buildings[A] is StorageBuilding)
				{
					b = buildings[A] as StorageBuilding;
				}
				
				//add more types
				
			return b;
		}
		//activate different menus
		//build, upgrade, etc
		function activateMenu(type:String):void
		{
			//hide mission instructions
			if(mi.opened)
				mi.lower();
				
			if (type.substr(0,6) == "build_") // check if build menu
			{
				//lower messageBoard
				if(mb.opened)
					mb.lower();
				
				addChild(bi);
				bi.visible = true;
				bi.enabled = true;
				bi.x = 0;		
				bi.y = 0
				
				var remainder:String = type.substr(6,type.length-5);
				if(remainder == "blank") // check if empty tile
				{
					//enable necessary buttons
					bi.mcBtn.enabled = true;
					bi.mcBtn.alpha = 1;
					bi.psBtn.enabled = true;
					bi.psBtn.alpha = 1;
					bi.hfBtn.enabled = true;
					bi.hfBtn.alpha = 1;
					bi.esBtn.enabled = true;
					bi.esBtn.alpha = 1;
					bi.sbBtn.enabled = true;
					bi.sbBtn.alpha = 1;
					
					//bi.addmouselistener for click of buttons
					bi.mcBtn.addEventListener(MouseEvent.CLICK, mcBtnClick);
					bi.mcBtn.addEventListener(MouseEvent.MOUSE_OVER, mcBtnOver);
					bi.mcBtn.addEventListener(MouseEvent.ROLL_OUT, BtnOut); 
					bi.psBtn.addEventListener(MouseEvent.CLICK, psBtnClick);
					bi.psBtn.addEventListener(MouseEvent.MOUSE_OVER, psBtnOver);
					bi.psBtn.addEventListener(MouseEvent.ROLL_OUT, BtnOut);
					bi.mdBtn.addEventListener(MouseEvent.CLICK, mdBtnClick);
					bi.mdBtn.addEventListener(MouseEvent.MOUSE_OVER, mdBtnOver);
					bi.mdBtn.addEventListener(MouseEvent.ROLL_OUT, BtnOut);
					bi.hfBtn.addEventListener(MouseEvent.CLICK, hfBtnClick);
					bi.hfBtn.addEventListener(MouseEvent.MOUSE_OVER, hfBtnOver);
					bi.hfBtn.addEventListener(MouseEvent.ROLL_OUT, BtnOut);
					bi.esBtn.addEventListener(MouseEvent.CLICK, elsBtnClick);
					bi.esBtn.addEventListener(MouseEvent.MOUSE_OVER, elsBtnOver);
					bi.esBtn.addEventListener(MouseEvent.ROLL_OUT, BtnOut);
					bi.sbBtn.addEventListener(MouseEvent.CLICK, sbBtnClick);
					bi.sbBtn.addEventListener(MouseEvent.MOUSE_OVER, sbBtnOver);
					bi.sbBtn.addEventListener(MouseEvent.ROLL_OUT, BtnOut);
					bi.idBtn.addEventListener(MouseEvent.CLICK, idBtnClick);
					bi.idBtn.addEventListener(MouseEvent.MOUSE_OVER, idBtnOver);
					bi.idBtn.addEventListener(MouseEvent.ROLL_OUT, BtnOut);
					bi.hmBtn.addEventListener(MouseEvent.CLICK, hmBtnClick);
					bi.hmBtn.addEventListener(MouseEvent.MOUSE_OVER, hmBtnOver);
					bi.hmBtn.addEventListener(MouseEvent.ROLL_OUT, BtnOut);
										
					//disable unusable resource specific buttons
					//bi.mdBtn.enabled = false;
					//bi.mdBtn.alpha = .5;
					//remove other interface menus
					ui.visible=false;
					ui.enabled=false;
				}
				else if(type.substr(6,4) == "res_") // check if resource tile
				{
					var resType:String = type.substr(10,type.length-9);
					if (resType == "ore") // check if ore type resource
					{
						//enable necessary buttons
						bi.mdBtn.enabled = true;
						bi.mdBtn.alpha = 1;
						//bi.addmouselistener for click of buttons
						bi.mdBtn.addEventListener(MouseEvent.CLICK, mdBtnClick);
						bi.mdBtn.addEventListener(MouseEvent.MOUSE_OVER, mdBtnOver);
						//disable unusable new building buttons
						bi.mcBtn.enabled = false;
						bi.mcBtn.alpha = .5;
						bi.psBtn.enabled = false;
						bi.psBtn.alpha = .5;
						//bi.mcBtn.addEventListener(MouseEvent.CLICK, mcBtnClick);
						//bi.mcBtn.addEventListener(MouseEvent.MOUSE_OVER, mcBtnOver);
						
						//remove other interface menus
						ui.enabled = false;
						ui.visible = false;
						//bi.remove listener
					}
				}
			}
			else if(type.substr(0,8) == "upgrade_") // check if upgrade menu
			{
				//keep instructions up
				mi.visible = true;
				//trace("upgrade menu");
				tt.addChild(ui);
				ui.visible = true;
				ui.enabled = true;
				ui.x = -15;
				ui.y = -150;
				//event listener
				ui.upgradeBtn.addEventListener(MouseEvent.CLICK, upgradeBtnClick);
				ui.upgradeBtn.addEventListener(MouseEvent.MOUSE_OVER, upgradeBtnOver);
				ui.sellBtn.addEventListener(MouseEvent.CLICK, sellBtnClick);
				ui.sellBtn.addEventListener(MouseEvent.MOUSE_OVER, sellBtnOver);
				//remove all interface menus
				
				//add specific buttons
				var remainder2:String = type.substr(8,type.length-7);
				if(remainder2 == "MissionControl") // if missionControl functions
				{
					ui.gotoAndStop(2);
					ui.REBtn.visible = true;
					ui.REBtn.addEventListener(MouseEvent.CLICK, radioEarth);
					ui.REBtn.addEventListener(MouseEvent.MOUSE_OVER, radioEarthOver);
				}
				else if (remainder2 == "general")
				{
					ui.gotoAndStop(1);
					ui.REBtn.visible = false;
				}
			}
		}
		//remove all menus from the screen
		function deactivateMenu():void
		{
			bi.enabled = false;
			ui.enabled = false;
			bi.visible = false;
			ui.visible = false;
			mci.visible = false;
			mci.enabled = false;
			
			//reset resource interface stuff
			ri.moneyCostText.text = "";
			ri.energyCostText.text = "";
			ri.oxygenCostText.text = "";
			ri.foodCostText.text ="";
			ri.waterCostText.text = "";	
			ri.metalCostText.text = "";
			ri.fuelCostText.text = "";
		}
		//building functions
		//radioEarth. needs a MC and a certain amount of energy
		function radioEarth(event:MouseEvent):void//add something for when function executes
		{
			if (resourceArray[3] >= 5)
			{
				resourceArray[3] -= 5;
				mci.visible = false;
				mci.enabled = false;
				earthContacted = true;
				ui.REBtn.removeEventListener(MouseEvent.CLICK, radioEarth);
			}
		}
		function radioEarthOver(event:MouseEvent):void
		{
			ui.upgradeDescription.text = "Radio back to earth to tell them what you've accomplished so far.";
			ri.energyCostText.text = "-5";
		}
		//delivery functions
		//add delivery ship
		private var deliveryMove:Tween;
		function makeDelivery():void 
		{
			ds = new DeliveryShip();
			tt.addChild(ds);
			ds.x = 64;
			deliveryMove = new Tween(ds, "y", Strong.easeOut, -500,-30, 120, false);
			deliveryMove.start();
			deliveryInProgress = true;
			deliveryMove.addEventListener(TweenEvent.MOTION_FINISH, deliveryFinish);
		}
		function deliveryFinish(event:TweenEvent):void
		{
			//remove Event listener
			deliveryMove.removeEventListener(TweenEvent.MOTION_FINISH, deliveryFinish);
			
			deliveryMove = new Tween(ds, "y", Strong.easeIn, -30,-500, 100, false);
			deliveryMove.start();
			
			//add final finish
			deliveryMove.addEventListener(TweenEvent.MOTION_FINISH, deliveryDone);
			
			
		}
		function deliveryDone(event:TweenEvent):void
		{
			deliveryMove.removeEventListener(TweenEvent.MOTION_FINISH, deliveryDone);
			deliveryInProgress = false;
		}
		//add lander functions
		public function placeLander(event:MouseEvent):void
		{
			if (!(event.target as tile).occupied)
			{
				var mousePos:Point = (event.target as tile).coord;
				addLander(mousePos);
				updateMission(maps.getObj(levelNum, objNum));
				
				world.removeEventListener(MouseEvent.CLICK, placeLander);	
			}
		}
		private var land:Tween; //landing animation
		function addLander(p:Point):void
		{
			var r:int = p.x;
			var c:int = p.y;
			var T:tile = world._floorTiles[r][c] as tile;
			var a:Lander = new Lander();
			land = new Tween(a, "y", Regular.easeOut, -600, 0, 2.5, true);
			land.start();
			T.occupied = true;
			T.addChild(a);
			landerPlaced = true;
			resourceArray[0] = 1;
		}
		//update mission box
		private var missionTween:Tween; 
		private var newMission:String;
		function updateMission(str:String):void
		{
			newMission = str;
			missionTween = new Tween(mi.mission, "alpha", Regular.easeIn, 1, 0, .5, true);
			missionTween.start();
			missionTween.addEventListener(TweenEvent.MOTION_FINISH, updateMissionFinish);
		}
		function updateMissionFinish(event:TweenEvent):void
		{
			mi.changeMessage(newMission);
			missionTween = new Tween(mi.mission, "alpha", Regular.easeIn, 0, 1, .5, true);
			missionTween.start();
			missionTween.removeEventListener(TweenEvent.MOTION_FINISH, updateMissionFinish);
		}
		//check win
		/*
		just comments
			initial thoughts for checkwin: it will be comlicated
			each objective will have to be in an array, the whole list
			of objectives is an array. Each specific objective array will 
			be broken down by obj type, specific goal, then an int for degree.
			
			ex Array(1, "MissionControl", 4) 
			- check for a type of building -> mission control -> level 4 (at least)
			
			objectivee types:
			1. checkBuilding - checks for building of certain level
			2. checkResources - checks for certain amount of a resource
			3. check contacct - checks if you've recently contacted earth
			
		*/
		function checkWin(objectivesList:Array):Boolean
		{
			var res:Boolean = true;
			for (var i:int = 0; i < objectivesList.length; i++)
			{
				if (!checkObjective(objectivesList[i]))
					res = false;
			}
			return res;
		}
		function checkObjective(objective:Array):Boolean
		{
			var res:Boolean = false;
			if (objective[0] == 1)// checkBuilding 
				res = checkBuilding(objective[1],objective[2]);
			if (objective[0] == 2)// checkResource
				res = checkResource(objective[1], objective[2]);
			if (objective[0] == 3)// check contact
				res = checkContact();
			return res;
		}
		function checkBuilding(c:Class, level:int):Boolean
		{
			
			var temp:Boolean = false;
			for (var i:int = 0; i < buildings.length; i++)
			{
				var b:building = buildings[i] as building;
				trace(b.buildLevel, level);
				if (b is c && b.buildLevel >= level) //checks for building of certain level
				{
					temp = true;
				}
			}
			return temp;
		}
		//instructions for checkResource
		/*
		for resource, put in the corresponding integer value from the resource array
		0 = money, energy = 1, oxygen = 2, etc
		Then just put in the minimal desired amount
		*/
		function checkResource(resource:int, amount:int):Boolean
		{
			var res:Boolean = false;
			if (resourceArray[resource] >= amount)
				res = true;
			return res;
		}
		//check if earth has been contacted
		function checkContact():Boolean
		{
			return earthContacted;
		}
		//next level
		function nextLevel():void
		{ 
			if (maps.objectives[levelNum] != null) //if  a next level exists
			{
				levelNum++;
				dayNum=1;
				objNum = 1;
				//reset resources
				setResources(maps.getStartingResources(levelNum));
				clearCosts();
				//reset day progress
				useTimer.resetBar();
				//clear arrays
				buildings.splice(0,buildings.length);
				//reset game variables
				isStart = false;
				toolMode = "build";
				landerPlaced = false;
				earthContacted = false;
				deliveryInProgress = false;
				
				updateMission(maps.getObj(levelNum, objNum));
				world.changeMap(maps.levels[levelNum]);
				
				//reset messageBoard and provide hints
				if (levelNum == 2)
					mb.changeMessage("*Hint* Certain tiles will affect buildings in different ways. Those tile in the center look like the ice is thin.");
				else 
					mb.changeMessage("Congratulations Captain! Onwards to the next Colony.");
				
				//show level name
				mi.levelName.text = maps.levelNames[levelNum];
				
				world.addEventListener(MouseEvent.CLICK, placeLander);

			}
			else
			{
				//win game
			}
		}
		//reset current level
		function resetLevel(event:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, update);
			
			//reset level counters
			dayNum=1;
			objNum = 1;
			//reset game variables
			landerPlaced = false;
			earthContacted = false;
			//reset resources
			setResources(maps.getStartingResources(levelNum));
			clearCosts();
			//reset day progress
			useTimer.resetBar();
			//clear arrays
			buildings.splice(0,buildings.length);
			//clear level
			updateMission(maps.getObj(levelNum, objNum));
			world.changeMap(maps.levels[levelNum]);
			
			//reset messageBoard
			mb.changeMessage("Space Captain's don't make mistakes, I'm sure you meant to do that");
			
			world.addEventListener(MouseEvent.CLICK, placeLander);
			addEventListener(Event.ENTER_FRAME, update);
			
		}
		//new resource array
		function setResources(nr:Array):void
		{
			for (var i:int = 0; i < 10; i ++)
			{
				resourceArray[i] = nr[i];
			}
			//reset storage
			es.timeEnd = 15;
			fds.timeEnd = 10;
			ws.timeEnd = 10;
			os.timeEnd = 10;
			ms.timeEnd = 10;
			fls.timeEnd = 10;
		}
		//set resource cost texts
		function showCosts(b:building):void
		{
			ri.moneyCostText.text = "-" + b.cost$.toString();
			ri.energyCostText.text = "-" + b.costE.toString();
			ri.oxygenCostText.text = "-" + b.costO.toString();
			ri.foodCostText.text = "-" + b.costFd.toString();
			ri.waterCostText.text = "-" + b.costW.toString();	
			ri.metalCostText.text = "-" + b.costM.toString();
			ri.fuelCostText.text = "-" + b.costF.toString();
		}
		//set the ccost text boxes on the resource bar to blank
		function clearCosts():void
		{
			ri.moneyCostText.text = "";
			ri.energyCostText.text = "";
			ri.oxygenCostText.text = "";
			ri.foodCostText.text = "";
			ri.waterCostText.text = "";
			ri.metalCostText.text = "";
			ri.fuelCostText.text = "";
		}
		//no funciton past this point
		//end of class
	}
}
